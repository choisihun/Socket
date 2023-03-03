//
//  SigninVC.swift
//  connect1on
//
//  Created by 최시훈 on 2022/11/17.
//

import UIKit
import SnapKit
import Then
import Alamofire


class SignInVC: UIViewController {
    let logolb = UILabel().then {
        $0.text = "ALT"
        $0.font = .systemFont(ofSize: 150.0, weight: .medium)
        $0.font.withSize(58)
        $0.textAlignment = .center //가운데 정렬
    }
        let emailTextField = UITextField().then {
            $0.placeholder = "이메일을 입력해주세요"
            $0.font = .systemFont(ofSize: 14.0, weight: .medium)
            $0.autocapitalizationType = .none
            $0.backgroundColor = .secondColor
            $0.layer.cornerRadius = 15
            $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 0.0))
            $0.leftViewMode = .always
        }
        let pwTextField = UITextField().then {
            $0.placeholder = "비밀번호를 입력해주세요"
            $0.font = .systemFont(ofSize: 14.0, weight: .medium)
            $0.autocapitalizationType = .none
            $0.isSecureTextEntry = true
            $0.backgroundColor = .secondColor
            $0.layer.cornerRadius = 15
            $0.leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 0.0))
            $0.leftViewMode = .always
        }
        let logInButton = UIButton().then {
            $0.backgroundColor = .mainColor
            $0.setTitle("로그인", for: .normal)
            $0.layer.cornerRadius = 20
            $0.addTarget(self, action: #selector(TablogInBt), for: .touchUpInside)
        }
        let signUpLabel = UILabel().then {
            $0.text = "계정이 없으시다고요??"
            $0.font = .systemFont(ofSize: 8.0)
            $0.textAlignment = .right
        }
        let signUpButton = UIButton().then {
            $0.setTitle("회원가입", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
            $0.addTarget(self, action: #selector(didTabGoTosignUpButton), for: .touchUpInside)
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setup()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) //키보드 바깟쪽 누르면 키보드 내려가는 코드
    }
}
extension SignInVC {
    @objc func TablogInBt() {
        let id = emailTextField.text!
        let pw = pwTextField.text!
        print(id, pw)
//        AF.request("\(api)/user/login.do",
//                   method: .post,
//                   parameters: [
//                                    "email":id,
//                                    "password":pw
//                   ],
//                   encoding : JSONEncoding.default,
//                   headers: ["Content-Type": "application/json"]
//        )
//        .validate()
//        .responseData { response in
//            switch response.result {
//            case.success:
                let VC = UINavigationController(rootViewController: ChannelVC())
                VC.modalPresentationStyle = .fullScreen
                self.present(VC, animated: true, completion: nil)
//                guard let value = response.value else { return }
//                guard let result = try? JSONDecoder().decode(LoginData.self, from: value) else { return }
//                UserDefaults.standard.set(result.data.token, forKey: "token")
//                print(LoginDatas(token: ""))
//            case.failure(let error):
//                print("통신 오류!\nCode:\(error._code), Message: \(error.errorDescription!)")
//            }
//        }
    }
    @objc func didTabGoTosignUpButton() {
        let VC = SignUpVC()
        present(VC, animated: true, completion: nil)
    }
    func setup() {
        [
            logolb,
            emailTextField,
            pwTextField,
            logInButton,
            signUpLabel,
            signUpButton
        ].forEach{ self.view.addSubview($0)
        }
        logolb.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.bottom.equalTo(logolb.snp.top).offset(100)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalToSuperview().offset(-70)
        }
        emailTextField.snp.makeConstraints {
            $0.top.equalTo(logolb.snp.bottom).offset(50)
            $0.bottom.equalTo(emailTextField.snp.top).offset(50)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalToSuperview().offset(-70)
        }
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(30)
            $0.bottom.equalTo(pwTextField.snp.top).offset(50)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalToSuperview().offset(-70)
        }
        logInButton.snp.makeConstraints {
            $0.top.equalTo(pwTextField.snp.bottom).offset(20)
            $0.bottom.equalTo(pwTextField.snp.bottom).offset(70)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalToSuperview().offset(-70)
        }
        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(logInButton.snp.bottom).offset(-5)
            $0.bottom.equalTo(signUpLabel.snp.top).offset(20)
            $0.left.equalToSuperview().offset(70)
            $0.right.equalTo(signUpLabel.snp.left).offset(200)
        }
        signUpButton.snp.makeConstraints {
            $0.top.equalTo(logInButton.snp.bottom).offset(5)
            $0.bottom.equalTo(signUpButton.snp.top).offset(15)
            $0.left.equalTo(signUpLabel.snp.right).offset(3)
            $0.right.equalToSuperview().offset(-70)
        }
    }
}
//extension SignInVC {
//    func af() {
//        let id = emailTF.text!
//        let pw = pwTF.text!
//        AF.request("\(api)/api/user/signin.do",
//                   method: .post,
//                   parameters: ["email": id,
//                                "password": pw],
//                   encoding : JSONEncoding.default,
//                   headers: ["Content-Type": "application/json"]
//        )
//        .validate()
//        .responseData { response in
//            switch response.result {
//            case.success:
//                let VC = ChannelVC()
//                VC.modalPresentationStyle = .fullScreen
//                self.present(VC, animated: true, completion: nil)
//                guard let value = response.value else { return }
//                guard let result = try? JSONDecoder().decode(LoginData.self, from: value) else { return }
//                UserDefaults.standard.set(result.data.token, forKey: "token")
//            case.failure(let error):
//                print("통신 오류!\nCode:\(error._code), Message: \(error.errorDescription!)")
//            }
//        }
//    }
//}
