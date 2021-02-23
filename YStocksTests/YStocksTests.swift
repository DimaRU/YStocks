//
//  YStocksTests.swift
//  YStocksTests
//
//  Created by Dmitriy Borovikov on 18.02.2021.
//

import XCTest
import Moya
import PromiseKit
@testable import YStocks

class YStocksTests: XCTestCase {

    override func setUp() {
        FinAPI.sampleBundle = Bundle.init(for: Self.self)
        FinProvider.instance = MoyaProvider<FinAPI>(stubClosure: MoyaProvider.immediatelyStub)
    }

    func testSampleProvider() {
        let expectation = XCTestExpectation(description: "Test Finprovider request")
        FinProvider.shared.request(.profile(symbol: "AAPL"))
            .done { (profile: SymbolProfile) in
                print(profile)
            }.then {
                FinProvider.shared.request(.stockSymbol(exchange: "US"))
            }.done { (symbols: [StockSymbol]) in
                print( symbols.first(where: { $0.symbol == "YNDX"})!)
            }.then {
                FinProvider.shared.request(.ytrending)
            }.done { (reply: RapidAPIReply) in
                print(reply.finance.result!.first!.count, reply.finance.result!.first!.quotes.first!)
            }.then {
                FinProvider.shared.request(.trending)
            }.done { (reply: [MboumReply]) in
                print(reply.first!.quotes.first!)
            }.then {
                FinProvider.shared.request(.constituents(stocksIndex: .SnP500))
            }.done { (reply: Constituents) in
                print(reply.constituents.count)
            }.catch { error in
                XCTFail(String(reflecting: error))
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10)
    }
}
