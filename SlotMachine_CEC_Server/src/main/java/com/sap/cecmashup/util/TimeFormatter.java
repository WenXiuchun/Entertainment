package com.sap.cecmashup.util;

import java.text.SimpleDateFormat;
import java.util.Date;

public class TimeFormatter {
	public static void main(String[] args) {
		System.out.println(System.currentTimeMillis());
		Date date = new Date(System.currentTimeMillis());
		String dateStr = toLongDateString(date);
		System.out.println(dateStr);
	}
	
	public static String toLongDateString(Date dt){
        SimpleDateFormat myFmt=new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");        
        return myFmt.format(dt);
    }
}
