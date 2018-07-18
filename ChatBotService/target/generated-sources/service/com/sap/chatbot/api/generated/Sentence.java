package com.sap.chatbot.api.generated;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonAutoDetect.Visibility;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Generated dto.
 */
@javax.annotation.Generated(value = "hybris", date = "Mon Aug 22 11:18:35 CST 2016")
@XmlRootElement
@JsonAutoDetect(isGetterVisibility = Visibility.NONE, getterVisibility = Visibility.NONE, setterVisibility = Visibility.NONE,
		creatorVisibility = Visibility.NONE, fieldVisibility = Visibility.NONE)
public class Sentence
{

	@com.fasterxml.jackson.annotation.JsonProperty(value="sentence")
	private java.lang.String _sentence;
	
	public java.lang.String getSentence()
	{
		return _sentence;
	}

	public void setSentence(final java.lang.String _sentence)
	{
		this._sentence = _sentence;
	}
}
