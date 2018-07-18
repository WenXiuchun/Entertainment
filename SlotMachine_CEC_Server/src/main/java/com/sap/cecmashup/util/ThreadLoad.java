package com.sap.cecmashup.util;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;


import com.sap.cecmashup.service.SlotMachineService;

public class ThreadLoad implements InitializingBean {

	protected Logger Log = LoggerFactory.getLogger(ThreadLoad.class);

	@Inject
	private SlotMachineService slotMachineService;
	
	@Override
	public void afterPropertiesSet() {
		Thread readRegisterThread = new Thread(new Runnable() {
			@Override
			public void run() {
				while (true) {
					try {
						slotMachineService.invokeCustomerRegister();
						Thread.sleep(1500);
					} catch (Exception e) {
						Log.error("Failed to invoke CustomerRegister",e);
					}
				}
			}
		});
		Thread readEngagementThread = new Thread(new Runnable() {
			@Override
			public void run() {
				while (true) {
					try {
						slotMachineService.invokeEngagementEmotion();
						Thread.sleep(1500);
					} catch (Exception e) {
						Log.error("Failed to invoke invokeEngagementEmotion",e);
					}
				}
			}
		});
		Thread readGameResultThread = new Thread(new Runnable() {
			@Override
			public void run() {
				while (true) {
					try {
						slotMachineService.invokeRecordGameResultLog();
						Thread.sleep(1500);
					} catch (Exception e) {
						Log.error("Failed to invoke invokeRecordGameResultLog",e);
					}
				}
			}
		});
		readRegisterThread.start();
		readEngagementThread.start();
		readGameResultThread.start();
	}
}
