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
    static let callbackQueue = DispatchQueue.init(label: "queue.finprovider", qos: .utility, attributes: .concurrent)
    #if DEBUG
    static var instance = { () -> MoyaProvider<FinAPI> in
        if let value = ProcessInfo.processInfo.environment["MoyaLogger"] {
            let configuration = NetworkLoggerPlugin.Configuration(logOptions: .verbose)
            return MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.defaultEndpointMapping,
                                        callbackQueue: callbackQueue,
                                        plugins: [NetworkLoggerPlugin(configuration: configuration)])
        } else {
            return MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.defaultEndpointMapping, callbackQueue: callbackQueue)
        }
    }()
    #else
    static var instance = MoyaProvider<FinAPI>(endpointClosure: MoyaProvider.endpointClosure, callbackQueue: callbackQueue)
    #endif

    // MARK: - Public
    func request(_ target: FinAPI) -> Promise<Void> {
        let (promise, seal) = Promise<Void>.pending()
        enqueueRequest((target,
                     resolve: { _ in seal.fulfill(Void()) },
                     reject: seal.reject))
        return promise
    }

    func request<T: Decodable>(_ target: FinAPI) -> Promise<T> {
        let (promise, seal) = Promise<T>.pending()
        enqueueRequest((target,
                     resolve: { self.parseData(data: $0 as! Data, seal: seal, target: target) },
                     reject: seal.reject))
        return promise
    }

    func requestData(_ target: FinAPI) -> Promise<Data> {
        let (promise, seal) = Promise<Data>.pending()
        enqueueRequest((target,
                     resolve: { seal.fulfill($0 as! Data) },
                     reject: seal.reject))
        return promise
    }

    // MARK: - Private
    private var requestsInProgress: Int = 0
    private var requestQueue: [RequestFuture] = []

    private func enqueueRequest(_ request: RequestFuture) {
        if requestsInProgress != 0 || !requestQueue.isEmpty {
            requestQueue.append(request)
        } else {
            sendRequest(request)
        }
    }

    private func dequeRequest() {
        guard requestsInProgress == 0 && !requestQueue.isEmpty else { return }
        DispatchQueue.main.async {
            let request = self.requestQueue.removeFirst()
            self.sendRequest(request)
        }
    }

    private func sendRequest(_ request: RequestFuture) {
        requestsInProgress += 1
        FinProvider.instance.request(request.target) { (result) in
            self.handleRequest(result: result, request: request)
            self.dequeRequest()
        }
    }

    private func handleRequest(result: MoyaResult, request: RequestFuture) {
        self.requestsInProgress -= 1
        switch result {
        case let .success(moyaResponse):
            #if DEBUG
            print(moyaResponse.request?.url?.absoluteString ?? "", moyaResponse.data.count)
            #endif
            switch moyaResponse.statusCode {
            case 200:
                if moyaResponse.data.isEmpty ||
                    (moyaResponse.data.count == 2 && String(data: moyaResponse.data, encoding: .utf8) == "{}") {
                    request.reject(FinNetworkError.empty)
                    return
                }
                fallthrough
            case 201...299, 300...399:
                request.resolve(moyaResponse.data)
            case 429:
                let duration: TimeInterval
                if
                    let rateLimitReset = moyaResponse.response?.headers["X-Ratelimit-Reset"],
                    let rateLimitResetTime = Double(rateLimitReset) {
                    duration = Date(timeIntervalSince1970: rateLimitResetTime).timeIntervalSinceNow
                } else {
                    duration = 2
                }
                #if DEBUG
                print("Error 429", Date(), duration)
                #endif
                handleNetworkFailureWithRetry(request: request, duration: duration)
            default:
                handleServerError(request: request, response: moyaResponse)
            }
        case .failure:
            request.reject(FinNetworkError.unavailable)
        //            handleNetworkFailure(request: request)
        }
    }

    private func handleServerError(request: RequestFuture, response moyaResponse: Moya.Response) {
        let statusCode = moyaResponse.statusCode
        let error = FinNetworkError.serverError(code: statusCode)
        request.reject(error)
    }

    private func handleNetworkFailureWithRetry(request: RequestFuture, duration: TimeInterval) {
        requestsInProgress += 1
        delay(duration) {
            self.requestsInProgress -= 1
            self.sendRequest(request)
        }
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
            seal.reject(FinNetworkError.responceSyntaxError(message: message))
        }
    }
}
