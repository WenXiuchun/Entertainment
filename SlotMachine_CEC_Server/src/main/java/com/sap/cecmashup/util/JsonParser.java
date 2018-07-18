package com.sap.cecmashup.util;

import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

import javax.annotation.ManagedBean;

import com.sap.cecmashup.model.PayLoad;
import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;
import net.sf.json.JSONObject;
import net.sf.json.JSONSerializer;
@ManagedBean
public class JsonParser {
	
	public PayLoad pubsubResponseParse(Map<String, Object> events) {
		String appleID = null;
    	String emotion = null;
    	String gameResult = null;
    	PayLoad payLoad = new PayLoad();
		ArrayList<Object> arrayList = (ArrayList<Object>) events.get("events");
        Map<String, Object> event = (Map<String, Object>) arrayList.get(0);
        long createAt = Long.parseLong(event.get("createdAt").toString());
        payLoad.setCreateAt(createAt);
        String payLoadStr = event.get("payload").toString();
        if(StringUtils.isNotEmpty(payLoadStr)){
        	JSONObject payLoadObj = (JSONObject) JSONSerializer.toJSON(payLoadStr);
        	if(payLoadObj != null){
        		appleID = (String) payLoadObj.get("appleID");
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
		return payLoad;
	}
}
