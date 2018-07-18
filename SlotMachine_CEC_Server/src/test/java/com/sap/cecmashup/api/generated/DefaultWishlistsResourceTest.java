package com.sap.cecmashup.api.generated;

import javax.inject.Inject;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.glassfish.jersey.server.ResourceConfig;
import org.junit.Assert;
import org.junit.Test;

import com.sap.cecmashup.client.CecCustomerClient;


public final class DefaultWishlistsResourceTest extends com.sap.cecmashup.api.generated.AbstractResourceTest
{
	/**
	 * Server side root resource /wishlists,
	 * evaluated with some default value(s).
	 */
	private static final String ROOT_RESOURCE_PATH = "/wishlists";
	
	@Inject
	private CecCustomerClient customerClient;
	/* get() /wishlists */
	@Test
	public void testGet()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("");

		final Response response = target.request().get();

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.OK.getStatusCode(), response.getStatus());
	}

	/* post(entity) /wishlists */
	@Test
	public void testPostWithWishlist()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("");
		final Wishlist entityBody =
		new Wishlist();
		final javax.ws.rs.client.Entity<Wishlist> entity =
		javax.ws.rs.client.Entity.entity(entityBody,"application/json");

		final Response response = target.request().post(entity);

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.CREATED.getStatusCode(), response.getStatus());
	}

	/* get() /wishlists/wishlistId */
	@Test
	public void testGetByWishlistId()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("/wishlistId");

		final Response response = target.request().get();

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.OK.getStatusCode(), response.getStatus());
	}

	/* put(entity) /wishlists/wishlistId */
	@Test
	public void testPutByWishlistIdWithWishlist()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("/wishlistId");
		final Wishlist entityBody =
		new Wishlist();
		final javax.ws.rs.client.Entity<Wishlist> entity =
		javax.ws.rs.client.Entity.entity(entityBody,"application/json");

		final Response response = target.request().put(entity);

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.OK.getStatusCode(), response.getStatus());
	}

	/* delete() /wishlists/wishlistId */
	@Test
	public void testDeleteByWishlistId()
	{
		final WebTarget target = getRootTarget(ROOT_RESOURCE_PATH).path("/wishlistId");

		final Response response = target.request().delete();

		Assert.assertNotNull("Response must not be null", response);
		Assert.assertEquals("Response does not have expected response code", Status.NO_CONTENT.getStatusCode(), response.getStatus());
	}

	@Test
	public void testCecCustomerClient()
	{
	    
	    //CecCustomerClient customerClient = new CecCustomerClient();
	    try {
	        String id = customerClient.CreateCustomer("nihao@sap.com");
	        String getId = customerClient.getCustomerIdByEmail("nihao@sap.com");
	        Assert.assertEquals(id, getId);
        } catch (Exception e) {
            // TODO: handle exception
            System.out.println(e);
            Assert.fail();
        }
	    
	}
	
	@Override
	protected ResourceConfig configureApplication()
	{
		final ResourceConfig application = new ResourceConfig();
		application.register(DefaultWishlistsResource.class);
		return application;
	}
	
}
