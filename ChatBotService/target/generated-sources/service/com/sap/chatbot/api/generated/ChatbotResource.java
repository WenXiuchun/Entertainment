package com.sap.chatbot.api.generated;

import javax.ws.rs.core.Response;

@javax.ws.rs.Path("/chatbot")
public interface ChatbotResource
{
	@javax.ws.rs.GET
	@javax.ws.rs.Produces({"application/json"})
	Response get(@javax.validation.constraints.NotNull @javax.ws.rs.QueryParam("sentence") final java.lang.String sentence);

	@javax.ws.rs.POST
	@javax.ws.rs.Consumes({"binary/octet-stream"})
	@javax.ws.rs.Produces({"application/json"})
	Response post();

}
