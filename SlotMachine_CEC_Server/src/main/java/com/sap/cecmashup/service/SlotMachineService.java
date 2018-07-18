package com.sap.cecmashup.service;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Map;

import javax.annotation.ManagedBean;
import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.sap.cecmashup.client.CecCustomerClient;
import com.sap.cecmashup.client.CecInteractionLogClient;
import com.sap.cecmashup.client.CecPubsubClient;
import com.sap.cecmashup.model.PayLoad;
import com.sap.cecmashup.util.EmailValidater;
import com.sap.cecmashup.util.JsonParser;

import net.logstash.logback.encoder.org.apache.commons.lang.StringUtils;

@ManagedBean
public class SlotMachineService {
	
	protected Logger Log = LoggerFactory.getLogger(SlotMachineService.class);

	@Inject
	private CecPubsubClient pubsubClient;

	@Inject
	private CecCustomerClient customerClient;

	@Inject
	private CecInteractionLogClient interactionLogClient;

	@Inject
	private JsonParser jsonParser;
	
	@Inject
	private EmailValidater emailValidater;

	public void invokeCustomerRegister() throws Exception {
		Map<String, Object> resultMap = pubsubClient.readTopics("ilog-register");
		String customerID = null;
		if (resultMap != null) {
			Log.debug("resultMap:" + resultMap);
			PayLoad payLoad = jsonParser.pubsubResponseParse(resultMap);
			String appleID = payLoad.getAppleID();
			if(StringUtils.isNotEmpty(appleID) && emailValidater.isEmail(appleID)){
				customerID = customerClient.CreateCustomer(appleID);
				Log.debug("Register appleID:" + payLoad.getAppleID() + ";CustomerID:" + customerID);
				Log.debug("======================================================================");
			}
		}
	}

	public void invokeEngagementEmotion() throws Exception {
		Map<String, Object> resultMap = pubsubClient.readTopics("ilog-engagement");
		if (resultMap != null) {
			PayLoad payLoad = jsonParser.pubsubResponseParse(resultMap);
			String customerId = customerClient.getCustomerIdByEmail(payLoad.getAppleID());
			if (null == customerId) {
				customerId = customerClient.CreateCustomer(payLoad.getAppleID());
				Log.debug("Register appleID:" + payLoad.getAppleID() + ";CustomerID:" + customerId);
			}
			if (null != customerId) {
				String interactionLogID = interactionLogClient.createEmotionLogForCustomer(customerId,
						payLoad.getEmotion(), dateFormatSeconds(payLoad.getCreateAt()));
				Log.debug("Record customer's emotion in engagement, customerID:" + customerId + ";emotion:" + payLoad.getEmotion() + ";InteractionLogID:" + interactionLogID);
			}
		}
	}

	public void invokeRecordGameResultLog() throws Exception {
		Map<String, Object> resultMap = pubsubClient.readTopics("ilog-gameresult");
		if (resultMap != null) {
			PayLoad payLoad = jsonParser.pubsubResponseParse(resultMap);
			String customerId = customerClient.getCustomerIdByEmail(payLoad.getAppleID());
			if (null == customerId) {
				customerId = customerClient.CreateCustomer(payLoad.getAppleID());
				Log.debug("Register appleID:" + payLoad.getAppleID() + ";CustomerID:" + customerId);
			}
			
			if (null != customerId) {
				String interactionLogID = interactionLogClient.createGameResultLogForCustomer(customerId, 
			            payLoad.getGameResult(),
			            dateFormatSeconds(payLoad.getCreateAt()));
			    Log.debug("Record customer's game result, customerID:" + customerId + "GameResult:" +  payLoad.getGameResult() +";InteractionLogID:" + interactionLogID);
			}
		}
	}

	public String dateFormatSeconds(Long time) {
		Date date = new Date(time);
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS Z");
		return sdf.format(date);
	}
}
