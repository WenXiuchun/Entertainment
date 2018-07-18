
package com.sap.chatbot.api.generated;

import javax.ws.rs.core.Feature;
import javax.ws.rs.core.FeatureContext;

/**
 * JAX RS feature which registers the API resources defined in the RAML.
 */
public class ApiFeature implements Feature
{
	@Override
	public boolean configure(final FeatureContext context)
	{
		context.register(DefaultChatbotResource.class);
		return true;
	}
}
