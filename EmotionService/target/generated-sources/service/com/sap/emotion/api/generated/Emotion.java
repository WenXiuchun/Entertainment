package com.sap.emotion.api.generated;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonAutoDetect.Visibility;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Generated dto.
 */
@javax.annotation.Generated(value = "hybris", date = "Fri Aug 26 15:49:29 CST 2016")
@XmlRootElement
@JsonAutoDetect(isGetterVisibility = Visibility.NONE, getterVisibility = Visibility.NONE, setterVisibility = Visibility.NONE,
		creatorVisibility = Visibility.NONE, fieldVisibility = Visibility.NONE)
public class Emotion
{

	@com.fasterxml.jackson.annotation.JsonProperty(value="image_url")
	private java.lang.String _imageUrl;
	
	public java.lang.String getImageUrl()
	{
		return _imageUrl;
	}

	public void setImageUrl(final java.lang.String _imageUrl)
	{
		this._imageUrl = _imageUrl;
	}
}
