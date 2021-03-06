package com.cloud.network.ovs.dao;

import java.util.List;

import com.cloud.utils.db.GenericDao;

public interface VlanMappingDao extends GenericDao<VlanMappingVO, Long> {
	List<VlanMappingVO> listByAccountIdAndHostId(long accountId, long hostId);

	List<VlanMappingVO> listByHostId(long hostId);

	List<VlanMappingVO> listByAccountId(long accountId);

	List<VlanMappingVO> lockByAccountId(long accoutnId);

	VlanMappingVO findByAccountIdAndHostId(long accountId, long hostId);

	VlanMappingVO lockByAccountIdAndHostId(long accountId, long hostId);
}
