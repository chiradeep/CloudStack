--;
-- Schema upgrade from 2.1 to 2.2;
--;
ALTER TABLE `cloud`.`cluster` ADD COLUMN `guid` varchar(255) UNIQUE DEFAULT NULL;
ALTER TABLE `cloud`.`cluster` ADD COLUMN `cluster_type` varchar(64) DEFAULT 'CloudManaged';
ALTER TABLE `cloud`.`vm_template` ADD COLUMN `hypervisor_type` varchar(32) COMMENT 'hypervisor that the template is belonged to';
ALTER TABLE `cloud`.`vm_template` ADD COLUMN `extractable` int(1) unsigned NOT NULL default 0 COMMENT 'Is this template extractable';
ALTER TABLE `cloud`.`template_spool_ref` ADD CONSTRAINT `fk_template_spool_ref__template_id` FOREIGN KEY (`template_id`) REFERENCES `vm_template`(`id`);    
ALTER TABLE `cloud`.`template_spool_ref` ADD CONSTRAINT `fk_template_spool_ref__pool_id` FOREIGN KEY (`pool_id`) REFERENCES `storage_pool`(`id`) ON DELETE CASCADE;

-- NOTE for tables below;
-- these 2 tables were used in 2.1, but are not in 2.2;
-- we will need a migration script for these tables when the migration is written;
-- furthermore we have renamed the following in 2.2;
-- network_group table --> security_group table;
-- network_group_vm_map table --> security_group_vm_map table;
DROP TABLE `cloud`.`security_group`;
DROP TABLE `cloud`.`security_group_vm_map`;
-- needs a migration step;
#ALTER TABLE `cloud`.`account` DROP COLUMN `network_domain`;

-- New migration from 2.1 to 2.2;

-- Easy stuff first.  All new tables.;

CREATE TABLE `cloud`.`version` (
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'id',
  `version` char(40) NOT NULL UNIQUE COMMENT 'version',
  `updated` datetime NOT NULL COMMENT 'Date this version table was updated',
  `step` char(32) NOT NULL COMMENT 'Step in the upgrade to this version',
  PRIMARY KEY (`id`),
  INDEX `i_version__version`(`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`mshost` MODIFY COLUMN `msid` bigint unsigned NOT NULL UNiQUE;

CREATE TABLE `cloud`.`op_it_work` (
  `id` char(40) COMMENT 'reservation id',
  `mgmt_server_id` bigint unsigned COMMENT 'management server id',
  `created_at` bigint unsigned NOT NULL COMMENT 'when was this work detail created',
  `thread` varchar(255) NOT NULL COMMENT 'thread name',
  `type` char(32) NOT NULL COMMENT 'type of work',
  `vm_type` char(32) NOT NULL COMMENT 'type of vm',
  `step` char(32) NOT NULL COMMENT 'state',
  `updated_at` bigint unsigned NOT NULL COMMENT 'time it was taken over',
  `instance_id` bigint unsigned NOT NULL COMMENT 'vm instance',
  `resource_type` char(32) COMMENT 'type of resource being worked on',
  `resource_id` bigint unsigned COMMENT 'resource id being worked on',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_op_it_work__mgmt_server_id` FOREIGN KEY (`mgmt_server_id`) REFERENCES `mshost`(`msid`),
  CONSTRAINT `fk_op_it_work__instance_id` FOREIGN KEY (`instance_id`) REFERENCES `vm_instance`(`id`) ON DELETE CASCADE,
  INDEX `i_op_it_work__step`(`step`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`network_offerings` (
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'id',
  `name` varchar(64) NOT NULL unique COMMENT 'network offering',
  `display_text` varchar(255) NOT NULL COMMENT 'text to display to users',
  `nw_rate` smallint unsigned COMMENT 'network rate throttle mbits/s',
  `mc_rate` smallint unsigned COMMENT 'mcast rate throttle mbits/s',
  `concurrent_connections` int(10) unsigned COMMENT 'concurrent connections supported on this network',
  `traffic_type` varchar(32) NOT NULL COMMENT 'traffic type carried on this network',
  `tags` varchar(4096) COMMENT 'tags supported by this offering',
  `system_only` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Is this network offering for system use only',
  `specify_vlan` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'Should the user specify vlan',
  `service_offering_id` bigint unsigned UNIQUE COMMENT 'service offering id that this network offering is tied to',
  `created` datetime NOT NULL COMMENT 'time the entry was created',
  `removed` datetime DEFAULT NULL COMMENT 'time the entry was removed',
  `default` int(1) unsigned NOT NULL DEFAULT 0 COMMENT '1 if network offering is default',
  `availability` varchar(255) NOT NULL COMMENT 'availability of the network',
  `dns_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides dns service',
  `gateway_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides gateway service',
  `firewall_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides firewall service',
  `lb_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides lb service',
  `userdata_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides user data service',
  `vpn_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides vpn service',
  `dhcp_service` int(1) unsigned NOT NULL DEFAULT 0 COMMENT 'true if network offering provides dhcp service',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`networks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) COMMENT 'name for this network',
  `display_text` varchar(255) COMMENT 'display text for this network',
  `traffic_type` varchar(32) NOT NULL COMMENT 'type of traffic going through this network',
  `broadcast_domain_type` varchar(32) NOT NULL COMMENT 'type of broadcast domain used',
  `broadcast_uri` varchar(255) COMMENT 'broadcast domain specifier',
  `gateway` varchar(15) COMMENT 'gateway for this network configuration',
  `cidr` varchar(18) COMMENT 'network cidr', 
  `mode` varchar(32) COMMENT 'How to retrieve ip address in this network',
  `network_offering_id` bigint unsigned NOT NULL COMMENT 'network offering id that this configuration is created from',
  `data_center_id` bigint unsigned NOT NULL COMMENT 'data center id that this configuration is used in',
  `guru_name` varchar(255) NOT NULL COMMENT 'who is responsible for this type of network configuration',
  `state` varchar(32) NOT NULL COMMENT 'what state is this configuration in',
  `related` bigint unsigned NOT NULL COMMENT 'related to what other network configuration',
  `domain_id` bigint unsigned NOT NULL COMMENT 'foreign key to domain id',
  `account_id` bigint unsigned NOT NULL COMMENT 'owner of this network',
  `dns1` varchar(255) COMMENT 'comma separated DNS list',
  `dns2` varchar(255) COMMENT 'comma separated DNS list',
  `guru_data` varchar(1024) COMMENT 'data stored by the network guru that setup this network',
  `set_fields` bigint unsigned NOT NULL DEFAULT 0 COMMENT 'which fields are set already',
  `guest_type` char(32) COMMENT 'type of guest network',
  `shared` int(1) unsigned NOT NULL DEFAULT 0 COMMENT '0 if network is shared, 1 if network dedicated',
  `network_domain` varchar(255) COMMENT 'domain',
  `reservation_id` char(40) COMMENT 'reservation id',
  `is_default` int(1) unsigned NOT NULL DEFAULT 0 COMMENT '1 if network is default',
  `created` datetime NOT NULL COMMENT 'date created',
  `removed` datetime COMMENT 'date removed if not null',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_networks__network_offering_id` FOREIGN KEY (`network_offering_id`) REFERENCES `network_offerings`(`id`),
  CONSTRAINT `fk_networks__data_center_id` FOREIGN KEY (`data_center_id`) REFERENCES `data_center`(`id`),
  CONSTRAINT `fk_networks__related` FOREIGN KEY(`related`) REFERENCES `networks`(`id`),
  CONSTRAINT `fk_networks__account_id` FOREIGN KEY(`account_id`) REFERENCES `account`(`id`),
  CONSTRAINT `fk_networks__domain_id` FOREIGN KEY(`domain_id`) REFERENCES `domain`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`op_networks`(
  `id` bigint unsigned NOT NULL UNIQUE KEY,
  `mac_address_seq` bigint unsigned NOT NULL DEFAULT 1 COMMENT 'mac address',
  `nics_count` int unsigned NOT NULL DEFAULT 0 COMMENT '# of nics',
  `gc` tinyint unsigned NOT NULL DEFAULT 1 COMMENT 'gc this network or not',
  `check_for_gc` tinyint unsigned NOT NULL DEFAULT 1 COMMENT 'check this network for gc or not',
  PRIMARY KEY(`id`),
  CONSTRAINT `fk_op_networks__id` FOREIGN KEY (`id`) REFERENCES `networks`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`account_network_ref` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `account_id` bigint unsigned NOT NULL COMMENT 'account id',
  `network_id` bigint unsigned NOT NULL COMMENT 'network id',
  `is_owner` smallint(1) NOT NULL COMMENT 'is the owner of the network',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_account_network_ref__account_id` FOREIGN KEY (`account_id`) REFERENCES `account`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_account_network_ref__networks_id` FOREIGN KEY (`network_id`) REFERENCES `networks`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `cloud`.`certificate` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'id',
  `certificate` text COMMENT 'the actual custom certificate being stored in the db',
  `updated` varchar(1) COMMENT 'status of the certificate',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `cloud`.`certificate` (id,certificate,updated) VALUES ('1',null,'N');

CREATE TABLE `cloud`.`nics` (
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT COMMENT 'id',
  `instance_id` bigint unsigned COMMENT 'vm instance id',
  `mac_address` varchar(17) COMMENT 'mac address',
  `ip4_address` varchar(15) COMMENT 'ip4 address',
  `netmask` varchar(15) COMMENT 'netmask for ip4 address',
  `gateway` varchar(15) COMMENT 'gateway',
  `ip_type` varchar(32) COMMENT 'type of ip',
  `broadcast_uri` varchar(255) COMMENT 'broadcast uri',
  `network_id` bigint unsigned NOT NULL COMMENT 'network configuration id',
  `mode` varchar(32) COMMENT 'mode of getting ip address',  
  `state` varchar(32) NOT NULL COMMENT 'state of the creation',
  `strategy` varchar(32) NOT NULL COMMENT 'reservation strategy',
  `reserver_name` varchar(255) COMMENT 'Name of the component that reserved the ip address',
  `reservation_id` varchar(64) COMMENT 'id for the reservation',
  `device_id` int(10) COMMENT 'device id for the network when plugged into the virtual machine',
  `update_time` timestamp NOT NULL COMMENT 'time the state was changed',
  `isolation_uri` varchar(255) COMMENT 'id for isolation',
  `ip6_address` char(40) COMMENT 'ip6 address',
  `default_nic` tinyint NOT NULL COMMENT "None", 
  `created` datetime NOT NULL COMMENT 'date created',
  `removed` datetime COMMENT 'date removed if not null',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_nics__instance_id` FOREIGN KEY `fk_nics__instance_id`(`instance_id`) REFERENCES `vm_instance`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_nics__networks_id` FOREIGN KEY `fk_nics__networks_id`(`network_id`) REFERENCES `networks`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `network_offerings` VALUES (1,'System-Public-Network','System Offering for System-Public-Network',NULL,NULL,NULL,'Public',NULL,1,0,NULL,now(),NULL,0,'Required',0,0,0,0,0,0,0),(2,'System-Management-Network','System Offering for System-Management-Network',NULL,NULL,NULL,'Management',NULL,1,0,NULL,now(),NULL,0,'Required',0,0,0,0,0,0,0),(3,'System-Control-Network','System Offering for System-Control-Network',NULL,NULL,NULL,'Control',NULL,1,0,NULL,now(),NULL,0,'Required',0,0,0,0,0,0,0),(4,'System-Storage-Network','System Offering for System-Storage-Network',NULL,NULL,NULL,'Storage',NULL,1,0,NULL,now(),NULL,0,'Required',0,0,0,0,0,0,0),(5,'System-Guest-Network','System-Guest-Network',NULL,NULL,NULL,'Guest',NULL,1,0,NULL,now(),NULL,1,'Required',1,0,0,0,1,0,1),(6,'DefaultVirtualizedNetworkOffering','Virtual Vlan',NULL,NULL,NULL,'Guest',NULL,0,0,NULL,now(),NULL,1,'Required',1,1,1,1,1,1,1),(7,'DefaultDirectNetworkOffering','Direct',NULL,NULL,NULL,'Public',NULL,0,0,NULL,now(),NULL,1,'Required',1,0,0,0,1,0,1);

CREATE TABLE `cloud`.`cluster_details` (
  `id` bigint unsigned NOT NULL auto_increment,
  `cluster_id` bigint unsigned NOT NULL COMMENT 'cluster id',
  `name` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_cluster_details__cluster_id` FOREIGN KEY (`cluster_id`) REFERENCES `cluster`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `id` bigint unsigned NOT NULL UNIQUE auto_increment;
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `one_to_one_nat` int(1) unsigned NOT NULL default '0';
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `vm_id` bigint unsigned DEFAULT NULL;
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `state` char(32) NOT NULL DEFAULT 'Free';
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `mac_address` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `source_network_id` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`user_ip_address` ADD COLUMN `network_id` bigint unsigned;

UPDATE `cloud`.`user_ip_address` set state='Allocated' WHERE allocated IS NOT NULL;

CREATE TABLE `cloud`.`firewall_rules` (
  `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
  `ip_address_id` bigint unsigned NOT NULL COMMENT 'id of the corresponding ip address',
  `start_port` int(10) NOT NULL COMMENT 'starting port of a port range',
  `end_port` int(10) NOT NULL COMMENT 'end port of a port range',
  `state` char(32) NOT NULL COMMENT 'current state of this rule',
  `protocol` char(16) NOT NULL default 'TCP' COMMENT 'protocol to open these ports for',
  `purpose` char(32) NOT NULL COMMENT 'why are these ports opened?',
  `account_id` bigint unsigned NOT NULL COMMENT 'owner id',
  `domain_id` bigint unsigned NOT NULL COMMENT 'domain id',
  `network_id` bigint unsigned NOT NULL COMMENT 'network id',
  `xid` char(40) NOT NULL COMMENT 'external id',
  `created` datetime COMMENT 'Date created',
  PRIMARY KEY  (`id`),
  CONSTRAINT `fk_firewall_rules__ip_address_id` FOREIGN KEY(`ip_address_id`) REFERENCES `user_ip_address`(`id`),
  CONSTRAINT `fk_firewall_rules__network_id` FOREIGN KEY(`network_id`) REFERENCES `networks`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_firewall_rules__account_id` FOREIGN KEY(`account_id`) REFERENCES `account`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_firewall_rules__domain_id` FOREIGN KEY(`domain_id`) REFERENCES `domain`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`port_forwarding_rules` (
  `id` bigint unsigned NOT NULL COMMENT 'id',
  `instance_id` bigint unsigned NOT NULL COMMENT 'vm instance id',
  `dest_ip_address` char(40) NOT NULL COMMENT 'id_address',
  `dest_port_start` int(10) NOT NULL COMMENT 'starting port of the port range to map to',
  `dest_port_end` int(10) NOT NULL COMMENT 'end port of the the port range to map to',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_port_forwarding_rules__id` FOREIGN KEY(`id`) REFERENCES `firewall_rules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`load_balancing_rules` (
  `id` bigint unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(4096) NULL COMMENT 'description',
  `default_port_start` int(10) NOT NULL COMMENT 'default private port range start',
  `default_port_end` int(10) NOT NULL COMMENT 'default destination port range end',
  `algorithm` varchar(255) NOT NULL,
  PRIMARY KEY  (`id`),
  CONSTRAINT `fk_load_balancing_rules__id` FOREIGN KEY(`id`) REFERENCES `firewall_rules`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`load_balancer_vm_map` ADD COLUMN `revoke` tinyint(1) unsigned NOT NULL DEFAULT 0;

CREATE TABLE `cloud`.`op_host` (
  `id` bigint unsigned NOT NULL UNIQUE COMMENT 'host id',
  `sequence` bigint unsigned DEFAULT 1 NOT NULL COMMENT 'sequence for the host communication',
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_op_host__id` FOREIGN KEY (`id`) REFERENCES `host`(`id`) ON DELETE CASCADE 
) ENGINE = InnoDB DEFAULT CHARSET=utf8;

INSERT INTO op_host(id, sequence) select id, sequence from host;

-- Alter Tables to add Columns;

ALTER TABLE `cloud`.`cluster` ADD COLUMN `hypervisor_type` varchar(32);
UPDATE `cloud`.`cluster` SET hypervisor_type=(SELECT DISTINCT host.hypervisor_type from host where host.cluster_id = cluster.id GROUP BY host.hypervisor_type); 

ALTER TABLE `cloud`.`volumes` ADD COLUMN `attached` datetime;
UPDATE `cloud`.`volumes` SET attached=now() WHERE removed IS NULL AND instance_id IS NOT NULL;

ALTER TABLE `cloud`.`volumes` ADD COLUMN `chain_info` text;

ALTER TABLE `cloud`.`volumes` MODIFY COLUMN `volume_type` VARCHAR(64) NOT NULL;

ALTER TABLE `cloud`.`volumes` ADD COLUMN `state` VARCHAR(32);
UPDATE `cloud`.`volumes` SET state='Destroyed' WHERE removed IS NOT NULL OR destroyed=1 OR status='Creating' OR status='Corrupted' OR status='Failed';
UPDATE `cloud`.`volumes` SET state='Ready' WHERE removed IS NULL AND destroyed=0 AND status='Created';
ALTER TABLE `cloud`.`volumes` MODIFY COLUMN `state` VARCHAR(32) NOT NULL;

ALTER TABLE `cloud`.`vlan` ADD COLUMN `network_id` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`vlan` ADD CONSTRAINT `fk_vlan__data_center_id` FOREIGN KEY `fk_vlan__data_center_id`(`data_center_id`) REFERENCES `data_center`(`id`);

ALTER TABLE `cloud`.`data_center` ADD COLUMN `domain` varchar(100);
ALTER TABLE `cloud`.`data_center` ADD COLUMN `domain_id` bigint unsigned;
ALTER TABLE `cloud`.`data_center` ADD COLUMN `networktype` varchar(255) NOT NULL DEFAULT 'Basic'; 
ALTER TABLE `cloud`.`data_center` ADD COLUMN `dns_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `gateway_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `firewall_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `dhcp_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `lb_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `vpn_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `userdata_provider` char(64) DEFAULT 'VirtualRouter';
ALTER TABLE `cloud`.`data_center` ADD COLUMN `enable` tinyint NOT NULL DEFAULT 1;

#TODO: We need something to adjust the networktype for all of the existing data centers.  How to tell if it is Basic/Advance?;

ALTER TABLE `cloud`.`op_dc_ip_address_alloc` ADD COLUMN `reservation_id` char(40) NULL;
ALTER TABLE `cloud`.`op_dc_ip_address_alloc` ADD COLUMN `mac_address` bigint unsigned NOT NULL;
UPDATE `cloud`.`op_dc_ip_address_alloc` SET reservation_id=concat(cast(instance_id as CHAR), ip_address) WHERE taken is NOT NULL;
#UPDATE `cloud`.`op_dc_ip_address_alloc` as alloc1 SET mac_address=id-(SELECT min(alloc2.id) from op_dc_ip_address_alloc as alloc2 WHERE alloc2.data_center_id=alloc1.data_center_id)+1;  

ALTER TABLE `cloud`.`op_dc_link_local_ip_address_alloc` ADD COLUMN `reservation_id` char(40) NULL;
UPDATE `cloud`.`op_dc_link_local_ip_address_alloc` SET reservation_id=concat(cast(instance_id as CHAR),ip_address) WHERE taken is NOT NULL;

#TODO: Set the Reservation id for this table?;

ALTER TABLE `cloud`.`host_pod_ref` ADD COLUMN `enabled` tinyint NOT NULL DEFAULT 1;

ALTER TABLE `cloud`.`op_dc_vnet_alloc` ADD COLUMN `reservation_id` char(40) NULL;
UPDATE op_dc_vnet_alloc set reservation_id=concat(cast(data_center_id as CHAR), concat("-", vnet)) WHERE taken is NOT NULL; 
#TODO: Set the Reservation id for this table;

ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `service_offering_id` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `reservation_id` char(40);
ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `hypervisor_type` char(32);
ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `account_id` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`vm_instance` ADD COLUMN `domain_id` bigint unsigned NOT NULL;

UPDATE vm_instance inner join user_vm on user_vm.id=vm_instance.id set vm_instance.service_offering_id=user_vm.service_offering_id, vm_instance.account_id=user_vm.account_id, vm_instance.domain_id=user_vm.domain_id where vm_instance.id = user_vm.id and vm_instance.type='User';
UPDATE vm_instance inner join domain_router on vm_instance.id=domain_router.id set vm_instance.account_id=domain_router.account_id, vm_instance.domain_id=domain_router.domain_id where vm_instance.type='DomainRouter';

ALTER TABLE `cloud`.`user_vm` ADD COLUMN `iso_id` bigint unsigned;
ALTER TABLE `cloud`.`user_vm` ADD COLUMN `display_name` varchar(255);

UPDATE user_vm inner join vm_instance on user_vm.id=vm_instance.id set user_vm.iso_id=vm_instance.iso_id, user_vm.display_name=vm_instance.display_name where vm_instance.type='User';

CREATE TABLE `cloud`.`user_vm_details` (
  `id` bigint unsigned NOT NULL auto_increment,
  `vm_id` bigint unsigned NOT NULL COMMENT 'vm id',
  `name` varchar(255) NOT NULL,
  `value` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_user_vm_details__vm_id` FOREIGN KEY `fk_user_vm_details__vm_id`(`vm_id`) REFERENCES `user_vm`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`domain_router` MODIFY COLUMN `guest_netmask` varchar(15);
ALTER TABLE `cloud`.`domain_router` MODIFY COLUMN `guest_ip_address` varchar(15);
ALTER TABLE `cloud`.`domain_router` ADD COLUMN `network_id` bigint unsigned NOT NULL;

CREATE TABLE  `cloud`.`upload` (
  `id` bigint unsigned NOT NULL auto_increment,
  `host_id` bigint unsigned NOT NULL,
  `type_id` bigint unsigned NOT NULL,
  `type` varchar(255),
  `mode` varchar(255),
  `created` DATETIME NOT NULL,
  `last_updated` DATETIME,
  `job_id` varchar(255),
  `upload_pct` int(10) unsigned,
  `upload_state` varchar(255),
  `error_str` varchar(255),
  `url` varchar(255),
  `install_path` varchar(255),
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`template_host_ref` ADD COLUMN `physical size` bigint unsigned DEFAULT 0;

ALTER TABLE `cloud`.`console_proxy` MODIFY COLUMN `public_mac_address` varchar(17);

ALTER TABLE `cloud`.`secondary_storage_vm` MODIFY COLUMN `public_mac_address` varchar(17);
ALTER TABLE `cloud`.`secondary_storage_vm` MODIFY COLUMN `nfs_share` varchar(255);

ALTER TABLE `cloud`.`resource_count` ADD COLUMN `domain_id` bigint unsigned;
ALTER TABLE `cloud`.`resource_count` MODIFY COLUMN `account_id` bigint unsigned;

ALTER TABLE `cloud`.`op_host_capacity` ADD COLUMN `reserved_capacity` bigint unsigned NOT NULL;

ALTER TABLE `cloud`.`disk_offering` ADD COLUMN `system_used` tinyint(1) unsigned NOT NULL DEFAULT 0;
ALTER TABLE `cloud`.`disk_offering` ADD COLUMN `customized` tinyint(1) unsigned NOT NULL DEFAULT 0;

update `cloud`.`disk_offering` set system_used=1, removed=null WHERE unique_name like 'Cloud.Com-%';

CREATE TABLE `cloud`.`remote_access_vpn` (
  `vpn_server_addr_id` bigint unsigned UNIQUE NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `network_id` bigint unsigned NOT NULL,
  `domain_id` bigint unsigned NOT NULL,
  `local_ip` varchar(15) NOT NULL,
  `ip_range` varchar(32) NOT NULL,
  `ipsec_psk` varchar(256) NOT NULL,
  `state` char(32) NOT NULL,
  PRIMARY KEY  (`vpn_server_addr_id`),
  CONSTRAINT `fk_remote_access_vpn__account_id` FOREIGN KEY `fk_remote_access_vpn__account_id`(`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_remote_access_vpn__domain_id` FOREIGN KEY `fk_remote_access_vpn__domain_id`(`domain_id`) REFERENCES `domain`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_remote_access_vpn__network_id` FOREIGN KEY `fk_remote_access_vpn__network_id` (`network_id`) REFERENCES `networks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_remote_access_vpn__vpn_server_addr_id` FOREIGN KEY `fk_remote_access_vpn__vpn_server_addr_id` (`vpn_server_addr_id`) REFERENCES `user_ip_address` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`vpn_users` (
  `id` bigint unsigned NOT NULL UNIQUE auto_increment,
  `owner_id` bigint unsigned NOT NULL,
  `domain_id` bigint unsigned NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `state` char(32) NOT NULL COMMENT 'What state is this vpn user in',
  PRIMARY KEY  (`id`),
  CONSTRAINT `fk_vpn_users__owner_id` FOREIGN KEY (`owner_id`) REFERENCES `account`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vpn_users__domain_id` FOREIGN KEY (`domain_id`) REFERENCES `domain`(`id`) ON DELETE CASCADE,
  INDEX `i_vpn_users_username`(`username`),
  UNIQUE `i_vpn_users__account_id__username`(`owner_id`, `username`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `cloud`.`storage_pool` ADD COLUMN `status` varchar(32);

CREATE TABLE `cloud`.`guest_os_hypervisor` (
  `id` bigint unsigned NOT NULL auto_increment,
  `hypervisor_type` varchar(32) NOT NULL,
  `guest_os_name` varchar(255) NOT NULL,
  `guest_os_id` bigint unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

--drop network group related constraints/indexes;
ALTER TABLE `cloud`.`network_group` drop foreign key `fk_network_group__domain_id`;
alter table `cloud`.`network_group` drop index `i_network_group_name`;

ALTER TABLE `cloud`.`network_ingress_rule` drop foreign key `fk_network_ingress_rule___network_group_id`;
ALTER TABLE `cloud`.`network_ingress_rule` drop foreign key `fk_network_ingress_rule___allowed_network_id`;
ALTER TABLE `cloud`.`network_ingress_rule` drop index `i_network_ingress_rule_network_id`;
ALTER TABLE `cloud`.`network_ingress_rule` drop index `i_network_ingress_rule_allowed_network`;

ALTER TABLE `cloud`.`network_group_vm_map` drop foreign key `fk_network_group_vm_map___network_group_id`;
ALTER TABLE `cloud`.`network_group_vm_map` drop foreign key `fk_network_group_vm_map___instance_id`;

ALTER TABLE `cloud`.`network_group` RENAME TO `security_group`;
ALTER TABLE `cloud`.`network_ingress_rule` RENAME TO `security_ingress_rule`;
ALTER TABLE `cloud`.`security_ingress_rule` CHANGE COLUMN `network_group_id` `security_group_id` bigint unsigned NOT NULL;
ALTER TABLE `cloud`.`security_ingress_rule` CHANGE COLUMN `allowed_network_group` `allowed_security_group` varchar(255);
ALTER TABLE `cloud`.`security_ingress_rule` CHANGE COLUMN `allowed_net_grp_acct` `allowed_sec_grp_acct` varchar(100);
ALTER TABLE `cloud`.`network_group_vm_map` RENAME TO `security_group_vm_map`;
ALTER TABLE `cloud`.`security_group_vm_map` CHANGE COLUMN `network_group_id` `security_group_id` bigint unsigned NOT NULL;

ALTER TABLE `cloud`.`security_group` ADD CONSTRAINT `fk_security_group___account_id` FOREIGN KEY `fk_security_group__account_id` (`account_id`) REFERENCES `account` (`id`) ON DELETE CASCADE;
ALTER TABLE `cloud`.`security_group` ADD CONSTRAINT `fk_security_group__domain_id` FOREIGN KEY `fk_security_group__domain_id` (`domain_id`) REFERENCES `domain` (`id`);
ALTER TABLE `cloud`.`security_group` ADD INDEX `i_security_group_name`(`name`);

ALTER TABLE `cloud`.`security_ingress_rule` ADD CONSTRAINT `fk_security_ingress_rule___security_group_id` FOREIGN KEY `fk_security_ingress_rule__security_group_id` (`security_group_id`) REFERENCES `security_group` (`id`) ON DELETE CASCADE;
ALTER TABLE `cloud`.`security_ingress_rule` ADD CONSTRAINT `fk_security_ingress_rule___allowed_network_id` FOREIGN KEY `fk_security_ingress_rule__allowed_network_id` (`allowed_network_id`) REFERENCES `security_group` (`id`) ON DELETE CASCADE;
ALTER TABLE `cloud`.`security_ingress_rule` ADD INDEX `i_security_ingress_rule_network_id`(`security_group_id`);
ALTER TABLE `cloud`.`security_ingress_rule` ADD INDEX `i_security_ingress_rule_allowed_network`(`allowed_network_id`);

ALTER TABLE `cloud`.`security_group_vm_map` ADD CONSTRAINT `fk_security_group_vm_map___security_group_id` FOREIGN KEY `fk_security_group_vm_map___security_group_id` (`security_group_id`) REFERENCES `security_group` (`id`) ON DELETE CASCADE;
ALTER TABLE `cloud`.`security_group_vm_map` ADD CONSTRAINT `fk_security_group_vm_map___instance_id` FOREIGN KEY `fk_security_group_vm_map___instance_id` (`instance_id`) REFERENCES `user_vm` (`id`) ON DELETE CASCADE;
--n/w to sec grps ends --;

CREATE TABLE `cloud`.`instance_group` (
  `id` bigint unsigned NOT NULL UNIQUE auto_increment,
  `account_id` bigint unsigned NOT NULL COMMENT 'owner.  foreign key to account table',
  `name` varchar(255) NOT NULL,
  `removed` datetime COMMENT 'date the group was removed',
  `created` datetime COMMENT 'date the group was created',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`instance_group_vm_map` (
  `id` bigint unsigned NOT NULL auto_increment,
  `group_id` bigint unsigned NOT NULL,
  `instance_id` bigint unsigned NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ssh_keypairs` (
  `id` bigint unsigned NOT NULL auto_increment COMMENT 'id',
  `account_id` bigint unsigned NOT NULL COMMENT 'owner, foreign key to account table',
  `domain_id` bigint unsigned NOT NULL COMMENT 'domain, foreign key to domain table',
  `keypair_name` varchar(256) NOT NULL COMMENT 'name of the key pair',
  `fingerprint` varchar(128) NOT NULL COMMENT 'fingerprint for the ssh public key',
  `public_key` varchar(5120) NOT NULL COMMENT 'public key of the ssh key pair',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE  `cloud`.`usage_event` (
  `id` bigint unsigned NOT NULL auto_increment,
  `type` varchar(32) NOT NULL,
  `account_id` bigint unsigned NOT NULL,
  `created` datetime NOT NULL,
  `zone_id` bigint unsigned NOT NULL,
  `resource_id` bigint unsigned,
  `resource_name` varchar(255),
  `offering_id` bigint unsigned,
  `template_id` bigint unsigned,
  `size` bigint unsigned,  
  `processed` tinyint NOT NULL default '0',
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_host_vlan_alloc`(
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT,
  `host_id` bigint unsigned COMMENT 'host id',
  `account_id` bigint unsigned COMMENT 'account id',
  `vlan` bigint unsigned COMMENT 'vlan id under account #account_id on host #host_id',
  `ref` int unsigned NOT NULL DEFAULT 0 COMMENT 'reference count',
  PRIMARY KEY(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_tunnel_alloc`(
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT,
  `from` bigint unsigned COMMENT 'from host id',
  `to` bigint unsigned COMMENT 'to host id',
  `in_port` int unsigned COMMENT 'in port on open vswitch',
  PRIMARY KEY(`from`, `to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_tunnel`(
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT,
  `from` bigint unsigned COMMENT 'from host id',
  `to` bigint unsigned COMMENT 'to host id',
  `key` int unsigned default '0' COMMENT 'current gre key can be used',
  PRIMARY KEY(`from`, `to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_tunnel_account`(
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT,
  `from` bigint unsigned COMMENT 'from host id',
  `to` bigint unsigned COMMENT 'to host id',
  `account` bigint unsigned COMMENT 'account',
  `key` int unsigned COMMENT 'gre key',
  `port_name` varchar(32) COMMENT 'in port on open vswitch',
  `state` varchar(16) default 'FAILED' COMMENT 'result of tunnel creatation',
  PRIMARY KEY(`from`, `to`, `account`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `cloud`.`ovs_tunnel_account` (`from`, `to`, `account`, `key`, `port_name`, `state`) VALUES (0, 0, 0, 0, 'lock', 'SUCCESS');

CREATE TABLE `cloud`.`ovs_vlan_mapping_dirty`(
  `id` bigint unsigned NOT NULL UNIQUE AUTO_INCREMENT,
  `account_id` bigint unsigned COMMENT 'account id',
  `dirty` int(1) unsigned NOT NULL DEFAULT 0 COMMENT '1 means vlan mapping of this account was changed',
  PRIMARY KEY(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_vm_flow_log` (
  `id` bigint unsigned UNIQUE NOT NULL AUTO_INCREMENT COMMENT 'id',
  `instance_id` bigint unsigned NOT NULL COMMENT 'vm instance that needs flows to be synced.',
  `created` datetime NOT NULL COMMENT 'time the entry was requested',
  `logsequence` bigint unsigned  COMMENT 'seq number to be sent to agent, uniquely identifies flow update',
  `vm_name` varchar(255) NOT NULL COMMENT 'vm name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`ovs_work` (
  `id` bigint unsigned UNIQUE NOT NULL AUTO_INCREMENT COMMENT 'id',
  `instance_id` bigint unsigned NOT NULL COMMENT 'vm instance that needs rules to be synced.',
  `mgmt_server_id` bigint unsigned COMMENT 'management server that has taken up the work of doing rule sync',
  `created` datetime NOT NULL COMMENT 'time the entry was requested',
  `taken` datetime COMMENT 'time it was taken by the management server',
  `step` varchar(32) NOT NULL COMMENT 'Step in the work',
  `seq_no` bigint unsigned  COMMENT 'seq number to be sent to agent, uniquely identifies ruleset update',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `cloud`.`storage_pool_work` (
  `id` bigint unsigned UNIQUE NOT NULL AUTO_INCREMENT COMMENT 'id',
  `pool_id` bigint unsigned NOT NULL COMMENT 'storage pool associated with the vm',
  `vm_id` bigint unsigned NOT NULL COMMENT 'vm identifier',
  `stopped_for_maintenance` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'this flag denoted whether the vm was stopped during maintenance',
  `started_after_maintenance` tinyint unsigned NOT NULL DEFAULT 0 COMMENT 'this flag denoted whether the vm was started after maintenance',
  `mgmt_server_id` bigint unsigned NOT NULL COMMENT 'management server id',
  PRIMARY KEY (`id`),
 UNIQUE (pool_id,vm_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Insert stuff?;
INSERT INTO `cloud`.`sequence` (name, value) VALUES ('volume_seq', (SELECT max(id) + 1 or 200 from volumes));
INSERT INTO `cloud`.`sequence` (name, value) VALUES ('networks_seq', 200);
