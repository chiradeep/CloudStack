package com.cloud.api.commands;

import org.apache.log4j.Logger;

import com.cloud.api.ApiConstants;
import com.cloud.api.BaseCmd;
import com.cloud.api.Implementation;
import com.cloud.api.Parameter;
import com.cloud.api.ServerApiException;
import com.cloud.api.response.SuccessResponse;
import com.cloud.exception.ResourceInUseException;
import com.cloud.network.security.SecurityGroup;
import com.cloud.user.Account;

@Implementation(description="Deletes security group", responseObject=SuccessResponse.class)
public class DeleteSecurityGroupCmd extends BaseCmd {
    public static final Logger s_logger = Logger.getLogger(DeleteSecurityGroupCmd.class.getName());
    private static final String s_name = "deletesecuritygroupresponse";

    /////////////////////////////////////////////////////
    //////////////// API parameters /////////////////////
    /////////////////////////////////////////////////////

    @Parameter(name=ApiConstants.ACCOUNT, type=CommandType.STRING, description="the account of the security group. Must be specified with domain ID")
    private String accountName;

    @Parameter(name=ApiConstants.DOMAIN_ID, type=CommandType.LONG, description="the domain ID of account owning the security group")
    private Long domainId;

    @Parameter(name=ApiConstants.ID, type=CommandType.LONG, required=true, description="The ID of the security group")
    private Long id;


    /////////////////////////////////////////////////////
    /////////////////// Accessors ///////////////////////
    /////////////////////////////////////////////////////

    public String getAccountName() {
        return accountName;
    }

    public Long getDomainId() {
        return domainId;
    }

    public Long getId() {
        return id;
    }



    /////////////////////////////////////////////////////
    /////////////// API Implementation///////////////////
    /////////////////////////////////////////////////////

    @Override
    public String getCommandName() {
        return s_name;
    }
    
    @Override
    public long getEntityOwnerId() {
        SecurityGroup group = _entityMgr.findById(SecurityGroup.class, getId());
        if (group != null) {
            return group.getAccountId();
        }

        return Account.ACCOUNT_ID_SYSTEM; // no account info given, parent this command to SYSTEM so ERROR events are tracked
    }
	
    @Override
    public void execute(){
        try{
            boolean result = _securityGroupService.deleteSecurityGroup(this);
            if (result) {
                SuccessResponse response = new SuccessResponse(getCommandName());
                this.setResponseObject(response);
            } else {
                throw new ServerApiException(BaseCmd.INTERNAL_ERROR, "Failed to delete security group");
            }
        } catch (ResourceInUseException ex) {
            s_logger.warn("Exception: ", ex);
            throw new ServerApiException(BaseCmd.RESOURCE_IN_USE_ERROR, ex.getMessage());
        }
    }
}
