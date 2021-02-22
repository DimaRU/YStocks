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
//        FinAPI.sampleBundle = Bundle.init(for: Self.self)
//        FinProvider.instance = MoyaProvider<FinAPI>(stubClosure: MoyaProvider.immediatelyStub)
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
            }.catch { error in
                XCTFail(String(reflecting: error))
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 10)
    }


    func testLoadProfiles() {
        func loadProfile(for symbol: String) -> Promise<SymbolProfile> {
            return
                firstly {
                    after(seconds: 0.1)
                }.then {
                    FinProvider.shared.request(.profile(symbol: symbol))
                }
        }

        func loadAllProfiles(for symbols: [String]) -> Promise<[AnyIterator<Promise<SymbolProfile>>.Element.T]> {
            var symbolsGenerator = symbols.makeIterator()

            let generator = AnyIterator<Promise<SymbolProfile>> {
                guard
                    let symbol = symbolsGenerator.next()
                else { return nil }
                return loadProfile(for: symbol)
            }
            return when(fulfilled: generator, concurrently: 1)
        }

        let expectation = XCTestExpectation(description: "Load profiles")
        FinProvider.shared.request(.trending)
            .then { (reply: [MboumReply]) -> Promise<[AnyIterator<Promise<SymbolProfile>>.Element.T]> in
                loadAllProfiles(for: reply.first!.quotes)
            }.done { profiles in
                print(profiles)
            }.catch { error in
                print(error)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5000)
    }
}
