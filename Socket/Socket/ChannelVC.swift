//
//  StackViewVC.swift
//
//
//  Created by 최시훈 on 2022/12/07.
//

import UIKit
import Then
import SnapKit
import MessageKit
import Alamofire
import SwiftStomp
class ChannelVC: UIViewController {
    lazy var channelView: UITableView = {
        let view = UITableView()
        view.register(MessageTableViewCell.self, forCellReuseIdentifier: MessageTableViewCell.className)
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    var Messages = [Channel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        view.addSubview(channelView)
        channelView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        Messages = getStackMocks()
    }
}

extension ChannelVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.className, for: indexPath) as! MessageTableViewCell
        cell.nameLabel.text = Messages[indexPath.row].name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = Messages[indexPath.row]
        let viewController = MessageVC(Stack: cell)
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}
