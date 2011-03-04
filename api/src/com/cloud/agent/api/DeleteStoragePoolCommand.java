/**
 *  Copyright (C) 2010 Cloud.com, Inc.  All rights reserved.
 * 
 * This software is licensed under the GNU General Public License v3 or later.
 * 
 * It is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 */

package com.cloud.agent.api;

import java.io.File;
import java.util.UUID;

import com.cloud.agent.api.to.StorageFilerTO;
import com.cloud.storage.StoragePool;

public class DeleteStoragePoolCommand extends Command {
	
	StorageFilerTO pool;
	public static final String LOCAL_PATH_PREFIX="/mnt/";
	String localPath;
	
	public DeleteStoragePoolCommand() {
		
	}
    
    public DeleteStoragePoolCommand(StoragePool pool, String localPath) {
    	this.pool = new StorageFilerTO(pool);
    	this.localPath = localPath;
    }
    
    public DeleteStoragePoolCommand(StoragePool pool) {
		this(pool, LOCAL_PATH_PREFIX + File.separator + UUID.nameUUIDFromBytes((pool.getHostAddress() + pool.getPath()).getBytes()));
	}

    public StorageFilerTO getPool() {
        return pool;
    }

    public void setPool(StoragePool pool) {
        this.pool = new StorageFilerTO(pool);
    }
    
	@Override
    public boolean executeInSequence() {
        return false;
    }

	public String getLocalPath() {
		return localPath;
	}
	
}