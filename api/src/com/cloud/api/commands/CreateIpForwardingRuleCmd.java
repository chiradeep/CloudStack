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

package com.cloud.api.commands;

import org.apache.log4j.Logger;

import com.cloud.api.ApiConstants;
import com.cloud.api.BaseAsyncCmd;
import com.cloud.api.BaseAsyncCreateCmd;
import com.cloud.api.BaseCmd;
import com.cloud.api.Implementation;
import com.cloud.api.Parameter;
import com.cloud.api.ServerApiException;
import com.cloud.api.response.FirewallRuleResponse;
import com.cloud.api.response.IpForwardingRuleResponse;
import com.cloud.event.EventTypes;
import com.cloud.exception.InvalidParameterValueException;
import com.cloud.exception.NetworkRuleConflictException;
import com.cloud.network.IpAddress;
import com.cloud.network.rules.FirewallRule;
import com.cloud.network.rules.StaticNatRule;
import com.cloud.user.Account;
import com.cloud.user.UserContext;

@Implementation(description="Creates an ip forwarding rule", responseObject=FirewallRuleResponse.class)
public class CreateIpForwardingRuleCmd extends BaseAsyncCreateCmd implements StaticNatRule {
    public static final Logger s_logger = Logger.getLogger(CreateIpForwardingRuleCmd.class.getName());

    private static final String s_name = "createipforwardingruleresponse";

    /////////////////////////////////////////////////////
    //////////////// API parameters /////////////////////
    /////////////////////////////////////////////////////

    @Parameter(name=ApiConstants.IP_ADDRESS_ID, type=CommandType.LONG, required=true, description="the public IP address id of the forwarding rule, already associated via associateIp")
    private Long ipAddressId;
    
    @Parameter(name=ApiConstants.START_PORT, type=CommandType.INTEGER, required=true, description="the start port for the rule")
    private Integer startPort;

    @Parameter(name=ApiConstants.END_PORT, type=CommandType.INTEGER, description="the end port for the rule")
    private Integer endPort;
    
    @Parameter(name=ApiConstants.PROTOCOL, type=CommandType.STRING, required=true, description="the protocol for the rule. Valid values are TCP or UDP.")
    private String protocol;
    

    /////////////////////////////////////////////////////
    /////////////////// Accessors ///////////////////////
    /////////////////////////////////////////////////////

    public Long getIpAddressId() {
        return ipAddressId;
    }
    
    public int getStartPort() {
        return startPort;
    }
    
    public int getEndPort() {
        return endPort;
    }

    /////////////////////////////////////////////////////
    /////////////// API Implementation///////////////////
    /////////////////////////////////////////////////////

    @Override
    public String getCommandName() {
        return s_name;
    }

    @Override
    public void execute(){ 
        boolean result;
        try {
            UserContext.current().setEventDetails("Rule Id: "+getEntityId());
            result = _rulesService.applyStaticNatRules(ipAddressId, UserContext.current().getCaller());
        } catch (Exception e) {
            s_logger.error("Unable to apply port forwarding rules", e);
            _rulesService.revokeStaticNatRule(getEntityId(), true);
            result = false;
        }
        if (result) {
            FirewallRule rule = _entityMgr.findById(FirewallRule.class, getEntityId());
            StaticNatRule staticNatRule = _rulesService.buildStaticNatRule(rule);
            IpForwardingRuleResponse fwResponse = _responseGenerator.createIpForwardingRuleResponse(staticNatRule);
            fwResponse.setResponseName(getCommandName());
            this.setResponseObject(fwResponse);
        } else {
            throw new ServerApiException(BaseCmd.INTERNAL_ERROR, "Error in creating ip forwarding rule on the domr");
        }
       
    }

	@Override
	public void create() {
		StaticNatRule rule;
        try {
            rule = _rulesService.createStaticNatRule(this);
        } catch (NetworkRuleConflictException e) {
            s_logger.info("Unable to create Static Nat Rule due to " + e.getMessage());
            throw new ServerApiException(BaseCmd.NETWORK_RULE_CONFLICT_ERROR, e.getMessage());
        }
        
        this.setEntityId(rule.getId());
	}

    @Override
    public long getEntityOwnerId() {
        Account account = UserContext.current().getCaller();

        if (account != null) {
            return account.getId();
        }

        return Account.ACCOUNT_ID_SYSTEM; // no account info given, parent this command to SYSTEM so ERROR events are tracked
    }

    @Override
    public String getEventType() {
        return EventTypes.EVENT_NET_RULE_ADD;
    }

    @Override
    public String getEventDescription() {
        IpAddress ip = _networkService.getIp(ipAddressId);
        return  ("Applying an ipforwarding 1:1 NAT rule for Ip: "+ip.getAddress()+" with virtual machine:"+ this.getVirtualMachineId());
    }
    
    private long getVirtualMachineId() {
        Long vmId = _networkService.getIp(ipAddressId).getAssociatedWithVmId();
        
        if (vmId == null) {
            throw new InvalidParameterValueException("Ip address is not associated with any network, unable to create static nat rule");
        }
        return vmId;
    }
    
    @Override
    public String getDestIpAddress(){
        return null;
    }

    @Override
    public long getId() {
        throw new UnsupportedOperationException("Don't call me");
    }

    @Override
    public long getSourceIpAddressId() {
        return ipAddressId;
    }

    @Override
    public int getSourcePortStart() {
        return startPort;
    }

    @Override
    public int getSourcePortEnd() {
        if (endPort == null) {
            return startPort;
        } else {
            return endPort;
        }
    }

    @Override
    public String getProtocol() {
        return protocol;
    }

    @Override
    public FirewallRule.Purpose getPurpose() {
        return FirewallRule.Purpose.StaticNat;
    }

    @Override
    public FirewallRule.State getState() {
        throw new UnsupportedOperationException("Don't call me");
    }

    @Override
    public long getNetworkId() {
        return -1;
    }

    @Override
    public long getDomainId() {
        IpAddress ip = _networkService.getIp(ipAddressId);
        return ip.getDomainId();
    }

    @Override
    public long getAccountId() {
        IpAddress ip = _networkService.getIp(ipAddressId);
        return ip.getAccountId();
    }
    
    @Override
    public String getXid() {
        // FIXME: We should allow for end user to specify Xid.
        return null;
    }
    
    @Override
    public String getSyncObjType() {
        return BaseAsyncCmd.networkSyncObject;
    }

    @Override
    public Long getSyncObjId() {
        return getIp().getAssociatedWithNetworkId();
    }

    private IpAddress getIp() {
        IpAddress ip = _networkService.getIp(ipAddressId);
        if (ip == null) {
            throw new InvalidParameterValueException("Unable to find ip address by id " + ipAddressId);
        }
        return ip;
    }
}
