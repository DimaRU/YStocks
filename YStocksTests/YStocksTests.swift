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
        func loadSample<T: Decodable>(type: T.Type, name: String) -> T? {
            let bundle = Bundle.init(for: Self.self)
            guard
                let path = bundle.url(forResource: name, withExtension: "json"),
                let data = try? Data(contentsOf: path)
            else { return nil }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try? decoder.decode(type, from: data)
        }

        func loadProfile(for symbol: String) -> Promise<SymbolProfile> {
            return
                firstly {
                    after(seconds: 1.2)
                }.then {
                    FinProvider.shared.request(.profile(symbol: symbol))
                }.recover { error -> Promise<SymbolProfile> in
                    if case FinNetworkError.empty = error {
                        let profile = SymbolProfile(country: "", currency: "", exchange: "", finnhubIndustry: "", ipo: "", logo: "", marketCapitalization: 0, name: "", phone: "", shareOutstanding: 0, ticker: "empty", weburl: "")
                        return Promise.value(profile)
                    }
                    throw error
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

        let trendings = Set<String>(loadSample(type: [MboumReply].self, name: "mboum-trending")!.first!.quotes)
        let symbols = Set<String>(loadSample(type: [StockSymbol].self, name: "stockSymbols_US")!.map { $0.symbol })
        let usableTrendings = [String](symbols.intersection(trendings))
        print(usableTrendings)
        let expectation = XCTestExpectation(description: "Load profiles")
        loadAllProfiles(for: usableTrendings)
            .done { profiles in
                let profilesFiltred = profiles.filter{ $0.ticker != "empty" }
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .secondsSince1970
                encoder.outputFormatting = .prettyPrinted
                let data = try! encoder.encode(profilesFiltred)
                print("------------------")
                print(String(data: data, encoding: .utf8)!)
                print("------------------")
            }.catch { error in
                print(error)
            }.finally {
                expectation.fulfill()
            }
        wait(for: [expectation], timeout: 5000)
    }
}
