//
//  KeyChainHelper.swift
//  ExampleKeyChain
//
//  Created by 황재현 on 5/9/25.
//

import Foundation
import Security
import RxSwift


// 키체인 헬퍼
final class KeyChainHelper {
    /// 싱글톤
    static let shared = KeyChainHelper()
    
    // MARK: - name으로 정한 key값에 KeyChain data 생성
    func createData(name: String, data: String, vm: MainVM) {
        /*
         kSecClassGenericPassword: 일반적인 문자열 비밀정보 (accessToken, refreshToken 사용)
         */
        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrAccount: name,
                                       kSecValueData: data.data(using: .utf8)!]
        
        // MARK: - KeyChain은 Key값에 중복이 생기면, 저장할 수 없기 때문에 먼저 Delete를 해줌
        SecItemDelete(keychainQuery)
        
        // 키 체인 값 저장
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        if status == errSecSuccess {
            print("createData success")
            vm.indicatorEvent.accept(false)
            vm.resultDataEvent.accept("createData success")
        } else {
            print("createData fail")
            vm.indicatorEvent.accept(false)
            vm.resultDataEvent.accept("createData fail")
        }
    }
    
    // MARK: - key값에 있는 KeyChain Data 읽기
    func readData(key: String) -> String? {
        // kSecAttrAccount: key = key값에 있는 데이터를 찾음 (access_Token) 값을 찾음
        // kSecReturnData: kCFBooleanTrue as Any = CFData 타입으로 불러오라는 의미
        // kSecMatchLimit: kSecMatchLimitOne = 중복되는 경우, 하나의 값만 불러오라는 의미
        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrAccount: key,
                                      kSecReturnData: kCFBooleanTrue as Any,
                                      kSecMatchLimit: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        
        if status == errSecSuccess {
            // 성공
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else { return nil }
        } else {
            // 실패
            return nil
        }
    }
    
    func deleteData(key: String, vm: MainVM) {
        // kSecAttrAccount: key = key값에 있는 데이터 접근 (key = access_Token) 값을 찾음
        let keychainQuery: NSDictionary = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrAccount: key]
        
        // 해당 아이템 제거
        let status = SecItemDelete(keychainQuery)
        
        if status == errSecSuccess {
            print("deleteData success")
            vm.resultDataEvent.accept("deleteData success")
        } else {
            print("deleteData fail")
            vm.resultDataEvent.accept("deleteData fail")
        }
    }
}
