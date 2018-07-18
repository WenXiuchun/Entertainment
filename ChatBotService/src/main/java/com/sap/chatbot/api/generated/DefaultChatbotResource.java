
package com.sap.chatbot.api.generated;

import java.io.IOException;
import java.io.InputStream;

import javax.inject.Singleton;
import javax.servlet.http.HttpServletRequest;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

import org.apache.http.entity.InputStreamEntity;
import org.springframework.stereotype.Component;

import com.sap.chatbot.HandleMessage;
import com.sun.research.ws.wadl.Request;

/**
* Resource class containing the custom logic. Please put your logic here!
*/
@Component("apiChatbotResource")
@Singleton
public class DefaultChatbotResource implements com.sap.chatbot.api.generated.ChatbotResource
{
	@javax.ws.rs.core.Context
	private javax.ws.rs.core.UriInfo uriInfo;
	@javax.ws.rs.core.Context
    private HttpServletRequest request;
	
	public InputStream getInputStream(HttpServletRequest request) throws IOException{
		InputStream input=request.getInputStream();
		return input;
	}
	
	HandleMessage handleMessage = new HandleMessage();

	/* GET / */
	@Override
	public Response get(final java.lang.String sentence)
	{
		// place some logic here
		return Response.ok()
			.entity(handleMessage.handler(sentence)).build();
	}

	/* POST / */
	@Override
	public Response post()
	{
		// place some logic here
		try {
			return Response.created(uriInfo.getAbsolutePath())
				.entity(handleMessage.handlePicture(getInputStream(request))).build();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			return(Response.serverError().build());
		}
	}

}
