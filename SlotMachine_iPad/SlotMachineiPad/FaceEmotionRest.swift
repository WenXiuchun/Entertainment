//
//  FaceEmotionRest.swift
//  SlotMachine
//
//  Created by Born, Torsten on 27/04/16.
//  Copyright © 2016 Born, Torsten. All rights reserved.
//

import UIKit

import Foundation

class FaceEmotionRest: NSObject{

    var scores  = [String: Double]()
    
    let emotions: [String] = ["sadness",
                              "anger",
                              "happiness",
                              "fear",
                              "neutral",
                              "contempt",
                              "disgust",
                              "surprise"]

    func getFaceEmotion(_ image: UIImage, emotionReturn: @escaping (String) -> ()) {

        let ms_subscription_key = "1a1deb05408f4a06abcea69beadab287" // 20 request per minute, 30000 request per month
        
        let service     = "https://api.projectoxford.ai/emotion/v1.0/recognize"
        let session     = URLSession.shared
        let request     = NSMutableURLRequest(url: URL(string: service)!)

        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue(ms_subscription_key, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.httpBody = UIImageJPEGRepresentation(image, 0.7)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            do {
            let json:JSON = try JSON(data: data!)
            
            
            let httpResponse = response as? HTTPURLResponse
            
            if (httpResponse!.statusCode == 200) {
                
                for emotion: String in self.emotions {
                    
                    self.scores[emotion] = json[0]["scores"][emotion].doubleValue
                    
                }
                
                emotionReturn( (self.scores as NSDictionary).keysSortedByValue(using: "compare:").last as! String )
            
            } else {
                
                emotionReturn("error")
                
            }
            } catch { }
            
        })
        
        task.resume()
        
    }
        
}
    
