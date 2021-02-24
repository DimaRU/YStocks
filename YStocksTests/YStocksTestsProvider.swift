//
//  YStocksTestsProvider.swift
//  YStocksTests
//
//  Created by Dmitriy Borovikov on 18.02.2021.
//

import XCTest
import Moya
import PromiseKit
@testable import YStocks

class YStocksProviderTests: XCTestCase {

    func testProvider() {
        let expectation = XCTestExpectation(description: "Test Finprovider request")
        firstly {
            FinProvider.shared.request(.profile(symbol: "AAPL"))
        }.done { (profile: SymbolProfile) in
            print(profile)
        }.catch { error in
            XCTFail(String(reflecting: error))
        }.finally {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
}
