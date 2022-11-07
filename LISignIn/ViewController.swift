//
//  ViewController.swift
//  LISignIn
//
//  Created by Gabriel Theodoropoulos on 21/12/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: IBOutlet Properties
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnGetProfileInfo: UIButton!
    @IBOutlet weak var btnOpenProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSignIn.isEnabled = true
        btnGetProfileInfo.isEnabled = false
        btnOpenProfile.isHidden = true
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingAccessToken()
    }
    
    // MARK: IBAction Functions
    @IBAction func getProfileInfo(sender: AnyObject) {
        if let accessToken = UserDefaults.standard.object(forKey: "LIAccessToken") {
            // Specify the URL string that we'll get the profile info from.
            let targetURLString = "https://api.linkedin.com/v1/people/~:(public-profile-url)?format=json"
            
            
            // Initialize a mutable URL request object.
            let request = NSMutableURLRequest(url: NSURL(string: targetURLString)! as URL)
            
            // Indicate that this is a GET request.
            request.httpMethod = "GET"
            
            // Add the access token as an HTTP header field.
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            // Initialize a NSURLSession object.
            let session = URLSession(configuration: URLSessionConfiguration.default)
            
            // Make the request.
            let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
                // Get the HTTP status code of the request.
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200 {
                    // Convert the received JSON data into a dictionary.
                    do {
                        
                        let dataDictionary = try JSONSerialization.jsonObject(with: data! as Data, options: .mutableContainers) as! [String:Any]
                                                
                        let profileURLString = dataDictionary["publicProfileUrl"] as! String
                        
                        DispatchQueue.global(qos: .background).async {
                            // Background Thread
                            DispatchQueue.main.async {
                                // Run UI Updates
                                self.btnOpenProfile.setTitle(profileURLString, for: UIControl.State.normal)
                                self.btnOpenProfile.isHidden = false
                            }
                        }
                    }
                    catch {
                        print("Could not convert JSON data into a dictionary.")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    @IBAction func openProfileInSafari(sender: AnyObject) {
        let profileURL = NSURL(string: btnOpenProfile.title(for: UIControl.State.normal)!)
        UIApplication.shared.openURL(profileURL! as URL)
    }
 
    // MARK: Custom Functions
    func checkForExistingAccessToken() {
        if UserDefaults.standard.object(forKey: "LIAccessToken") != nil {
            btnSignIn.isEnabled = false
            btnGetProfileInfo.isEnabled = true
        }
    }
    
}

