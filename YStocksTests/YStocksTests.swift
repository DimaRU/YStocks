//
//  YStocksTests.swift
//  YStocksTests
//
//  Created by Dmitriy Borovikov on 18.02.2021.
//

import XCTest
import Moya
@testable import YStocks

class YStocksTests: XCTestCase {

    override func setUp() {
        FinAPI.sampleBundle = Bundle.init(for: Self.self)
        FinProvider.instance = MoyaProvider<FinAPI>(stubClosure: MoyaProvider.immediatelyStub)
    }
//    func testGetCompanyProfile()
//    {
//        let expectation = XCTestExpectation(description: "Test Finprovider request")
//        FinProvider.shared.request(.profile(symbol: "YNDX"))
//            .done { (quote: Quote) in
//                print(quote)
//            }.catch { error in
//                XCTFail(String(reflecting: error))
//            }.finally {
//                expectation.fulfill()
//            }
//        wait(for: [expectation], timeout: 10)
//    }

    func testSampleProvider() {
        let expectation = XCTestExpectation(description: "Test Finprovider request")
        FinProvider.shared.request(.profile(symbol: "AAPL"))
            .done { (profile: SymbolProfile) in
                print(profile)
            }.catch { error in
                XCTFail(String(reflecting: error))
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10)

    }
}
