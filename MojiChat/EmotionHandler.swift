//
//  EmotionHandler.swift
//  TestEmotion
//
//  Created by Jake Saferstein on 9/18/16.
//  Copyright © 2016 Meme Moji Masters. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias emoteData = (max: Double, emotion: String)
//typealias emoteCompletionBlock = (emoteData) -> ()

class EmotionHandler {
    
    static let sharedInstance = EmotionHandler()
    private init() { }
    
    var emotArray: [String] = ["anger", "contempt", "disgust", "fear", "happiness", "sadness", "surprise"]
    var maxCoef = 0.0
    var emotion = "neutral"
    
    enum Errors: ErrorType{
        case HTTPError
    }
    
    
    func getEmotion(imageURLs: [String], completion: (String)->() ) {
        
        let emotionGroup = dispatch_group_create()
        
        dispatch_group_enter(emotionGroup)
        
        for imageURL in imageURLs {
            do{
                
                dispatch_group_enter(emotionGroup)
                
                if emotion == "unknown" {
                    emotion = "neutral"
                }
                
                try self.parseJSON(imageURL, completion: { (coef, emot) in
                    
                    
                    if coef < 0 && self.emotion == "neutral" {
                        self.emotion = "unknown"
                        //                        return
                    }
                    else if (coef > self.maxCoef) && (coef >= 0.18) {
                        self.maxCoef = coef
                        self.emotion = emot
                        //                        return
                    }
                    dispatch_group_leave(emotionGroup)
                })
                
                
            } catch {
                if emotion == "neutral" {
                    emotion = "unknown"
                }
                dispatch_group_leave(emotionGroup)
            }
        }
        
        dispatch_group_leave(emotionGroup)
        
        dispatch_group_notify(emotionGroup, dispatch_get_main_queue()) {
            completion(self.emotion)
        }
    }
    
    func takeMax1d(array: [Double]) -> emoteData {
        var currentMax = array[0]
        var curidx = 0
        var maxidx = 0
        var the_emotion = "null"
        for value in array[1..<array.count] {
            curidx = curidx + 1
            if (value > currentMax) {
                currentMax = value
                maxidx = curidx
            }
        }
        let emotionindex = maxidx % 7
        if emotionindex == 0{
            the_emotion = "anger"
        }
        else if emotionindex == 1{
            the_emotion = "anger" //actually contempt
        }
        else if emotionindex == 2{
            the_emotion = "disgust"
        }
        else if emotionindex == 3{
            the_emotion = "fear"
        }
        else if emotionindex == 4{
            the_emotion = "happiness"
        }
        else if emotionindex == 5{
            the_emotion = "sadness"
        }
        else {
            the_emotion = "surprise"
        }
        
        return (currentMax, the_emotion)
    }
    
    func parseJSON(imageURL: String, completion:(Double, String)->()) throws {
        let urlStringEmotion = NSString(format: "https://api.projectoxford.ai/emotion/v1.0/recognize");
        
        let emotionRequest : NSMutableURLRequest = NSMutableURLRequest()
        
        let session = NSURLSession.sharedSession()
        
        //let urlStr = /*"http://static.eharmony.com/dating-advice/wp-content/uploads/images/across-the-pond-uk-and-us-views-on-dating-multiple-people-at-once-large.jpg"*/"http://efdreams.com/data_images/dreams/face/face-03.jpg"
        
        let params = ["url":imageURL]
        emotionRequest.URL = NSURL(string: NSString(format: "%@", urlStringEmotion) as String)
        emotionRequest.HTTPMethod = "POST"
        emotionRequest.timeoutInterval = 30
        emotionRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        emotionRequest.addValue("1fe171edcf9f4a0bbf6724f615e79175", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        let jsonBody = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        emotionRequest.HTTPBody = jsonBody
        let dataTaskEmotion = session.dataTaskWithRequest(emotionRequest){
            (let data: NSData?, let response: NSURLResponse?, let error: NSError?) -> Void in
            // 1: Check HTTP Response for successful GET request
            guard let httpResponse = response as? NSHTTPURLResponse, receivedEmotionData = data else {
                print("error: not a valid http response")
                completion(-1.0, "error: unknown")
                return
            }
            if(httpResponse.statusCode != 200){
                completion(-1.0, "error: unknown")
                return
            }
            
            let json = JSON(data: receivedEmotionData)
            if((json.array)?.count==0){
                completion(-1.0, "error: unknown")
                return
            }
            
            
            var emotVals = [0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            var largestFace = 0;
            var largestFaceArea = 0.0
            
            //finds indexof largest face
            for i in 0..<json.count{
                let width =  json[i]["faceRectangle"]["width"].double!
                let height = json[i]["faceRectangle"]["height"].double!
                if width*height > largestFaceArea {
                    largestFaceArea = width*height
                    largestFace = i
                }
            }
            
            //array of coefs for emotions
            for i in 0..<7{
                let emotion: String = self.emotArray[i]
                emotVals[i] = json[largestFace]["scores"][emotion].double!
            }
            
            //maximum coef in array
            let (coef, emot) = self.takeMax1d(emotVals)
            completion (coef, emot)
        }
        dataTaskEmotion.resume()
        return
    }
    
    
}