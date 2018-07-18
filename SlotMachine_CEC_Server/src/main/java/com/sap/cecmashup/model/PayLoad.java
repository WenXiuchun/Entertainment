package com.sap.cecmashup.model;

public class PayLoad {
	
	private String appleID;
	
	private String emotion;
	
	private boolean gameResult;
	
	private long createAt;

	public long getCreateAt() {
		return createAt;
	}

	public void setCreateAt(long createAt) {
		this.createAt = createAt;
	}
	
	public String getAppleID() {
		return appleID;
	}

	public void setAppleID(String appleID) {
		this.appleID = appleID;
	}

	public String getEmotion() {
		return emotion;
	}

	public void setEmotion(String emotion) {
		this.emotion = emotion;
	}

	public boolean getGameResult() {
		return gameResult;
	}

	public void setGameResult(boolean gameResult) {
		this.gameResult = gameResult;
	}

	@Override
	public String toString() {
		return "PayLoad [appleID=" + appleID + ", emotion=" + emotion + ", gameResult=" + gameResult + ", createAt="
				+ createAt + "]";
	}

}
