package com.sap.cecmashup.client;

import java.security.cert.CertPathValidatorException.Reason;
import java.util.ArrayList;
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
public class CecInteractionLogClient {
	
	@Value("${ENGAGEMENT_TENANT}")
	private String TENANT;
	
    private String INTREATIONLOG = "interactionLog";
    
    private static final String URL = "https://api.yaas.io/hybris/tinteractionlog/v1";
    private static final String ENTITY_MEDIA_TYPE = "application/json";
    
    
//    @Inject
//    private AuthorizedExecutionTemplate authorizedExecutionTemplate;
    
    @Autowired
    @Qualifier("authorizedExecutionTemplateForEngagement")
    private AuthorizedExecutionTemplate authorizedExecutionTemplateForEngagement;
    
    private static final String AUTHORIZATION_HEADER = "Authorization";
    
    private Map<String, Object> initInteractionLog(String customerId, String time) {
        Map<String, Object> map = new HashMap<String, Object>();
        
        Map<String, String> reason = new HashMap<String, String>();
        List<Map<String, String>> reasons = new ArrayList<Map<String, String>>();
        reason.put("interactionReason", "PLAY_GAME");
        reason.put("description", "vegas game");
        reasons.add(reason);
        map.put("interactionReasons", reasons);
        
        map.put("customerId", customerId);
        
        map.put("agentId", "karen@sap.com");
        map.put("agentTitle", "Ms.");
        map.put("agentFirstName", "karen");
        map.put("agentLastName", "ai");
        
        map.put("interactionStartedAt", time);
        map.put("interactionEndedAt", time);
//        map.put("communicationStartedAt", time);
//        map.put("communicationEndedAt", time);
        
        
        return map;
    }
    
    public String createEmotionLogForCustomer(String customerId, String emotion, String time) throws Exception{
        Map<String, Object> map = initInteractionLog(customerId, time);
        
        Map<String, String> emotionObject = new HashMap<String, String>();
        emotionObject.put("objectType", "EMOTION");
        emotionObject.put("objectId", "5551c0ffa86e7c1f624d03fb");
        emotionObject.put("objectName", ": " + emotion);
        
        List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
        objects.add(emotionObject);
        
        map.put("interactionDescription", "The customer's emotion is: " + emotion);
        map.put("relatedObjects", objects);
        
        Response response = postInteractionLog(map);
        if (response.getStatus() == 201) {
            Map<String, String> entity = response.readEntity(new GenericType<Map<String, String>>(){});
            return entity.get("id");
        }
        
        return null;
    }
    
    public String createGameResultLogForCustomer(String customerId, boolean result, String time) throws Exception{
        Map<String, Object> map = initInteractionLog(customerId, time);
        
        Map<String, String> gameResultObject;
        gameResultObject = new HashMap<String, String>();
        gameResultObject.put("objectType", "GAME_RESULT");
        gameResultObject.put("objectId", "5551c0ffa86e7c1f624d03fb");
        if (result) {
            gameResultObject.put("objectName", ": Won");
            map.put("interactionDescription", "The customer won the game!");
        } else {
            gameResultObject.put("objectName", ": Lose");
            map.put("interactionDescription", "The customer lose the game.");
        }
        
        List<Map<String, String>> objects = new ArrayList<Map<String, String>>();
        objects.add(gameResultObject);
        map.put("relatedObjects", objects);
        
        Response response = postInteractionLog(map);
        if (response.getStatus() == 201) {
            Map<String, String> entity = response.readEntity(new GenericType<Map<String, String>>(){});
            return entity.get("id");
        }
        
        return null;
    }
    
    private Response postInteractionLog(Map<String, Object> body) throws Exception{
        return authorizedExecutionTemplateForEngagement.executeAuthorized(
                new AuthorizationScope(TENANT, 
                    Arrays.asList("hybris.interactionlog_manage")), 
                new DiagnosticContext("", 1),
                new AuthorizedExecutionCallback<Response>() {
                    @Override
                    public Response execute(final AccessToken token) {
                        Response response = ClientBuilder.newBuilder()
                        .build()
                        .target(URL)
                        .path(TENANT)
                        .path(INTREATIONLOG)
                        .request()
                        .header(AUTHORIZATION_HEADER, token.toAuthorizationHeaderValue())
                        .post(Entity.entity(body, ENTITY_MEDIA_TYPE));
                        return response;
                    }
              });
    }
}
