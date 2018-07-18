package com.sap.cecmashup.api.generated;

/**
 * Generated parameter dto.
 */
@javax.annotation.Generated(value = "hybris", date = "Fri Oct 21 15:56:16 CST 2016")
public class YaasAwareParameters
{
	@javax.validation.constraints.Pattern(regexp="^[a-z][a-z0-9]+$")
	@javax.validation.constraints.Size(min=3,max=16)
	@javax.ws.rs.HeaderParam("hybris-tenant")
	private java.lang.String hybrisTenant;

	@javax.validation.constraints.Pattern(regexp="^[a-z][a-z0-9-]{1,14}[a-z0-9][.][a-z][a-z0-9-]{0,22}[a-z0-9]$")
	@javax.validation.constraints.Size(min=6,max=41)
	@javax.ws.rs.HeaderParam("hybris-client")
	private java.lang.String hybrisClient;

	@javax.ws.rs.HeaderParam("hybris-client-id")
	private java.lang.String hybrisClientId;

	@javax.ws.rs.HeaderParam("hybris-external-path")
	private java.lang.String hybrisExternalPath;

	@javax.ws.rs.HeaderParam("hybris-external-url")
	private java.lang.String hybrisExternalUrl;

	@javax.ws.rs.HeaderParam("hybris-user")
	private java.lang.String hybrisUser;

	@javax.validation.constraints.Pattern(regexp="^([a-zA-Z0-9._=-]{1,128}( [a-zA-Z0-9._=-]{1,128})*)?$")
	@javax.ws.rs.HeaderParam("hybris-scopes")
	private java.lang.String hybrisScopes;

	@javax.ws.rs.HeaderParam("hybris-request-id")
	private java.lang.String hybrisRequestId;

	@javax.validation.constraints.DecimalMin(value="1")
	@javax.ws.rs.DefaultValue("1")	@javax.ws.rs.HeaderParam("hybris-hop")
	private java.lang.Integer hybrisHop;

	@javax.ws.rs.HeaderParam("hybris-org")
	private java.lang.String hybrisOrg;

	@javax.ws.rs.HeaderParam("hybris-target-url")
	private java.lang.String hybrisTargetUrl;

	public java.lang.String getHybrisTenant()
	{
		return hybrisTenant;
	}

	public java.lang.String getHybrisClient()
	{
		return hybrisClient;
	}

	public java.lang.String getHybrisClientId()
	{
		return hybrisClientId;
	}

	public java.lang.String getHybrisExternalPath()
	{
		return hybrisExternalPath;
	}

	public java.lang.String getHybrisExternalUrl()
	{
		return hybrisExternalUrl;
	}

	public java.lang.String getHybrisUser()
	{
		return hybrisUser;
	}

	public java.lang.String getHybrisScopes()
	{
		return hybrisScopes;
	}

	public java.lang.String getHybrisRequestId()
	{
		return hybrisRequestId;
	}

	public java.lang.Integer getHybrisHop()
	{
		return hybrisHop;
	}

	public java.lang.String getHybrisOrg()
	{
		return hybrisOrg;
	}

	public java.lang.String getHybrisTargetUrl()
	{
		return hybrisTargetUrl;
	}

	public void setHybrisTenant(final java.lang.String hybrisTenant)
	{
		this.hybrisTenant = hybrisTenant;
	}

	public void setHybrisClient(final java.lang.String hybrisClient)
	{
		this.hybrisClient = hybrisClient;
	}

	public void setHybrisClientId(final java.lang.String hybrisClientId)
	{
		this.hybrisClientId = hybrisClientId;
	}

	public void setHybrisExternalPath(final java.lang.String hybrisExternalPath)
	{
		this.hybrisExternalPath = hybrisExternalPath;
	}

	public void setHybrisExternalUrl(final java.lang.String hybrisExternalUrl)
	{
		this.hybrisExternalUrl = hybrisExternalUrl;
	}

	public void setHybrisUser(final java.lang.String hybrisUser)
	{
		this.hybrisUser = hybrisUser;
	}

	public void setHybrisScopes(final java.lang.String hybrisScopes)
	{
		this.hybrisScopes = hybrisScopes;
	}

	public void setHybrisRequestId(final java.lang.String hybrisRequestId)
	{
		this.hybrisRequestId = hybrisRequestId;
	}

	public void setHybrisHop(final java.lang.Integer hybrisHop)
	{
		this.hybrisHop = hybrisHop;
	}

	public void setHybrisOrg(final java.lang.String hybrisOrg)
	{
		this.hybrisOrg = hybrisOrg;
	}

	public void setHybrisTargetUrl(final java.lang.String hybrisTargetUrl)
	{
		this.hybrisTargetUrl = hybrisTargetUrl;
	}

}
