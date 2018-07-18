package com.sap.emotion.api.generated;

import javax.ws.rs.core.Response;

@javax.ws.rs.Path("/emotion")
public interface EmotionResource
{
	@javax.ws.rs.POST
	@javax.ws.rs.Consumes({"application/json"})
	@javax.ws.rs.Produces({"application/json"})
	Response post(@javax.validation.Valid final Emotion emotion);

}
