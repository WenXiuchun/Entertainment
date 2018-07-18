package com.sap.emotion.api.generated;

import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.glassfish.jersey.server.ResourceConfig;
import org.junit.Assert;
import org.junit.Test;


public final class DefaultEmotionResourceTest extends com.sap.emotion.api.generated.AbstractResourceTest
{
	/**
	 * Server side root resource /emotion,
	 * evaluated with some default value(s).
	 */
	private static final String ROOT_RESOURCE_PATH = "/emotion";

	/* post(entity) /emotion */
	@Test
	public void testPostWithEmotion()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("");
		final Emotion entityBody =
		new Emotion();
		final javax.ws.rs.client.Entity<Emotion> entity =
		javax.ws.rs.client.Entity.entity(entityBody,"application/json");

		final Response response = target.request().post(entity);

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.CREATED.getStatusCode(), response.getStatus());
	}

	@Override
	protected ResourceConfig configureApplication()
	{
		final ResourceConfig application = new ResourceConfig();
		application.register(DefaultEmotionResource.class);
		return application;
	}
}
