//
//  MassageVC.swift
//  connect1on
//
//  Created by 최시훈 on 2022/11/24.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Photos
import StompClientLib
import SocketRocket

class MessageVC: MessagesViewController {
    var stompClient = StompClientLib()
    let url = URL(string: "ws://10.80.161.156:8080/ws")!
    let subscribe: String = "/sub/chat/user/cksgur0612@dgsw.hs.kr"
    
    var stack: Channel
    var sender = Sender(senderId: "최시훈", displayName: "sihun")
    var messages: [Message] = []
    private var isSendingPhoto = false {
        didSet {
            messageInputBar.leftStackViewItems.forEach { item in
                guard let item = item as? InputBarButtonItem else {
                    return
                }
                item.isEnabled = !self.isSendingPhoto
            }
        }
    }
    
    init(Stack: Channel) {
        self.stack = Stack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //     MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
        setup()
        setupMessageInputBar()
        removeOutgoingMessageAvatars()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stompClient = StompClientLib()
        
        connectStomp()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stompClient.autoDisconnect(time: 3)
    }
    
    deinit {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    private func setupDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    private func setup() {
        title = stack.name
        navigationController?.navigationBar.prefersLargeTitles = false
        //                messages = getMessagesMock()
    }
    private func setupMessageInputBar() {
        messageInputBar.inputTextView.tintColor = .mainColor
        messageInputBar.sendButton.setTitleColor(.mainColor, for: .normal)
        messageInputBar.sendButton.setTitle("보내버려", for: .normal)
        messageInputBar.inputTextView.placeholder = "Aa"
        messageInputBar.backgroundView.backgroundColor = UIColor(red: 240.0/255, green: 240.0/255, blue: 240.0/255, alpha: 1)
    }
    
    private func removeOutgoingMessageAvatars() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else { return }
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.setMessageOutgoingAvatarSize(.zero)
        let outgoingLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15))
        layout.setMessageOutgoingMessageTopLabelAlignment(outgoingLabelAlignment)
    }
    
    private func insertNewMessage(_ message: Message) {
        messages.append(message)
        messages.sort()
        messagesCollectionView.reloadData()
    }
}
// 오류 고침
extension MessageVC: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return Sender(senderId: "최시훈", displayName: "sihun")
    }
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1),
                                                             .foregroundColor: UIColor(white: 0.3, alpha: 1)])
    }
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        // 날짜 레이블에 날짜 정보를 표시하기 위한 코드
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString)
    }
}
extension MessageVC: MessagesLayoutDelegate {
    // 아래 여백
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    // 말풍선 위 이름 나오는 곳의 height
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
}
// 상대방이 보낸 메시지, 내가 보낸 메시지를 구분하여 색상과 모양 지정
extension MessageVC: MessagesDisplayDelegate {
    // 말풍선의 배경 색상
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .systemYellow : .systemOrange
    }
    // 말풍선의 text 색상
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .black
    }
    // 말풍선의 꼬리 모양 방향
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if  sender.senderId == sender.senderId {
            return .bubbleTail(.bottomLeft, .curved)
        } else {
            return .bubbleTail(.bottomRight, .curved)
        }
    }
}

extension MessageVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(content: text)
        insertNewMessage(message)
        inputBar.inputTextView.text.removeAll()
        sendData(InputBarAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44)))
    }
}
extension MessageVC: StompClientLibDelegate {
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("ReceiveMessage")
        if let jsonData = stringBody!.data(using: .utf8) {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                if let jsonDict = jsonObject as? [String: Any] {
                    if let messageText = jsonDict["message"] as? String {
                        let message = Message(content: messageText)
                        insertNewMessage(message)
                        print("성공")
                    }
                }
            } catch {
                print("Failed to parse JSON data: \(error.localizedDescription)")
            }
        }
    }
    func stompClientDidDisconnect(client: StompClientLib!) {
        print("stompClientDidDisconnect")
        stompClient.unsubscribe(destination: subscribe)
    }
    func stompClientDidConnect(client: StompClientLib!) {
        print("stompClientDidConnect")
        stompClient.subscribe(destination: subscribe)
        
        print("⭐️")
    }
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("serverDidSendReceipt")
        
    }
    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        stompClient.reconnect(request: NSURLRequest(url: url as URL) , delegate: self as StompClientLibDelegate, time: 4.0)
        print("🚫serverDidSendError🚫")
    }
    func serverDidSendPing() {
        print("sercerDidSendPing")
    }
    func connectStomp() {
        let headers = [
            "Authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJja3NndXIwNjEyQGRnc3cuaHMua3IiLCJhdXRoIjoiUk9MRV9HVUVTVCIsImV4cCI6MTY3ODcwOTM3MH0.aQgtMVce83q1jRllAQqjfgT-32fErxFjrGiNju-IpVU"
        ]
        
        DispatchQueue.global(qos: .background).async { [self] in
            
            stompClient.openSocketWithURLRequest(request: NSURLRequest(url: url as URL) , delegate: self, connectionHeaders: headers)
        }
        print("✨")
    }
    
    
    func onConnect() {
        do {
            let bodyData: [String:Any] = [
                "type":"ENTER",
                "roomId":"747ba655-b3ae-4d66-9877-0c62aed31925",
                "sender":"뭘 봐 이 개복치같은 친구야",
                "message":""
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
            
            let stringData = String(data: jsonData, encoding: .utf8)!
            
            let headers = [
                "Authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJja3NndXIwNjEyQGRnc3cuaHMua3IiLCJhdXRoIjoiUk9MRV9HVUVTVCIsImV4cCI6MTY3ODcwOTM3MH0.aQgtMVce83q1jRllAQqjfgT-32fErxFjrGiNju-IpVU"
            ]
            
            stompClient.sendMessage(message: stringData, toDestination: "/pub/chat/user/", withHeaders: headers, withReceipt: nil)
            print("⭐️")
        }
        
        catch {
            print("😡")
        }
        
    }
    
    
    
    
    func sendData(_ inputBar: InputBarAccessoryView) {
        do {
            let bodyData: [String:Any] = [
                "type":"TALK",
                "roomId":"747ba655-b3ae-4d66-9877-0c62aed31925",
                "sender":"뭘 봐 이 개복치같은 친구야",
                "message":inputBar.inputTextView.text!
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
            
            let stringData = String(data: jsonData, encoding: .utf8)!
            
            let headers = ["Authorization":"Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJja3NndXIwNjEyQGRnc3cuaHMua3IiLCJhdXRoIjoiUk9MRV9HVUVTVCxST0xFX1VTRVIsUk9MRV9BRE1JTiIsImV4cCI6MTY3ODYxNTUwOH0.mNEP7yu-U8Pownft1APL0cijgPe2jmBpHeLvq7PZe-U"]
            
            let receiptId: String = "cksgur0612@dgsw.hs.kr"
            stompClient.sendMessage(message: stringData, toDestination: "/pub/chat/user/", withHeaders: headers, withReceipt: nil)
            print("😁")
        }
        catch {
            print("😡")
        }
    }
    
}

