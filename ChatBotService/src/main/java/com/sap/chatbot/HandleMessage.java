package com.sap.chatbot;

import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.imageio.ImageIO;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

import com.drew.imaging.ImageMetadataReader;
import com.drew.imaging.ImageProcessingException;
import com.drew.metadata.Directory;
import com.drew.metadata.Metadata;
import com.drew.metadata.MetadataException;
import com.drew.metadata.exif.ExifIFD0Directory;
import com.drew.metadata.jpeg.JpegDirectory;

public class HandleMessage {

	private static String convertStreamToString(InputStream is) {


		BufferedReader reader = new BufferedReader(new InputStreamReader(is));

		StringBuilder sb = new StringBuilder();

		String line = null;
		try {
			while ((line = reader.readLine()) != null) {
				sb.append(line + "\n");
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				is.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		return sb.toString();

	}

	public static List<String> JSONParser(String response, String value) {

		List<String> dummyResponse = new ArrayList<String>();
		List<String> intents = new ArrayList<String>();
		ArrayList<List<String>> allEntities = new ArrayList<List<String>>();
		//get the most likely intent
		Matcher totalMatcher = Pattern.compile("(?m)\"intent\":\\s\"\\w+\",\\s*\"score\":\\s\\d\\.\\d+")
				.matcher(response);
		while (totalMatcher.find()) {
			intents.add(totalMatcher.group());
		}
		//get all entities in the input
		Matcher wholeEntityMatcher = Pattern.compile("(?ms)entities.*(\"entity\".*?\\d\\.\\d+)").matcher(response);
		String wholeEntity = "";
		while (wholeEntityMatcher.find()) {
			wholeEntity = wholeEntityMatcher.group();
		}

		if(intents.size()==0){
			dummyResponse.add("0.0");
			return dummyResponse;	
		}

		if (value.equals("score")) {
			Matcher scoreMatcher = Pattern.compile("\\d\\.\\d+").matcher(intents.get(0));
			List<String> score = new ArrayList<>();
			while (scoreMatcher.find()) {
				score.add(scoreMatcher.group());
			}
			return score;
		} else if (value.equals("intent")) {
			Matcher intentMatcher = Pattern.compile(":\\s\"(\\w+)\"").matcher(intents.get(0));
			List<String> intent = new ArrayList<>();
			if (intentMatcher.find()) {
				intent.add(intentMatcher.group(1));
			}
			return intent;
		} else if (value.equals("entity")) {
			List<String> entities = new ArrayList<>();
			Matcher wholeEntityEntityMatcher = Pattern.compile("\"entity\":\\s\"(.*)\"").matcher(wholeEntity);
			while (wholeEntityEntityMatcher.find()) {
				entities.add(wholeEntityEntityMatcher.group(1));
			}
			allEntities.add(entities);
			return entities;
		} else if (value.equals("entityType")) {
			Matcher wholeEntityTypeMatcher = Pattern.compile("\"type\":\\s\"(.*)\"").matcher(wholeEntity);
			List<String> wholeEntityType = new ArrayList<>();
			while (wholeEntityTypeMatcher.find()) {
				wholeEntityType.add(wholeEntityTypeMatcher.group(1));
			}
			allEntities.add(wholeEntityType);
			return wholeEntityType;
		} else if (value.equals("entityScore")) {
			Matcher wholeEntityScoreMatcher = Pattern.compile("\\d\\.\\d+").matcher(wholeEntity);
			List<String> wholeEntityScore = new ArrayList<>();
			if (wholeEntityScoreMatcher.find()) {
				wholeEntityScore.add(wholeEntityScoreMatcher.group());
			}
			allEntities.add(wholeEntityScore);
			return wholeEntityScore;
		} else if (value.equals("index")) {
			Matcher wholeEntityIndexMatcher = Pattern.compile("\"startIndex\":\\s(\\d+)").matcher(wholeEntity);
			List<String> wholeEntityIndex = new ArrayList<>();
			while (wholeEntityIndexMatcher.find()) {
				wholeEntityIndex.add(wholeEntityIndexMatcher.group(1));
			}
			allEntities.add(wholeEntityIndex);
			return wholeEntityIndex;

		}
		dummyResponse.add("0.0");
		return dummyResponse;
	}
	public static class ImageInformation {
		public final int orientation;
		public final int width;
		public final int height;

		public ImageInformation(int orientation, int width, int height) {
			this.orientation = orientation;
			this.width = width;
			this.height = height;
		}

		public String toString() {
			return String.format("%dx%d,%d", this.width, this.height, this.orientation);
		}
	}

	public static ImageInformation readImageInformation(InputStream inputStream)  throws IOException, MetadataException, ImageProcessingException {
		Metadata metadata = ImageMetadataReader.readMetadata(inputStream);
		int orientation = 1;
		if(metadata.containsDirectoryOfType(ExifIFD0Directory.class)){
			Directory directory = metadata.getFirstDirectoryOfType(ExifIFD0Directory.class);
			try {
				orientation = directory.getInt(ExifIFD0Directory.TAG_ORIENTATION);
			} catch (MetadataException me) {
				System.out.println(me.getMessage());
			}
		}
		int width;
		int height;
		if(metadata.containsDirectoryOfType(JpegDirectory.class)){
			JpegDirectory jpegDirectory = metadata.getFirstDirectoryOfType(JpegDirectory.class);

			width = jpegDirectory.getImageWidth();
			height = jpegDirectory.getImageHeight();
		}
		else{
			width=-1;
			height=-1;
		}

		return new ImageInformation(orientation, width, height);
	}

	public static AffineTransform getExifTransformation(ImageInformation info) {

		AffineTransform t = new AffineTransform();

		switch (info.orientation) {
		case 1:
			break;
		case 2: // Flip X
			t.scale(-1.0, 1.0);
			t.translate(-info.width, 0);
			break;
		case 3: // PI rotation 
			t.translate(info.width, info.height);
			t.rotate(Math.PI);
			break;
		case 4: // Flip Y
			t.scale(1.0, -1.0);
			t.translate(0, -info.height);
			break;
		case 5: // - PI/2 and Flip X
			t.rotate(-Math.PI / 2);
			t.scale(-1.0, 1.0);
			break;
		case 6: // -PI/2 and -width
			t.translate(info.height, 0);
			t.rotate(Math.PI / 2);
			break;
		case 7: // PI/2 and Flip
			t.scale(-1.0, 1.0);
			t.translate(-info.height, 0);
			t.translate(0, info.width);
			t.rotate(  3 * Math.PI / 2);
			break;
		case 8: // PI / 2
			t.translate(0, info.width);
			t.rotate(  3 * Math.PI / 2);
			break;
		}

		return t;
	}

	public static BufferedImage transformImage(BufferedImage image, AffineTransform transform) throws Exception {

		AffineTransformOp op = new AffineTransformOp(transform, AffineTransformOp.TYPE_BICUBIC);

		BufferedImage destinationImage = op.createCompatibleDestImage(image, (image.getType() == BufferedImage.TYPE_BYTE_GRAY) ? image.getColorModel() : null );
		Graphics2D g = destinationImage.createGraphics();
		g.setBackground(Color.WHITE);
		g.clearRect(0, 0, destinationImage.getWidth(), destinationImage.getHeight());

		destinationImage = op.filter(image, destinationImage);
		return destinationImage;
	}

	public String handlePicture(InputStream fileContent){

		try {
			BufferedInputStream bis = new BufferedInputStream(fileContent);
			ByteArrayOutputStream baosInput = new ByteArrayOutputStream();
			org.apache.commons.io.IOUtils.copy(bis, baosInput);
			byte[] bytes = baosInput.toByteArray();

			ByteArrayInputStream bais = new ByteArrayInputStream(bytes);

			BufferedImage bi = ImageIO.read(bais);
			bais.reset();

			ImageInformation info = readImageInformation(bais);
			if(info.height==-1){
				return "Error: The picture must be .jpg or .jpeg";
			}
			AffineTransform trans = getExifTransformation(info);

			BufferedImage image = transformImage(bi, trans);

			BufferedImage dstImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);
			dstImage.getGraphics().drawImage(
					image, 0, 0, image.getWidth(), image.getHeight(), null);

			//		        File outputfiletest = new File("C:\\Users\\D065234\\Pictures\\test.jpg");
			//		        ImageIO.write(dstImage, "jpg", outputfiletest);

			//		         It's an image (only BMP, GIF, JPG and PNG are recognized).
			//		        File outputfile = new File("C:\\Users\\D065234\\Pictures\\saved.jpg");
			//		        ImageIO.write(bi, "jpg", outputfile);

			ByteArrayOutputStream baos = new ByteArrayOutputStream();
			ImageIO.write( dstImage, "jpg", baos );
			baos.flush();
			byte[] imageInByte = baos.toByteArray();

			HttpClient httpclient = HttpClients.createDefault();

			//HttpHost proxy = new HttpHost("proxy.wdf.sap.corp", 8080);

			//	            RequestConfig config = RequestConfig.custom()
			//	                .setProxy(proxy)
			//	                .build();

			try
			{
				URIBuilder builder = new URIBuilder("https://api.projectoxford.ai/emotion/v1.0/recognize");

				URI uri = builder.build();
				HttpPost httppost = new HttpPost(uri);
				httppost.setHeader("Content-Type", "application/octet-stream");
				httppost.setHeader("ocp-apim-subscription-key", "1a1deb05408f4a06abcea69beadab287");
				// httppost.setConfig(config);


				//		            HttpEntity httpEntity = MultipartEntityBuilder.create()
				//		            	    .addBinaryBody("file", imageInByte)
				//		            	    .build();
				HttpEntity httpEntity2 = new ByteArrayEntity(imageInByte);

				httppost.setEntity(httpEntity2);

				HttpResponse response = httpclient.execute(httppost);

				HttpEntity resEntity = response.getEntity();

				if (resEntity.getContentLength()!=2){

					String jsonResponse = EntityUtils.toString(response.getEntity(), "UTF-8");
					System.out.println(jsonResponse);

					if (jsonResponse.contains("error")){
						return "error";
					}



					JSONParser parser = new JSONParser();
					Object resultObject = parser.parse(jsonResponse);


					JSONArray  jsonResultArray 	= (JSONArray)resultObject;
					JSONObject jsonResulObject 	= (JSONObject)jsonResultArray.get(0);	            
					HashMap    scores 		= (HashMap)jsonResulObject.get("scores");

					Comparator<? super Entry<String, Double>> maxValueComparator = (
							entry1, entry2) -> entry1.getValue().compareTo(
									entry2.getValue());

							Optional<Entry<String, Double>> maxValue = scores.entrySet()
									.stream().max(maxValueComparator);

							String maxKey = maxValue.get().getKey();

							String returnString="";
							switch(maxKey){

							case "happiness": returnString="Nice to see that you enjoy our game";
							break;
							case "sadness": returnString="Unlucky at cards, lucky in love";
							break;
							case "anger": returnString="Why you have to be mad? It's only game";
							break;
							default: returnString="Do you want something to drink?";
							break;
							}
							//return ("DEBUG:"+maxKey+" -- "+returnString);
							return maxKey;

				}
				else return "No face detected";



				//anger,contempt,disgust,fear,happiness,neutral,sadness,surprise



			}
			catch (Exception e)
			{
				return(e.toString());
			}


		} catch (Exception e) {
			// It's not an image.
			return (e.toString());
		}
		//return ("fail");
	}

	boolean confirmed = false;
	boolean ordered = false;
	String lastIntent = "";
	Map<String,Integer> orderList = new HashMap<String,Integer>();
	String[] menu = {"salad","steak","chicken","coke","beer","wine","water","sprite"};
	Map<String,Integer> prizeList = createPrizeList();


	public String handler(String input) {
		URL url;
		try {

			String strippedInput = input.replace(" ", "%20");
			// get URL content
			// System.setProperty("java.net.useSystemProxies", "false");
			String a = "https://api.projectoxford.ai/luis/v1/application?id=d4f0c9b2-098b-455f-8641-38e54764691e&subscription-key=7f66eebd6ea84296a86659bf1d18ab17&q="
					+ URLEncoder.encode(input, "UTF-8");
			url = new URL(a);
			URLConnection conn = url.openConnection();

			// open the stream and put it into BufferedReader
			String result = convertStreamToString(conn.getInputStream());
			Double score = Double.parseDouble(JSONParser(result, "score").get(0));
			String intent = JSONParser(result, "intent").get(0);
			List<String> entity = new ArrayList<>();
			List<String> entityType = new ArrayList<>();
			List<String> entityIndex = new ArrayList<>();
			List<Integer> entityIndexInt = new ArrayList<>();
			List<String> menuItems = new ArrayList<>();
			menuItems=Arrays.asList(menu);
			Random random = new Random();
			int time = random.nextInt((30 - 10) + 1) + 10;

			if (score < 0.5 && !confirmed) {
				String statement="";
				switch (intent) {
				case "Order":
					lastIntent = intent;
					statement="I'm not sure if you wanted to order something, could you please confirm it?";
					break;
				default:
					statement="I didn't understand what you meant or we are not offering this service, " 
							+ "please retype/rephrase your input or type in help to see the available services";
					break;
				}
				return statement;

			}
			if (intent.equals("Confirmation")) {
				confirmed = true;


			}

			else if (intent.equals("Order") || (lastIntent.equals("Order") && confirmed)) {

				try {
					entity = JSONParser(result, "entity");
					entityType = JSONParser(result, "entityType");
					entityIndex = JSONParser(result, "index");
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					return (e1.getMessage());
				}
				// parse <String> List to <Integer> list
				for (String s : entityIndex)
					entityIndexInt.add(Integer.valueOf(s));
				//sort list for searching
				Collections.sort(entityIndexInt);
				int amount = 1;
				String specification = "";
				confirmed = false;
				boolean specificationBefore=false;
				boolean specificationAfter=false;
				for (int i = 0; i < entityType.size(); i++) {
					if (entityType.get(i).equals("food") || entityType.get(i).equals("drink")) {
						int index = Integer.parseInt(entityIndex.get(i));
						int sortedIndex = entityIndexInt.indexOf(index);
						//check if there are any specifications or amounts before the drink/food but stop if you find another drink/food
						for (int z = sortedIndex - 1; z >= 0; z--) {
							String smallerEntity = entityType
									.get(entityIndex.indexOf(entityIndexInt.get(z).toString()));
							if (smallerEntity.equals("food") || smallerEntity.equals("drink")) {
								break;
							} else if (smallerEntity.equals("specification")) {
								specification = entity.get(entityIndex.indexOf(entityIndexInt.get(z).toString())) + " ";
								specificationBefore=true;
							} else if (smallerEntity.equals("amount")) {
								try {
									amount = Integer.parseInt(
											entity.get(entityIndex.indexOf(entityIndexInt.get(z).toString())));
								} catch (NumberFormatException e) {
									amount = inNumerals(
											entity.get(entityIndex.indexOf(entityIndexInt.get(z).toString())));
								}

							}
						}
						//if there is a specification directly behind the food/drink override the other specification
						if (sortedIndex + 1 < entityIndexInt.size()
								&& entityType.get(entityIndex.indexOf(entityIndexInt.get(sortedIndex + 1).toString()))
								.equals("specification")) {
							specification = entity
									.get(entityIndex.indexOf(entityIndexInt.get(sortedIndex + 1).toString()));
							specificationAfter=true;
						}

						if(!menuItems.contains(entity.get(i))&&entityType.get(i).equals("food")){
							Random rand = new Random();
							int randomNum = rand.nextInt((3 - 1) + 1) + 1;
							String invalidMenuMessage="";
							switch (randomNum) {
							case 1:
								invalidMenuMessage = "Unfortunately "+entity.get(i)+" is/are empty, do you want something else?" ;
								break;
							case 2:
								invalidMenuMessage = "Sorry we are not serving "+entity.get(i)+", do you want something else?";
								break;
							case 3:
								invalidMenuMessage = "Sorry "+entity.get(i)+" is not on the menue anymore, do you want something else?";
								break;
							default:
								invalidMenuMessage = "Sorry that is not possible, please refer to the menu";
							}
							return invalidMenuMessage;
						}

						String entry;
						if(specificationAfter)entry = (entity.get(i)+" "+specification).trim();						
						else entry = (specification+entity.get(i)).trim();						

						if(orderList.containsKey(entry)) orderList.put(entry, orderList.get(entry)+amount);
						else orderList.put(entry, amount);

						amount=1;
						specification="";
					}
				}
				//set that a order came in
				ordered = true;
				if (orderList.isEmpty()) {
					return ("Sorry I didn't understand your order or it was empty, try to change your input");
				}

				String returnOrder ="";
				int returnPrize =0;
				for(String key : orderList.keySet()){
					returnOrder =returnOrder + orderList.get(key).toString()+" "+key+" ";
					if(orderList.size()>1)returnOrder=returnOrder+"and ";

					returnPrize=returnPrize+orderList.get(key)*prizeList.get(key);
				}
				if(orderList.size()>1)returnOrder=returnOrder.substring(0, returnOrder.length()-4);



				return ("Your order of " + returnOrder + "costs " + returnPrize + " Euros" + "\nWould you like anything else or is that everything?");

			} else if (intent.equals("Menu")) {
				ordered = false;
				confirmed = false;
				return ("To drink we are offering Water, Coke, Sprite, Beer and Wine"
						+ "\nAnd to eat the todays menu is Steak, Chicken or a Salad");

			}

			else if (intent.equals("Refusal")) {
				ordered = false;
				confirmed = false;
				orderList.clear();
				return ("I'm sorry if I didn't understand you right, do you want something else then?");

			}

			else if (intent.equals("Help")) {
				ordered = false;
				confirmed = false;
				return ("Currently we're only offering the possibility to get the menu and order food and drinks, "
						+ "\n to see what's on the menu just type menu and to order something just type what you normally would say to a waiter. "
						+ "\n You can speak to me like a normal person and I try to understand what you mean.");

			}
			else if (intent.equals("Smalltalk")){
				return("I'm fine thanks for asking and you?");
			}

			else if (intent.equals("SmalltalkAnswer")){
				return("Good to hear :) \n can I help you with something else?");
			}

			else if (intent.equals("None")) {
				ordered = false;
				confirmed = false;
				return ("Sorry I didn't understand you or we are not offering this service, "
						+ "currently we're only offering the possibility to get the menu and order food and drinks");

			} else if (intent.equals("Greeting")) {
				return ("Hey nice to meet you I'm Karen and i can help you with ordering food, do you want to see the menu or do you already know what you want?");

			} else if (intent.equals("PositiveReaction")) {
				return ("You're welcome");
			}

			else if(intent.equals("DeleteItem")){
				try {
					entity = JSONParser(result, "entity");
					entityType = JSONParser(result, "entityType");
					entityIndex = JSONParser(result, "index");
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					return (e1.getMessage());
				}
				// parse <String> List to <Integer> list
				for (String s : entityIndex)
					entityIndexInt.add(Integer.valueOf(s));
				//sort list for searching
				Collections.sort(entityIndexInt);
				int amount = 1;
				for (int i = 0; i < entityType.size(); i++) {
					if (entityType.get(i).equals("food") || entityType.get(i).equals("drink")) {
						String entityToDelete = entity.get(i);

						for(String key : orderList.keySet()){
							if(key.contains(entityToDelete)){
								orderList.remove(key);
								break;
							}
						}
					}
				}


				String returnOrder ="";
				int returnPrize =0;
				for(String key : orderList.keySet()){
					returnOrder =returnOrder + orderList.get(key).toString()+" "+key+" ";
					if(orderList.size()>1)returnOrder=returnOrder+"and ";

					returnPrize=returnPrize+orderList.get(key)*prizeList.get(key);
				}
				if(orderList.size()>1)returnOrder=returnOrder.substring(0, returnOrder.length()-4);

				if (orderList.isEmpty())returnOrder= "nothing ";

				return ("Your updated order consists of " + returnOrder + "and costs " + returnPrize + " Euros" + "\nWould you like anything else or is that everything?");
			}

			else if (intent.equals("Recommendation")){
				return ("I'm new to this job so I can't really recommend you something sorry");
			}

			else if (intent.equals("DeleteOrder")){
				ordered = false;
				confirmed = false;
				orderList.clear();
				return("Your order has been deleted, do you want to start over or do you want to see the menu again?");
			}

			else if(intent.equals("OrderInformation")){

				String returnOrder ="";
				int returnPrize =0;
				for(String key : orderList.keySet()){
					returnOrder =returnOrder + orderList.get(key).toString()+" "+key+" ";
					if(orderList.size()>1)returnOrder=returnOrder+"and ";

					returnPrize=returnPrize+orderList.get(key)*prizeList.get(key);
				}
				if(orderList.size()>1)returnOrder=returnOrder.substring(0, returnOrder.length()-4);

				String returnString="";
				if(confirmed)returnString="Your order has been received and still will take "+time+" minutes";
				else if (orderList.isEmpty())returnString="Your order is currently empty, do you want to see the menu or do you want to order something?";
				else returnString = "Your updated order consists of " + returnOrder + "and costs " + returnPrize + " Euros";

				return returnString;

			}

			else if(intent.equals("PrizeInformation")){
				try {
					entity = JSONParser(result, "entity");
					entityType = JSONParser(result, "entityType");
				} catch (Exception e1) {
					// TODO Auto-generated catch block
					return (e1.getMessage());
				}
				for (int i = 0; i < entityType.size(); i++) {
					if (entityType.get(i).equals("food") || entityType.get(i).equals("drink")) {
						return(entity.get(i) +" costs "+prizeList.get(entity.get(i)).toString()+" Euros");

					}
				}

			}

			if (ordered && confirmed) {
				ordered = false;
				confirmed= false;
				orderList.clear();
				return ("Your order has been taken and will take approximately "+time +" minutes");

			}

		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

		return ("Sorry there have been some problems with the service, try to change your input");
	}

	public static Map<String, Integer> createPrizeList(){

		Map <String,Integer>prizeList= new HashMap<String,Integer>();

		prizeList.put("salad", 8);
		prizeList.put("steak", 13);
		prizeList.put("chicken", 10);
		prizeList.put("coke", 2);
		prizeList.put("beer", 3);
		prizeList.put("wine", 4);
		prizeList.put("water", 1);
		prizeList.put("sprite", 3);


		return prizeList;
	}

	//convert "one" to 1
	public int inNumerals(String inwords) {
		int wordnum = 0;
		String[] arrinwords = inwords.split(" ");
		int arrinwordsLength = arrinwords.length;
		if (inwords.equals("zero")) {
			return 0;
		}
		/*
		 * if(inwords.contains("thousand")) { int indexofthousand =
		 * inwords.indexOf("thousand"); //System.out.println(indexofthousand);
		 * String beforethousand = inwords.substring(0,indexofthousand);
		 * //System.out.println(beforethousand); String[] arrbeforethousand =
		 * beforethousand.split(" "); int arrbeforethousandLength =
		 * arrbeforethousand.length;
		 * //System.out.println(arrbeforethousandLength);
		 * if(arrbeforethousandLength==2) { wordnum = wordnum +
		 * 1000*(wordtonum(arrbeforethousand[0]) +
		 * wordtonum(arrbeforethousand[1])); //System.out.println(wordnum); }
		 * if(arrbeforethousandLength==1) { wordnum = wordnum +
		 * 1000*(wordtonum(arrbeforethousand[0]));
		 * //System.out.println(wordnum); }
		 * 
		 * } if(inwords.contains("hundred")) { int indexofhundred =
		 * inwords.indexOf("hundred"); //System.out.println(indexofhundred);
		 * String beforehundred = inwords.substring(0,indexofhundred);
		 * 
		 * //System.out.println(beforehundred); String[] arrbeforehundred =
		 * beforehundred.split(" "); int arrbeforehundredLength =
		 * arrbeforehundred.length; wordnum = wordnum +
		 * 100*(wordtonum(arrbeforehundred[arrbeforehundredLength-1])); String
		 * afterhundred = inwords.substring(indexofhundred+8);//7 for 7 char of
		 * hundred and 1 space //System.out.println(afterhundred); String[]
		 * arrafterhundred = afterhundred.split(" "); int arrafterhundredLength
		 * = arrafterhundred.length; if(arrafterhundredLength==1) { wordnum =
		 * wordnum + (wordtonum(arrafterhundred[0])); }
		 * if(arrafterhundredLength==2) { wordnum = wordnum +
		 * (wordtonum(arrafterhundred[1]) + wordtonum(arrafterhundred[0])); }
		 * //System.out.println(wordnum);
		 * 
		 * }
		 */
		if (!inwords.contains("thousand") && !inwords.contains("hundred")) {
			if (arrinwordsLength == 1) {
				wordnum = wordnum + (wordtonum(arrinwords[0]));
			}
			if (arrinwordsLength == 2) {
				wordnum = wordnum + (wordtonum(arrinwords[1]) + wordtonum(arrinwords[0]));
			}
			// System.out.println(wordnum);
		}

		return wordnum;
	}

	public int wordtonum(String word) {
		int num = 0;
		switch (word) {
		case "one":
			num = 1;
			break;
		case "two":
			num = 2;
			break;
		case "three":
			num = 3;
			break;
		case "four":
			num = 4;
			break;
		case "five":
			num = 5;
			break;
		case "six":
			num = 6;
			break;
		case "seven":
			num = 7;
			break;
		case "eight":
			num = 8;
			break;
		case "nine":
			num = 9;
			break;
		case "ten":
			num = 10;
			break;
		case "eleven":
			num = 11;
			break;
		case "twelve":
			num = 12;
			break;
		case "thirteen":
			num = 13;
			break;
		case "fourteen":
			num = 14;
			break;
		case "fifteen":
			num = 15;
			break;
		case "sixteen":
			num = 16;
			break;
		case "seventeen":
			num = 17;
			break;
		case "eighteen":
			num = 18;
			break;
		case "nineteen":
			num = 19;
			break;
		case "twenty":
			num = 20;
			break;
		case "thirty":
			num = 30;
			break;
		case "forty":
			num = 40;
			break;
		case "fifty":
			num = 50;
			break;
		case "sixty":
			num = 60;
			break;
		case "seventy":
			num = 70;
			break;
		case "eighty":
			num = 80;
			break;
		case "ninety":
			num = 90;
			break;
		case "hundred":
			num = 100;
			break;
		case "thousand":
			num = 1000;
			break;
			/*
			 * default: num = "Invalid month"; break;
			 */
		}
		return num;
	}
}
