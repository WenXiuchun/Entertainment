
package com.sap.cecmashup.api.generated;

import java.util.ArrayList;
import java.util.Map;

import javax.inject.Inject;
import javax.inject.Singleton;
import javax.ws.rs.core.Response;

import org.springframework.stereotype.Component;

import com.sap.cecmashup.client.CecCustomerClient;
import com.sap.cecmashup.client.CecInteractionLogClient;
import com.sap.cecmashup.client.CecPubsubClient;
import com.sap.cecmashup.model.PayLoad;
import com.sap.cecmashup.service.SlotMachineService;

import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;

/**
* Resource class containing the custom logic. Please put your logic here!
 * @param <E>
*/
@Component("apiWishlistsResource")
@Singleton
public class DefaultWishlistsResource<E> implements com.sap.cecmashup.api.generated.WishlistsResource
{
	@javax.ws.rs.core.Context
	private javax.ws.rs.core.UriInfo uriInfo;
	
	@Inject
    private CecCustomerClient customerClient;
	
	@Inject
	private CecInteractionLogClient logClient;
	
	@Inject
	private CecPubsubClient cecClient;
	@Inject
	private SlotMachineService slotService;
	/* GET / */
	@Override
	public Response get(final YaasAwareParameters yaasAware)
	{
		// place some logic here
	    
	    try {
	    	String appleID = null;
	    	String emotion = null;
	    	String gameResult = null;
	    	String[] payLoadList;
	    	PayLoad payLoad = new PayLoad();
//	        String email = "nihao@sap.com";
//	        String id = customerClient.CreateCustomer(email);
//	        String getId = customerClient.getCustomerIdByEmail("abc@qq.com");
//	        
//	        System.out.println(id);
//	        System.out.println(getId);
//	        String logId = logClient.createInteractionLogWithCustomer(id, "this is first log of talking to karen", "2016-07-19T14:10:20.000+0000");
//	        System.out.println(logId);
	        Map<String, Object> events = cecClient.readTopics("ilog-register");
	        ArrayList<Object> arrayList = (ArrayList<Object>) events.get("events");
	        Map<String, Object> event = (Map<String, Object>) arrayList.get(0);
	        long createAt = Long.parseLong(event.get("createdAt").toString());
	        System.out.println(slotService.dateFormatSeconds(createAt));
	        payLoad.setCreateAt(createAt);
	        String payLoadStr = event.get("payload").toString();
	        if(StringUtils.isNotEmpty(payLoadStr)){
	        	JSONObject payLoadObj = (JSONObject) JSONSerializer.toJSON(payLoadStr);
	        	if(payLoadObj != null){
	        		appleID = (String) payLoadObj.get("appleId");
	        		emotion = (String) payLoadObj.get("emotion");
	        		gameResult = (String) payLoadObj.get("gameresult");
	        		if(appleID != null){
	        			payLoad.setAppleID(appleID);
	        		}
	        		if(emotion != null){
	        			payLoad.setEmotion(emotion);
	        		}
	        		if(gameResult != null){
	        			payLoad.setGameResult(Boolean.parseBoolean(gameResult));
	        		}
	        	}
	        }
	        System.out.println(payLoad);
	        
	    } catch (Exception e) {
            System.out.println(e);
            // TODO: handle exception
        }
	    
	   
		return Response.ok()
			.entity(new java.util.ArrayList<Wishlist>()).build();
	}

	/* POST / */
	@Override
	public Response post(final YaasAwareParameters yaasAware, final Wishlist wishlist)
	{
		// place some logic here
		return Response.created(uriInfo.getAbsolutePath())
			.build();
	}

	/* GET /{wishlistId} */
	@Override
	public Response getByWishlistId(final YaasAwareParameters yaasAware, final java.lang.String wishlistId)
	{
		// place some logic here
		return Response.ok()
			.entity(new Wishlist()).build();
	}

	/* PUT /{wishlistId} */
	@Override
	public Response putByWishlistId(final YaasAwareParameters yaasAware, final java.lang.String wishlistId, final Wishlist wishlist)
	{
		// place some logic here
		return Response.ok()
			.build();
	}

	/* DELETE /{wishlistId} */
	@Override
	public Response deleteByWishlistId(final YaasAwareParameters yaasAware, final java.lang.String wishlistId)
	{
		// place some logic here
		return Response.noContent()
			.build();
	}

}
