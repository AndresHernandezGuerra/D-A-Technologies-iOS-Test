//
//  ChatViewController.swift
//  iOSTest
//
//  Created by D & A Technologies on 1/22/18.
//  Copyright © 2018 D & A Technologies. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /**
     * =========================================================================================
     * INSTRUCTIONS
     * =========================================================================================
     * 1) Make the UI look like it does in the mock-up.
     *
     * 2) Using the following endpoint, fetch chat data
     *    URL: http://dev.datechnologies.co/Tests/scripts/chat_log.php
     *
     * 3) Parse the chat data using 'Message' model
     *
     **/
    
    // MARK: - Properties
    private var client: ChatClient?
    private var messages: [Message]?
    let chatURL = URL(string: "http://dev.datechnologies.co/Tests/scripts/chat_log.php")!
    
    // MARK: - Outlets
    @IBOutlet weak var chatTable: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        chatTable.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        
        messages = [Message]()
        configureTable(tableView: chatTable)
        title = "Chat"
        
        // NOTE : Test data has been removed, pulling data from server to populate view now
        
        chatTable.reloadData()
        retrieveChatLog()
    }
    
    // MARK: - Private
    private func configureTable(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatTableViewCell", bundle: nil), forCellReuseIdentifier: "ChatTableViewCell")
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - API Calling Function
    func retrieveChatLog() {
        URLSession.shared.dataTask(with: chatURL, completionHandler: {(data, response, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                let msgData = json["data"] as? [[String: String]] ?? []
                
                // For loop to iterate through the array of dictionaries created, each element contains all necessary data to populate Message model
                for each in msgData {
                    self.messages?.append(Message(dictionary: each))
                }

                // Asynchronously reload of data in order to not block UI
                DispatchQueue.main.async {
                    self.chatTable.reloadData()
                }
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ChatTableViewCell? = nil
        if cell == nil {
            let nibs = Bundle.main.loadNibNamed("ChatTableViewCell", owner: self, options: nil)
            cell = nibs?[0] as? ChatTableViewCell
        }
        cell?.setCellData(message: messages![indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages!.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    // MARK: - String Size Calculator Function
    func getStringSizeForFont(font: UIFont, myText: String) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = (myText as NSString).size(withAttributes: fontAttributes)
        
        return size
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Call to function outlined above, needs to specify the font used and weight, as well as the text that populkates each cell
        var stringSizeAsText: CGSize = getStringSizeForFont(font: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular), myText: self.messages![indexPath.row].text)
        
        // Label width and height are hardcoded here because of specifications given accounting for insets
        // It is also important to leave them hardcoded because the autolayout is the same in all devicves
        let labelWidth: CGFloat = 185.0
        let originalLabelHeight: CGFloat = 18.0
        
        // Text width that surpases this limit creates layout issues because of the word wrapping property making as many words fit per line, so it needs to be adjusted
        if stringSizeAsText.width > 830 {
            stringSizeAsText.width = 830
        }
        
        // Based on the label width and "stringSizeAsText" variable, we can calculate the ammount of lines needed for any specific string
        var labelLines: CGFloat = CGFloat((Float(stringSizeAsText.width/labelWidth)).rounded())
        
        // Since 0 is not an option, but text can be very short, the minimum lines number is 1
        if labelLines < 1.0 {
            labelLines = 1.0
        }
        // Assigning dynamic height for table cells according to the formula below
        // NOTE: the -1.50 constant is due to specific spacing created from insets
        let height: CGFloat = tableView.rowHeight + originalLabelHeight + CGFloat(labelLines*stringSizeAsText.height) - 1.50
        
        return height
    }
    
}
