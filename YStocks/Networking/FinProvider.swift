/////
////  FinProvider.swift
///   Copyright © 2021 Dmitriy Borovikov. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import PromiseKit

class FinProvider {
    typealias ErrorBlock = (Error) -> Void
    typealias RequestFuture = (target: FinAPI, resolve: (Decodable) -> Void, reject: ErrorBlock)

    static let shared = FinProvider()

    #if DEBUG
    fileprivate static let instance = { () -> MoyaProvider<FinAPI> in
        let configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
        if let value = ProcessInfo.processInfo.environment["MoyaLogger"] {
            return MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.defaultEndpointMapping, plugins: [NetworkLoggerPlugin(configuration: configuration)])
        } else {
            return MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.defaultEndpointMapping)
        }
    }()
    #else
    fileprivate static let instance = MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.endpointClosure)
    #endif

    // MARK: - Public
    func request(_ target: FinAPI) -> Promise<Void> {
        let (promise, seal) = Promise<Void>.pending()
        sendRequest((target,
                     resolve: { _ in seal.fulfill(Void()) },
                     reject: seal.reject))
        return promise
    }

    func request<T: Decodable>(_ target: FinAPI) -> Promise<T> {
        let (promise, seal) = Promise<T>.pending()
        sendRequest((target,
                     resolve: { self.parseData(data: $0 as! Data, seal: seal, target: target) },
                     reject: seal.reject))
        return promise
    }


    private func sendRequest(_ request: RequestFuture) {
        #if DEBUG
        print("Request:", request.target)
        #endif
        FinProvider.instance.request(request.target) { (result) in
            self.handleRequest(request: request, result: result)
        }
    }
}

extension FinProvider {

    private func handleRequest(request: RequestFuture, result: MoyaResult) {
        switch result {
        case let .success(moyaResponse):
            #if DEBUG
            print(moyaResponse.request?.url?.absoluteString ?? "")
            #endif
            switch moyaResponse.statusCode {
            case 200...299, 300...399:
                request.resolve(moyaResponse.data)
            case 429:
                handleNetworkFailureWithRetry(request: request)
            default:
                handleServerError(request: request, response: moyaResponse)
            }
        case .failure:
            request.reject(NatNetworkError.unavailable)
        //            handleNetworkFailure(request: request)
        }
    }

    private func handleServerError(request: RequestFuture, response moyaResponse: Moya.Response) {
        let statusCode = moyaResponse.statusCode
        let error = NatNetworkError.serverError(code: statusCode)
        request.reject(error)
    }

    private func handleNetworkFailureWithRetry(request: RequestFuture) {
//        delay(1) {
//            self.sendRequest(request)
//        }
    }

    fileprivate func parseData<T: Decodable>(data: Data, seal: Resolver<T>, target: FinAPI) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            let object = try decoder.decode(T.self, from: data)
            seal.fulfill(object)
        } catch {
            #if DEBUG
            print(error)
            #endif
            let message = error.localizedDescription
            seal.reject(NatNetworkError.responceSyntaxError(message: message))
        }
    }
}