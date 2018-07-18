package com.sap.chatbot.api.generated;

import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.glassfish.jersey.server.ResourceConfig;
import org.junit.Assert;
import org.junit.Test;


public final class DefaultChatbotResourceTest extends com.sap.chatbot.api.generated.AbstractResourceTest
{
	/**
	 * Server side root resource /chatbot,
	 * evaluated with some default value(s).
	 */
	private static final String ROOT_RESOURCE_PATH = "/chatbot";

	/* get() /chatbot */
	@Test
	public void testGetWithSentence()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("");
		final Sentence entityBody =
		new Sentence();
		entityBody.setSentence("menu");
		final javax.ws.rs.client.Entity<Sentence> entity =
		javax.ws.rs.client.Entity.entity(entityBody,"application/json");
		
		

		final Response response = target.request().get();

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.OK.getStatusCode(), response.getStatus());
	}

	/* post(null) /chatbot */
//	@Test
//	public void testPost()
//	{
//		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("");
//
//		final Response response = target.request().post(null);
//
//		Assert.assertNotNull("Response must not be null", response);
//		Assert.assertEquals("Response does not have expected response code", Status.CREATED.getStatusCode(), response.getStatus());
//	}

	@Override
	protected ResourceConfig configureApplication()
	{
		final ResourceConfig application = new ResourceConfig();
		application.register(DefaultChatbotResource.class);
		return application;
	}
}
