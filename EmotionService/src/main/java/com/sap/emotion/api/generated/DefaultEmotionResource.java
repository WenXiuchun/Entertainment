
package com.sap.emotion.api.generated;

import java.net.URI;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;

import javax.inject.Singleton;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.StatusType;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Component;

import ch.qos.logback.core.status.Status;

/**
* Resource class containing the custom logic. Please put your logic here!
*/
@Component("apiEmotionResource")
@Singleton
public class DefaultEmotionResource implements com.sap.emotion.api.generated.EmotionResource {
    
	@javax.ws.rs.core.Context
	private javax.ws.rs.core.UriInfo uriInfo;

	/* POST / */
	@Override
	public Response post(final Emotion emotion) {
	
	    String maxKey;
	    
	    try {
		
		HttpClient httpclient = HttpClients.createDefault();
		
		URIBuilder builder = new URIBuilder("https://api.projectoxford.ai/emotion/v1.0/recognize");

	        URI uri = builder.build();
	        HttpPost request = new HttpPost(uri);
	        request.setHeader("Content-Type", "application/json");
	        request.setHeader("Ocp-Apim-Subscription-Key", "1a1deb05408f4a06abcea69beadab287");

	        String body = "{ \"url\":\"" + emotion.getImageUrl() + "\"}";
	            
	        StringEntity reqEntity = new StringEntity(body);
	        request.setEntity(reqEntity);

	        HttpResponse response = httpclient.execute(request);	
	        
	        String jsonResponse = EntityUtils.toString(response.getEntity(), "UTF-8");
	            
	        JSONParser parser = new JSONParser();
	        Object resultObject = parser.parse(jsonResponse);    

	        JSONArray  jsonResultArray 	= (JSONArray)resultObject;
	        JSONObject jsonResulObject 	= (JSONObject)jsonResultArray.get(0);	            
	        HashMap    scores 		= (HashMap)jsonResulObject.get("scores");

	        Comparator<? super Entry<String, Double>> maxValueComparator = (
	                entry1, entry2) -> entry1.getValue().compareTo(
	                entry2.getValue());

	        Optional<Entry<String, Double>> maxValue = scores.entrySet()
	                .stream().max(maxValueComparator);
	        
	        maxKey = maxValue.get().getKey();
	    
	    } catch (Exception e) {
		
		return Response.status(400).build();
	    
	    } 
		
	    JSONObject resultEmotionJson = new JSONObject();
	    resultEmotionJson.put("emotion", maxKey);
	 	   
	    return Response.ok(resultEmotionJson).build();
	    
	    //return Response.created(uriInfo.getAbsolutePath()).entity("myEntity").build();
	    
	}

}
