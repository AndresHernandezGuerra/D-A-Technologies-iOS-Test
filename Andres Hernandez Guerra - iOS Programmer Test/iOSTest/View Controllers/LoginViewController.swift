//
//  LoginViewController.swift
//  iOSTest
//
//  Created by D & A Technologies on 1/22/18.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    /**
     * =========================================================================================
     * INSTRUCTIONS
     * =========================================================================================
     * 1) Make the UI look like it does in the mock-up.
     *
     * 2) Take username and password input from the user using UITextFields
     *
     * 3) Using the following endpoint, make a request to login
     *    URL: http://dev.datechnologies.co/Tests/scripts/login.php
     *    Parameter One: email
     *    Parameter Two: password
     *
     * 4) A valid email is 'info@datechnologies.co'
     *    A valid password is 'Test123'
     *
     * 5) Calculate how long the API call took in milliseconds
     *
     * 6) If the response is an error display the error in a UIAlertView
     *
     * 7) If the response is successful display the success message AND how long the API call took in milliseconds in a UIAlertView
     *
     * 8) When login is successful, tapping 'OK' in the UIAlertView should bring you back to the main menu.
     **/

    // MARK: - Outlets
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    // MARK: - Properties
    var loginURL = URL(string: "http://dev.datechnologies.co/Tests/scripts/login.php")!
    var dict = [String: String?]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        dict = ["code": "", "message": ""]
        self.navigationItem.backBarButtonItem?.title = " "
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.username.delegate = self
        self.password.delegate = self
        
        // Calling setup functions
        backgroundImage()
        attributeSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func didPressLoginButton(_ sender: Any) {
        var request = URLRequest(url: loginURL)

        // Choosing encoding, header file, and method for the HTTP request
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        // Parameters to be encoded and passed to the API
        let parameters: [String: Any] = [
            "email": username.text!,
            "password": password.text!
        ]
        
        // Encoding of the parameters using percent encoding function defined below
        request.httpBody = parameters.percentEscaped().data(using: .utf8)

        // Saving API call start time
        let startTime = DispatchTime.now()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Checking for fundamental networking error
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            // Checking for http errors
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // NOTE: If desired if-let can be made to guard-let in order to ensure only 200-299 response codes are accepted and processed
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            // If no errors happen, this response is processed
            let responseString = String(data: data, encoding: .utf8)
            
            // Saving API call return time and calculating total time in nanoseconds
            let endTime = DispatchTime.now()
            let nanoSecTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            
            // Dictionary to store response components
            var dictonary:NSDictionary?
            // Decoding the response obtained from "responseString" and assigning it to the dictionary above
            if let data = responseString?.data(using: String.Encoding.utf8) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
                    
                    if let myDictionary = dictonary
                    {
                        // Calling alert function with the needed parameters
                        self.showAlert(title: "\(myDictionary["code"]!)", message: "\(myDictionary["message"]!)", Double(nanoSecTime/1000000))
                    }
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Customizing Textfield Return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // This function allows the user to skip to the next available textfield based on tag number. If it is the last field available to fill, hitting return will call the same action as when pressing the "login" button.
        
        // NOTE: tag numbers are easily assigned in the .xib file
        let nextTag = textField.tag + 1
        
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didPressLoginButton((Any).self)
        }
        return true
    }
    
    // MARK: - Setup Functions
    func backgroundImage() {
        // Assigning background image with aspect fill property and sending to background
        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        imageViewBackground.image = UIImage(named: "img_login")
        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        self.view.addSubview(imageViewBackground)
        self.view.sendSubview(toBack: imageViewBackground)
    }
    
    func attributeSetup() {
        // General property setup for textfields
        username.layer.sublayerTransform = CATransform3DMakeTranslation(24, 0, 0)
        username.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:0.3)
        username.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.37, green:0.38, blue:0.39, alpha:1.0)])
        username.textColor = UIColor(red:0.11, green:0.12, blue:0.12, alpha:1.0)
        
        password.layer.sublayerTransform = CATransform3DMakeTranslation(24, 0, 0)
        password.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:0.3)
        password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red:0.37, green:0.38, blue:0.39, alpha:1.0)])
        password.textColor = UIColor(red:0.11, green:0.12, blue:0.12, alpha:1.0)
    }
    
    // MARK: - Alert
    func showAlert(title: String, message: String, _ time: Double) {
        var finalMessage = message
        var action = UIAlertAction()
        
        // If the login call is successful message displays elapsed time as well and goes back to Main Menu
        if title == "Success" {
            finalMessage = message + "\n API call took \(time) milliseconds"
            action = UIAlertAction(title: "OK", style: .default, handler: { // Action dismisses AlertController when pressed.
                action in
                self.navigationController?.popViewController(animated: true) // When press "OK" button, it also goes back to Main Menu view
            })
        }
        else {
            action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)

        }
        
        // Asynchronous call to create and present alert to make UI responsive and display message correctly
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: finalMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(action)

            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions
extension Dictionary {
    // This function performs percent encoding to the parameters to be passed as httpBody
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    // Function to replace characters with only allowed characters based on internet standars
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
