package com.sap.cecmashup.client;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.ManagedBean;
import javax.inject.Inject;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.Response;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import com.sap.cloud.yaas.servicesdk.authorization.AccessToken;
import com.sap.cloud.yaas.servicesdk.authorization.AuthorizationScope;
import com.sap.cloud.yaas.servicesdk.authorization.DiagnosticContext;
import com.sap.cloud.yaas.servicesdk.authorization.integration.AuthorizedExecutionCallback;
import com.sap.cloud.yaas.servicesdk.authorization.integration.AuthorizedExecutionTemplate;

@ManagedBean
@Component
public class CecPubsubClient {
    private static final String ENTITY_MEDIA_TYPE = "application/json";
    private static final String URL = "https://api.yaas.io/hybris/pubsub/v1";
    
	@Value("${PUBSUB_TENANT}")
	private String TENANT;
	
	@Value("${PUBSUB_CLIENT}")
	private String CLIENT;
    
//    @Inject
//    private AuthorizedExecutionTemplate authorizedExecutionTemplate;
    
    @Autowired
    @Qualifier("authorizedExecutionTemplateForPubsub")
    private AuthorizedExecutionTemplate authorizedExecutionTemplateForPubsub;
    
    private static final String AUTHORIZATION_HEADER = "Authorization";
    
    private Map<String, Object> readBody;
    public CecPubsubClient() {
        readBody = new HashMap<String, Object>();
        readBody.put("numEvents", 1);
        readBody.put("autoCommit", true);
//        readBody.put("autoCommit", false);
    }
    
    public Map<String, Object> readTopics(String eventType) throws Exception{
        String path = "topics/" + CLIENT + "/" + eventType + "/read";
        Response response = postTopics(path, readBody);
        if (200 == response.getStatus()) {
            Map<String, Object> map = response.readEntity(new GenericType<Map<String, Object>>(){});
            return map;
        } 
        return null;
    }
    
    private Response postTopics(String path, Map<String, Object> body) throws Exception{
        return authorizedExecutionTemplateForPubsub.executeAuthorized(
                new AuthorizationScope(TENANT), 
                new DiagnosticContext("", 1),
                new AuthorizedExecutionCallback<Response>() {
                    @Override
                    public Response execute(final AccessToken token) {
                        Response response = ClientBuilder.newBuilder()
                        .build()
                        .target(URL)
                        .path(path)
                        .request()
                        .header(AUTHORIZATION_HEADER, token.toAuthorizationHeaderValue())
                        .post(Entity.entity(body, ENTITY_MEDIA_TYPE));
                        return response;
                    }
              });
    }
}
