package com.sap.cecmashup.api.generated;

import com.fasterxml.jackson.annotation.JsonAutoDetect;
import com.fasterxml.jackson.annotation.JsonAutoDetect.Visibility;
import javax.xml.bind.annotation.XmlRootElement;

/**
 * Generated dto.
 */
@javax.annotation.Generated(value = "hybris", date = "Fri Oct 21 15:56:16 CST 2016")
@XmlRootElement
@JsonAutoDetect(isGetterVisibility = Visibility.NONE, getterVisibility = Visibility.NONE, setterVisibility = Visibility.NONE,
		creatorVisibility = Visibility.NONE, fieldVisibility = Visibility.NONE)
public class Detail
{

	@com.fasterxml.jackson.annotation.JsonProperty(value="field")
	private java.lang.String _field;

	@com.fasterxml.jackson.annotation.JsonProperty(value="type")
	@javax.validation.constraints.Pattern(regexp="[a-z]+[a-z_]*[a-z]+")
	@javax.validation.constraints.NotNull
	private java.lang.String _type;

	@com.fasterxml.jackson.annotation.JsonProperty(value="message")
	private java.lang.String _message;

	@com.fasterxml.jackson.annotation.JsonProperty(value="moreInfo")
	private java.net.URI _moreInfo;
	
	public java.lang.String getField()
	{
		return _field;
	}
	
	public java.lang.String getType()
	{
		return _type;
	}
	
	public java.lang.String getMessage()
	{
		return _message;
	}
	
	public java.net.URI getMoreInfo()
	{
		return _moreInfo;
	}

	public void setField(final java.lang.String _field)
	{
		this._field = _field;
	}

	public void setType(final java.lang.String _type)
	{
		this._type = _type;
	}

	public void setMessage(final java.lang.String _message)
	{
		this._message = _message;
	}

	public void setMoreInfo(final java.net.URI _moreInfo)
	{
		this._moreInfo = _moreInfo;
	}

}
