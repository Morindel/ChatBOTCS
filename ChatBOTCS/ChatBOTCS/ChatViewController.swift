//
//  ChatViewController.swift
//  ChatBOTCS
//
//  Created by Jakub Kołodziej on 28/05/2019.
//  Copyright © 2019 Jakub Kołodziej. All rights reserved.
//

import ApiAI
import JSQMessagesViewController
import UIKit
import Speech


//struct fulfilmet : Decodable{
//    let request :MData
//}
//
//struct MData : Decodable {
//
//}


enum ChatWindowStatus
{
    case minimised
    case maximised
}

class ChatViewController: JSQMessagesViewController {
    
    
    var messages = [JSQMessage]()
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    lazy var botImageView = UIImageView()
    
    var chatWindowStatus : ChatWindowStatus = .maximised
    var botImageTapGesture: UITapGestureRecognizer?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.senderId = "userId"
        self.senderDisplayName = "userName"
        
        SpeechManager.shared.delegate = self

        self.addMicButton()
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
            self.populateWithWelcomeMessage()
        })
        
        self.inputToolbar.contentView.textView.autocorrectionType = .no
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Helper Methods
    func addMicButton()
    {
        let height = self.inputToolbar.contentView.leftBarButtonContainerView.frame.size.height
        let micButton = UIButton(type: .custom)
        micButton.setImage(#imageLiteral(resourceName: "microphone"), for: .normal)
        micButton.frame = CGRect(x: 0, y: 0, width: height, height: height)
        
        self.inputToolbar.contentView.leftBarButtonItemWidth = 25
        self.inputToolbar.contentView.leftBarButtonContainerView.addSubview(micButton)
        self.inputToolbar.contentView.leftBarButtonItem.isHidden = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOfMic(gesture:)))
        micButton.addGestureRecognizer(longPressGesture)
    }
    
    func populateWithWelcomeMessage()
    {
        self.addMessage(withId: "BotId", name: "Bot", text: "Hi I am Timmy")
        self.finishReceivingMessage()
        self.addMessage(withId: "BotId", name: "Bot", text: "I am here to help you get information about weather")
        self.finishReceivingMessage()

    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: Gesture Handler Methods
    @objc func handleLongPressOfMic(gesture:UILongPressGestureRecognizer)
    {
        if gesture.state == .began
        {
            SpeechManager.shared.startRecording()
        }
        else if gesture.state == .ended
        {
            SpeechManager.shared.stopRecording()
            if inputToolbar.contentView.textView.text == "Say something, I'm listening!"
            {
                inputToolbar.contentView.textView.text = ""
            }
        }
    }
    
    
    //MARK: Core Functionality
    func performQuery(senderId:String,name:String,text:String)
    {
        let request = ApiAI.shared().textRequest()
        
        if text.isEmpty {
            return
        }
        
        request?.query = text
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            guard let response = response as? AIResponse else {
                return
            }
        
            if let textResponse = response.result.fulfillment.speech
            {
                SpeechManager.shared.speak(text: textResponse)
                self.addMessage(withId: "BotId", name: "Bot", text: textResponse)
                self.finishReceivingMessage()
            }
        }, failure: { (request, error) in
            if let error = error{
                print(error)
            }
        })
        ApiAI.shared().enqueue(request)
    }
    
    //MARK: JSQMessageViewController Methods
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        addMessage(withId: senderId, name: senderDisplayName!, text: text!)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        performQuery(senderId: senderId, name: senderDisplayName, text: text!)
        
    }
    
    override func didPressAccessoryButton(_ sender: UIButton)
    {
        performQuery(senderId: senderId, name: senderDisplayName, text: "Multimedia")
        
    }
    
    
}

extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId { 
            return outgoingBubbleImageView
        } else { 
            return incomingBubbleImageView
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell else {
            return UICollectionViewCell.init()
        }
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
            cell.avatarImageView.image = UIImage.init(imageLiteralResourceName: "user")
        } else {
            cell.textView?.textColor = UIColor.black
            cell.avatarImageView.image = UIImage.init(imageLiteralResourceName: "robot")
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
}

extension ChatViewController:SpeechManagerDelegate
{
    func didStartedListening(status:Bool)
    {
        if status
        {
            self.inputToolbar.contentView.textView.text = "Say something, I'm listening!"
        }
    }
    
    func didReceiveText(text: String)
    {
        self.inputToolbar.contentView.textView.text = text
        
        if text != "Say something, I'm listening!"
        {
            self.inputToolbar.contentView.rightBarButtonItem.isEnabled = true
        }
    }
}
