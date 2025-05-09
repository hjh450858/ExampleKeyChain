//
//  MainVM.swift
//  ExampleKeyChain
//
//  Created by 황재현 on 5/9/25.
//

import Foundation
import RxSwift
import RxCocoa
import Security


/// 메인 뷰모델
class MainVM: NSObject {
    // 결과값 이벤트
    var resultDataEvent = PublishRelay<String>()
    // 인디케이터 이벤트
    var indicatorEvent = PublishRelay<Bool>()
}
