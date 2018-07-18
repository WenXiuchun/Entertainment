package com.sap.cecmashup.client;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.ManagedBean;
import javax.inject.Inject;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.Response;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.sap.cecmashup.service.SlotMachineService;
import com.sap.cloud.yaas.servicesdk.authorization.AccessToken;
import com.sap.cloud.yaas.servicesdk.authorization.AuthorizationScope;
import com.sap.cloud.yaas.servicesdk.authorization.DiagnosticContext;
import com.sap.cloud.yaas.servicesdk.authorization.integration.AuthorizedExecutionCallback;
import com.sap.cloud.yaas.servicesdk.authorization.integration.AuthorizedExecutionTemplate;

@ManagedBean
@Component
public class CecCustomerClient {
    
	protected Logger Log = LoggerFactory.getLogger(CecCustomerClient.class);
	
    @Value("${ENGAGEMENT_TENANT}")
	private String TENANT;
    
    private String CUSTOMER = "customers";
    
    private static final String URL = "https://api.yaas.io/hybris/tcecentercustomer/v1";
    private static final String ENTITY_MEDIA_TYPE = "application/json";
    
//    @Inject
//    private AuthorizedExecutionTemplate authorizedExecutionTemplate;
    
    @Autowired
    @Qualifier("authorizedExecutionTemplateForEngagement")
    private AuthorizedExecutionTemplate authorizedExecutionTemplateForEngagement;
    
    private static final String AUTHORIZATION_HEADER = "Authorization";

    public String CreateCustomer(final String email)throws Exception {
        Map<String, String> body = new HashMap<String, String>();
        body.put("contactEmail", email);
        Response response = postCecCustomer(body);
        Log.debug("Create customer's Response:" + response);
        if(response.getStatus() == 201) {
            Map<String, String> map = response.readEntity(new GenericType<Map<String, String>>(){});
            return map.get("id");
        }
        
        if (response.getStatus() == 409) {
            Map<String, String> map = response.readEntity(new GenericType<Map<String, String>>(){});
            if(map.get("type").equals("conflict_resource")) {
                return getCustomerIdByEmail(email);
            }
        }
        
        return null;
    }
    
    public String getCustomerIdByEmail(final String email) throws Exception {
        String query = "contactEmail:"+ email;
        Response response = queryCecCustomer(query);
        
        List<Map<String, Object>> map = response.readEntity(new GenericType<List<Map<String, Object>>>(){});
        if (null != map && map.size() != 0) {
            return map.get(0).get("customerNumber").toString();
        } else {
            return null;
        }
        

    }
    
    private Response postCecCustomer(final Map<String, String> body) throws Exception{
        return authorizedExecutionTemplateForEngagement.executeAuthorized(
                new AuthorizationScope(TENANT, 
                    Arrays.asList("hybris.cecentercustomer_manage")), 
                new DiagnosticContext("", 1),
                new AuthorizedExecutionCallback<Response>() {
                    @Override
                    public Response execute(final AccessToken token) {
                        Response response = ClientBuilder.newBuilder()
                        .build()
                        .target(URL)
                        .path(TENANT)
                        .path(CUSTOMER)
                        .request()
                        .header(AUTHORIZATION_HEADER, token.toAuthorizationHeaderValue())
                        .post(Entity.entity(body, ENTITY_MEDIA_TYPE));
                        return response;
                    }
              });
    }
    
    private Response queryCecCustomer(final String query) throws Exception{
        return authorizedExecutionTemplateForEngagement.executeAuthorized(
            new AuthorizationScope(TENANT, 
                    Arrays.asList("hybris.cecentercustomer_view")), 
                new DiagnosticContext("", 1),
                new AuthorizedExecutionCallback<Response>() {
                    @Override
                    public Response execute(final AccessToken token) {
                        Response response = ClientBuilder.newBuilder()
                        .build()
                        .target(URL)
                        .path(TENANT)
                        .path(CUSTOMER)
                        .queryParam("q", query)
                        .request()
                        .header(AUTHORIZATION_HEADER, token.toAuthorizationHeaderValue())
                        .accept(ENTITY_MEDIA_TYPE)
                        .get();
                        return response;
                    }
                });
    }
}
