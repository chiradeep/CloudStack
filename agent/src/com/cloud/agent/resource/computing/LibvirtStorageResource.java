package com.cloud.agent.resource.computing;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.log4j.Logger;
import org.libvirt.Connect;
import org.libvirt.LibvirtException;
import org.libvirt.StoragePool;
import org.libvirt.StoragePoolInfo;
import org.libvirt.StorageVol;
import org.libvirt.StoragePoolInfo.StoragePoolState;

import com.cloud.agent.api.to.StorageFilerTO;
import com.cloud.agent.resource.computing.KVMHABase.PoolType;
import com.cloud.agent.resource.computing.LibvirtStoragePoolDef.poolType;
import com.cloud.agent.resource.computing.LibvirtStorageVolumeDef.volFormat;
import com.cloud.exception.InternalErrorException;
import com.cloud.storage.Storage.StoragePoolType;
import com.cloud.storage.StorageLayer;
import com.cloud.utils.script.Script;

public class LibvirtStorageResource {
    private static final Logger s_logger = Logger.getLogger(LibvirtStorageResource.class);
    private LibvirtComputingResource _computingResource;
    private final Map<String, Object> _storagePools = new ConcurrentHashMap<String, Object>();
    private StorageLayer _storageLayer;
    private String _createvmPath;
    private int _timeout;
    private String _mountPoint;
    private KVMHAMonitor _monitor;
    
    public LibvirtStorageResource(LibvirtComputingResource resource, StorageLayer storage, String createDiskScript, int timeout,
                                  String mountPoint, KVMHAMonitor monitor) {
        _computingResource = resource;
        _storageLayer = storage;
        _createvmPath = createDiskScript;
        _timeout = timeout;
        _mountPoint = mountPoint;
        _monitor = monitor;
    }
    public StoragePool getStoragePool(Connect conn, String uuid) throws LibvirtException {
        StoragePool storage = null;
        try {
            storage = conn.storagePoolLookupByUUIDString(uuid);
        } catch (LibvirtException e) {
            throw e;
        }
        
        if ( storage.getInfo().state != StoragePoolState.VIR_STORAGE_POOL_RUNNING) {
            storage.create(0);
        }
        return storage;
    }
    
    public boolean deleteStoragePool(Connect conn, StorageFilerTO spt) throws LibvirtException {
        StoragePool pool = getStoragePool(conn, spt.getUuid());
        
        synchronized (getStoragePool(pool.getUUIDString())) {
            pool.destroy();
            pool.undefine();
        }
        
        LibvirtStoragePoolDef spd = getStoragePoolDef(conn, pool);
        
        if (spd.getPoolType() == poolType.NETFS) {
            KVMHABase.NfsStoragePool sp = new KVMHABase.NfsStoragePool(spt.getUuid(),
                    spt.getHost(),
                    spt.getPath(),
                    spd.getTargetPath(),
                    PoolType.PrimaryStorage);
            _monitor.removeStoragePool(sp);
        }
        rmStoragePool(spt.getUuid());
        return true;
    }
    
    public boolean deleteStoragePool(Connect conn, StoragePool pool) throws LibvirtException {
        if (pool != null) {
            String uuid = pool.getUUIDString();
            synchronized (getStoragePool(uuid)) {
                pool.destroy();
                pool.undefine();
                pool.free();
            }
            rmStoragePool(uuid);
        }
        return true;
    }
    
    public StorageVol getVolume(Connect conn, StoragePool pool, String volPath) throws LibvirtException {
        StorageVol vol = null;
        try {
            vol = conn.storageVolLookupByKey(volPath);
        } catch (LibvirtException e) {
            
        }
        if (vol == null) {
            storagePoolRefresh(pool);
            vol = conn.storageVolLookupByKey(volPath);
        }
        return vol;
    }
    
    public StorageVol createVolumeFromTempl(StoragePool destPool, StorageVol tmplVol) throws LibvirtException {
        if (_computingResource.isCentosHost()) {
            LibvirtStorageVolumeDef volDef = new LibvirtStorageVolumeDef(UUID.randomUUID().toString(), tmplVol.getInfo().capacity, volFormat.QCOW2, null, null);
            s_logger.debug(volDef.toString());
            StorageVol vol = destPool.storageVolCreateXML(volDef.toString(), 0);
            
            /*create qcow2 image based on the name*/
            Script.runSimpleBashScript("qemu-img create -f qcow2 -b  " + tmplVol.getPath() + " " + vol.getPath() );
            return vol;
        } else {
            LibvirtStorageVolumeDef volDef = new LibvirtStorageVolumeDef(UUID.randomUUID().toString(), tmplVol.getInfo().capacity, volFormat.QCOW2, tmplVol.getPath(), volFormat.QCOW2);
            s_logger.debug(volDef.toString());
            return destPool.storageVolCreateXML(volDef.toString(), 0);
        }
    }
    
    private void addStoragePool(String uuid) {
        synchronized (_storagePools) {
            if (!_storagePools.containsKey(uuid)) {
                _storagePools.put(uuid, new Object());
            }
        }
    }
    
    private void rmStoragePool(String uuid) {
        synchronized (_storagePools) {
            if (_storagePools.containsKey(uuid)) {
                _storagePools.remove(uuid);
            }
        }
    }
    
    private Object getStoragePool(String uuid) {
        synchronized (_storagePools) {
            if (!_storagePools.containsKey(uuid)) {         
                addStoragePool(uuid);
            }
            return _storagePools.get(uuid);
        }
    }
   
    
    public StorageVol createTmplDataDisk(Connect conn, String rootkPath, long size) throws LibvirtException, InternalErrorException {
        /*create a templ data disk, to contain patches*/
        StorageVol rootVol = conn.storageVolLookupByKey(rootkPath);
        StoragePool rootPool = rootVol.storagePoolLookupByVolume();
        LibvirtStorageVolumeDef volDef = new LibvirtStorageVolumeDef(UUID.randomUUID().toString(), size, volFormat.RAW, null, null);
        StorageVol dataVol =  rootPool.storageVolCreateXML(volDef.toString(), 0);

        /*Format/create fs on this disk*/
        final Script command = new Script(_createvmPath, _timeout, s_logger);
        command.add("-f", dataVol.getKey());
        String result = command.execute();
        if (result != null) {
            s_logger.debug("Failed to create data disk: " + result);
            throw new InternalErrorException("Failed to create data disk: " + result);
        }
        return dataVol;
    }
    
    public StorageVol createVolume(Connect conn, StoragePool pool, String uuid, long size, volFormat format) throws LibvirtException {
        LibvirtStorageVolumeDef volDef = new LibvirtStorageVolumeDef(UUID.randomUUID().toString(), size, format, null, null);
        s_logger.debug(volDef.toString());
        return pool.storageVolCreateXML(volDef.toString(), 0);
    }
    
    public StoragePool getStoragePoolbyURI(Connect conn, URI uri) throws LibvirtException {
        String sourcePath = uri.getPath();
        sourcePath = sourcePath.replace("//", "/");
        String sourceHost = uri.getHost();
        String uuid = UUID.nameUUIDFromBytes(new String(sourceHost + sourcePath).getBytes()).toString();
        String targetPath = _mountPoint + File.separator + uuid;
        StoragePool sp = null;
        try {
            sp = conn.storagePoolLookupByUUIDString(uuid);
        }  catch (LibvirtException e) {
        }

        if (sp == null) {
            try {
                _storageLayer.mkdir(targetPath);
                LibvirtStoragePoolDef spd = new LibvirtStoragePoolDef(poolType.NETFS, uuid, uuid,
                        sourceHost, sourcePath, targetPath);
                s_logger.debug(spd.toString());
                addStoragePool(uuid);

                synchronized (getStoragePool(uuid)) {
                    sp = conn.storagePoolDefineXML(spd.toString(), 0);

                    if (sp == null) {
                        s_logger.debug("Failed to define storage pool");
                        return null;
                    }
                    sp.create(0);
                }

                return sp;
            } catch (LibvirtException e) {
                try {
                    if (sp != null) {
                        sp.undefine();
                        sp.free();
                    }
                } catch (LibvirtException l) {

                }
                throw e;
            }
        } else {
            StoragePoolInfo spi = sp.getInfo();
            if (spi.state != StoragePoolState.VIR_STORAGE_POOL_RUNNING) {
                sp.create(0);
            }
            return sp;
        }
    }
    
    public void storagePoolRefresh(StoragePool pool) {
        try {
            synchronized (getStoragePool(pool.getUUIDString())) {
                pool.refresh(0);
            }
        } catch (LibvirtException e) {
            
        }
    }
    
    private StoragePool createNfsStoragePool(Connect conn, StorageFilerTO pool) {
        String targetPath = _mountPoint + File.separator + pool.getUuid();
        LibvirtStoragePoolDef spd = new LibvirtStoragePoolDef(poolType.NETFS, pool.getUuid(), pool.getUuid(),
                                                              pool.getHost(), pool.getPath(), targetPath);
        _storageLayer.mkdir(targetPath);
        StoragePool sp = null;
        try {
            s_logger.debug(spd.toString());
            addStoragePool(pool.getUuid());
            
            synchronized (getStoragePool(pool.getUuid())) {
                sp = conn.storagePoolDefineXML(spd.toString(), 0);
                sp.create(0);
            }
            return sp;
        } catch (LibvirtException e) {
            s_logger.debug(e.toString());
            if (sp != null) {
                try {
                    sp.undefine();
                    sp.free();
                } catch (LibvirtException l) {
                    s_logger.debug("Failed to define nfs storage pool with: " + l.toString());
                }
            }
            return null;
        }
    }
    
    private StoragePool CreateSharedStoragePool(Connect conn, StorageFilerTO pool) {
        String mountPoint = pool.getPath();
        if (!_storageLayer.exists(mountPoint)) {
            return null;
        }
        LibvirtStoragePoolDef spd = new LibvirtStoragePoolDef(poolType.DIR, pool.getUuid(), pool.getUuid(),
                                                             pool.getHost(), pool.getPath(), pool.getPath());
        StoragePool sp = null;
        try {
            addStoragePool(pool.getUuid());
            synchronized (getStoragePool(pool.getUuid())) {
                sp = conn.storagePoolDefineXML(spd.toString(), 0);
                sp.create(0);
            }
            return sp;
        } catch (LibvirtException e) {
            s_logger.debug(e.toString());
            if (sp != null) {
                try {
                    sp.undefine();
                    sp.free();
                } catch (LibvirtException l) {
                    s_logger.debug("Failed to define shared mount point storage pool with: " + l.toString());
                }
            }
            return null;
        }
    }
    
    public StoragePool getStoragePool(Connect conn, StorageFilerTO spt) {
        StoragePool sp = null;
        try {
            sp = conn.storagePoolLookupByUUIDString(spt.getUuid());
        } catch (LibvirtException e) {
            
        }
        
        if (sp == null) {
            if (spt.getType() == StoragePoolType.NetworkFilesystem) {
                sp = createNfsStoragePool(conn, spt);
            } else if (spt.getType() == StoragePoolType.SharedMountPoint) {
                sp = CreateSharedStoragePool(conn, spt);
            }
            if (sp == null) {
                s_logger.debug("Failed to create storage Pool");
                return null;
            }
        }
        
        try {
            StoragePoolInfo spi = sp.getInfo();
            if (spi.state != StoragePoolState.VIR_STORAGE_POOL_RUNNING) {
                sp.create(0);
            }
        } catch (LibvirtException e) {

        }
        
        if (spt.getType() == StoragePoolType.NetworkFilesystem) {
            KVMHABase.NfsStoragePool pool = new KVMHABase.NfsStoragePool(spt.getUuid(),
                    spt.getHost(),
                    spt.getPath(),
                    _mountPoint + File.separator + spt.getUuid(),
                    PoolType.PrimaryStorage);
            _monitor.addStoragePool(pool);
        }
        
        addStoragePool(spt.getUuid());

        return sp;
    }
    
    public StorageVol copyVolume(StoragePool destPool, LibvirtStorageVolumeDef destVol, StorageVol srcVol) throws LibvirtException {
        if (_computingResource.isCentosHost()) {
            /*define a volume, then override the file*/
            
            StorageVol vol = destPool.storageVolCreateXML(destVol.toString(), 0);
            String srcPath = srcVol.getKey();
            String destPath = vol.getKey();
            Script.runSimpleBashScript("cp " + srcPath + " " + destPath );
            return vol;
        } else {
            return destPool.storageVolCreateXMLFrom(destVol.toString(), srcVol, 0);
        }
    }
    
    public LibvirtStoragePoolDef getStoragePoolDef(Connect conn, StoragePool pool) throws LibvirtException {
        String poolDefXML = pool.getXMLDesc(0);
        LibvirtStoragePoolXMLParser parser = new LibvirtStoragePoolXMLParser();
        return parser.parseStoragePoolXML(poolDefXML);
    }
    
    public StorageVol getVolumeFromURI(Connect conn, String volPath) throws LibvirtException, URISyntaxException {
        int index = volPath.lastIndexOf("/");
        URI volDir = null;
        StoragePool sp = null;
        StorageVol vol = null;
        try {
            volDir = new URI(volPath.substring(0, index));
            String volName = volPath.substring(index + 1);
            sp = getStoragePoolbyURI(conn, volDir);
            vol = sp.storageVolLookupByName(volName);
            return vol;
        } catch (LibvirtException e) {
            s_logger.debug("Faild to get vol path: " + e.toString());
            throw e;
        } finally {
            try {
                if (sp != null) {
                    sp.free();
                }
            } catch (LibvirtException e) {

            }
        }
    }
    
}