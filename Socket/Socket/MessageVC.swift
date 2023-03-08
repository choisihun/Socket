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
import Then
import Starscream
import SwiftStomp

class MessageVC: MessagesViewController {
    
    let swiftStomp: SwiftStomp
    
    let url = URL(string: "ws://localhost:8080/myApp/stompEndpoint")!
    
    var stack: Channel
    var sender = Sender(senderId: "asdfasdfdddd", displayName: "sihun")
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
        self.swiftStomp = SwiftStomp(host: url)
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
        connectStomp()
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
        return sender
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
        return isFromCurrentSender(message: message) ? .systemYellow : .systemGray5
    }
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .black
    }
    // 말풍선의 꼬리 모양 방향
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let cornerDirection: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(cornerDirection, .curved)
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
extension MessageVC: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        print("onConncet")
    }
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        print("onDisconnect")
    }
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        print("onMessageReceived")
    }
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        print("onMessageReceived")
    }
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        print("onReceipt")
    }
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: SwiftStomp) {
        print("onError")
    }
    func onSocketEvent(eventName: String, description: String) {
        print("onSocketEvent")
    }
    
    func connectStomp() {ç
        swiftStomp.delegate = self //< Set delegate
        swiftStomp.autoReconnect = true //< Auto reconnect on error or cancel
        swiftStomp.connect() //< Connect
        
    }
    
    func stompMessage() {
        switch self.swiftStomp.connectionStatus {
        case .connecting:
            print("Connecting to the server")
        case .socketConnected:
            print("socketConnected")
        case .fullyConnected:
            print("Both socket and STOMP is connected. Ready for messaging")
        case .socketDisconnected:
            print("Socket is disconnected")
        }
    }
    
    func sendData(_ inputBar: InputBarAccessoryView) {
        do {
            let bodyData: [String:String] = [
                "type":"ENTER",
                "roomId":"34ce07dd-7c66-4d5c-ae77-2544fb35c875",
                "sender":"뭘 봐 이 개복치같은 친구야",
                "message":inputBar.inputTextView.text!
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: bodyData, options: .prettyPrinted)
            
            let stringData = String(data: jsonData, encoding: .utf8)!
            
            let headers = [
                "destination": "토큰"
            ]
            let receiptId = ["tank6210@gmail.com"]
            swiftStomp.subscribe(to: "sub/chat/user/tank6210@gmail.com", mode: .auto)
            swiftStomp.send(body: bodyData, to: "sub/chat/user/", receiptId: "receiptId", headers: headers)
        }
        catch {
            print("asdf")
        }
    }
}


