//
//  ViewController.swift
//  ExampleKeyChain
//
//  Created by 황재현 on 5/9/25.
//

import UIKit
import Security
import SnapKit
import Then
import RxSwift
import RxCocoa
import MaterialActivityIndicator

class ViewController: UIViewController {
    
    /// 뷰모델
    let vm = MainVM()
    
    let disposeBag = DisposeBag()
    
    /// 인디케이터
    let indicator = MaterialActivityIndicatorView().then {
        $0.color = .lightGray
        $0.layer.zPosition = 1
    }
    
    /// 타이틀 라벨
    let titleLabel = UILabel().then {
        $0.text = "key값은 access_Token"
        $0.font = $0.font.withSize(16)
    }
    
    /// 텍스트 필드
    let textField = UITextField().then {
        $0.placeholder = "데이터를 입력해주세요."
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.black.cgColor
    }
    
    /// 결과값 라벨
    let resultLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = $0.font.withSize(14)
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    
    
    /// 버튼을 담고있는 스택뷰
    lazy var stackViewBtn = UIStackView(arrangedSubviews: [createBtn, readBtn, deleteBtn]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }
    
    /// 데이터 생성 버튼
    let createBtn = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.black.cgColor
        $0.setTitle("데이터 저장", for: .normal)
        $0.titleLabel?.font = $0.titleLabel?.font.withSize(12)
        $0.setTitleColor(.black, for: .normal)
    }
    
    /// 데이터 불러오는 버튼
    let readBtn = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.black.cgColor
        $0.setTitle("데이터 불러오기", for: .normal)
        $0.titleLabel?.font = $0.titleLabel?.font.withSize(12)
        $0.setTitleColor(.black, for: .normal)
    }
    
    // 데이터 삭제
    let deleteBtn = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.black.cgColor
        $0.setTitle("데이터 삭제", for: .normal)
        $0.titleLabel?.font = $0.titleLabel?.font.withSize(12)
        $0.setTitleColor(.black, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        bindingVM()
    }
    
    
    func configureUI() {
        view.addSubview(indicator)
        
        view.addSubview(titleLabel)
        
        view.addSubview(textField)
        
        view.addSubview(stackViewBtn)
        
        view.addSubview(resultLabel)

        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        stackViewBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(44)
        }
        
        resultLabel.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(stackViewBtn.snp.top).offset(-16)
        }
    }
    
    
    func bindingVM() {
        vm.resultDataEvent.bind(to: resultLabel.rx.text).disposed(by: disposeBag)
        
        vm.indicatorEvent.subscribe { [weak self] flag in
            guard let self = self else { return }
            flag == true ? self.indicator.startAnimating() : self.indicator.stopAnimating()
        }.disposed(by: disposeBag)
        
        createBtn.rx.tap.subscribe { [weak self] tap in
            guard let self = self else { return }
            print("createBtn - tap")
            self.vm.indicatorEvent.accept(true)
            KeyChainHelper.shared.createData(name: "access_Token", data: self.textField.text!, vm: self.vm)
        }.disposed(by: disposeBag)
        
        readBtn.rx.tap.subscribe { [weak self] tap in
            guard let self = self else { return }
            print("readBtn - tap")
            self.vm.indicatorEvent.accept(true)
            if let result = KeyChainHelper.shared.readData(key: "access_Token") {
                print("readBtn - result = \(result)")
                self.vm.indicatorEvent.accept(false)
                self.vm.resultDataEvent.accept(result)
            } else {
                self.vm.indicatorEvent.accept(false)
                self.vm.resultDataEvent.accept("fail to read...")
            }
        }.disposed(by: disposeBag)
        
        deleteBtn.rx.tap.subscribe { [weak self] tap in
            guard let self = self else { return }
            print("deleteBtn - tap")
//            self.deleteData(key: "access_Token")
            KeyChainHelper.shared.deleteData(key: "access_Token", vm: self.vm)
        }.disposed(by: disposeBag)
    }
    
//    // MARK: - name으로 정한 key값에 KeyChain data 생성
//    func createData(name: String, data: String) {
//        /*
//         kSecClassGenericPassword: 일반적인 문자열 비밀정보 (accessToken, refreshToken 사용)
//         */
//        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
//                                     kSecAttrAccount: name,
//                                       kSecValueData: data.data(using: .utf8)!]
//        
//        // MARK: - KeyChain은 Key값에 중복이 생기면, 저장할 수 없기 때문에 먼저 Delete를 해줌
//        SecItemDelete(keychainQuery)
//        
//        // 키 체인 값 저장
//        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
//        if status == errSecSuccess {
//            print("createData success")
//            self.vm.indicatorEvent.accept(false)
//            self.vm.resultDataEvent.accept("createData success")
//        } else {
//            print("createData fail")
//            self.vm.indicatorEvent.accept(false)
//            self.vm.resultDataEvent.accept("createData fail")
//        }
//    }
//    
//    // MARK: - key값에 있는 KeyChain Data 읽기
//    func readData(key: String) -> String? {
//        // kSecAttrAccount: key = key값에 있는 데이터를 찾음 (access_Token) 값을 찾음
//        // kSecReturnData: kCFBooleanTrue as Any = CFData 타입으로 불러오라는 의미
//        // kSecMatchLimit: kSecMatchLimitOne = 중복되는 경우, 하나의 값만 불러오라는 의미
//        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
//                                     kSecAttrAccount: key,
//                                      kSecReturnData: kCFBooleanTrue as Any,
//                                      kSecMatchLimit: kSecMatchLimitOne]
//        
//        var dataTypeRef: AnyObject?
//        let status = SecItemCopyMatching(keychainQuery, &dataTypeRef)
//        
//        if status == errSecSuccess {
//            // 성공
//            if let retrievedData: Data = dataTypeRef as? Data {
//                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
//                return value
//            } else { return nil }
//        } else {
//            // 실패
//            return nil
//        }
//    }
//    
//    func deleteData(key: String) {
//        // kSecAttrAccount: key = key값에 있는 데이터 접근 (key = access_Token) 값을 찾음
//        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
//                                     kSecAttrAccount: key]
//        
//        // 해당 아이템 제거
//        let status = SecItemDelete(keychainQuery)
//        
//        if status == errSecSuccess {
//            print("deleteData success")
//            self.vm.resultDataEvent.accept("deleteData success")
//        } else {
//            print("deleteData fail")
//            self.vm.resultDataEvent.accept("deleteData fail")
//        }
//    }
}

