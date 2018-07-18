package com.sap.cecmashup.api.generated.util;



import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

/**
 * Generic utility class used for deserialization of oneof constructs.
 */
public final class OneOfDeserializerUtility
{
	private static final Logger LOG = LoggerFactory.getLogger(OneOfDeserializerUtility.class);

	/**
	 * Hidden constructor to avoid creation.
	 */
	private OneOfDeserializerUtility()
	{
		//avoid creation
	}

	/**
	 * Reads the next value from given JSON parser assuring that the value is one of the defined types.
	 *
	 * @param jsonParser     parser to read the value from
	 * @param supportedTypes to one of the types the value will be converted
	 * @return the converted value
	 * @throws IOException in case of problems reading the next value from json parser or if the value is not convertable
	 *                     to any of the types
	 */
	public static Object deserialize(final JsonParser jsonParser, final Class<?>[] supportedTypes) throws IOException
	{
		final ObjectMapper objectMapper = (ObjectMapper) jsonParser.getCodec();
		final JsonNode node = jsonParser.readValueAsTree();
		if (node == null)
		{
			throw new JsonMappingException("Could not find valid mapping for empty JSON value.");
		}

		final String nodeAsString = getNodeAsText(objectMapper, node);
		return readAsPrimitiveIfPossible(node, nodeAsString, Arrays.asList(supportedTypes), objectMapper);
	}

	/**
	 * Tries to interpret the given node as one of possible primitives.
	 * <p/>
	 * <ul>
	 * <li>boolean</li>
	 * <li>integer</li>
	 * <li>number</li>
	 * <li>string</li>
	 * </ul>
	 * <p/>
	 * If it fails to find the matching primitive type then fallbacks to eager default mapping
	 *	{@link #readAsSupportedType(java.util.Collection, com.fasterxml.jackson.databind.ObjectMapper, String)}.
	 */
	private static Object readAsPrimitiveIfPossible(final JsonNode node, final String nodeAsString,
			final Collection<Class<?>> supportedTypes,
			final ObjectMapper
					objectMapper) throws IOException, IllegalArgumentException
	{
		if (node.isDouble() && supportedTypes.contains(Double.class))
		{
			return objectMapper.readValue(nodeAsString, Double.class);
		}
		else if (node.isInt() && supportedTypes.contains(Integer.class))
		{
			return objectMapper.readValue(nodeAsString, Integer.class);
		}
		else if (node.isNumber() && supportedTypes.contains(Number.class))
		{
			return objectMapper.readValue(nodeAsString, Number.class);
		}
		else if (node.isBoolean() && supportedTypes.contains(Boolean.class))
		{
			return objectMapper.readValue(nodeAsString, Boolean.class);
		}
		else if (node.isTextual() && supportedTypes.contains(String.class))
		{
			return objectMapper.readValue(nodeAsString, String.class);
		}
		else
		{
			return readAsSupportedType(supportedTypes, objectMapper, nodeAsString);
		}
	}

	private static Object readAsSupportedType(final Collection<Class<?>> supportedTypes, final ObjectMapper objectMapper,
			final String nodeAsString) throws IOException
	{
		for (final Class<?> tryClass : supportedTypes)
		{
			try
			{
				return objectMapper.readValue(nodeAsString, tryClass);
			}
			catch (final JsonProcessingException e)
			{
				LOG.debug("Failed to read '" + nodeAsString + "' as " + tryClass + ".");
			}
		}
		throw new JsonMappingException("Could not deserialize " + nodeAsString + " as one of "
				+ Arrays.asList(supportedTypes));
	}

	private static String getNodeAsText(final ObjectMapper objectMapper, final JsonNode node) throws JsonProcessingException
	{
		final Object nodeAsObject = objectMapper.treeToValue(node, Object.class);
		return objectMapper.writeValueAsString(nodeAsObject);
	}
}
