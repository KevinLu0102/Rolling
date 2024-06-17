//
//  APIRequest.swift
//  MovieTrailer
//
//  Created by Kevin Lu on 2024/6/12.
//

import Foundation

protocol APIRequestProtocol {
    func upcoming(page: Int) -> URLRequest?
    func detail(movieId: Int) -> URLRequest?
    func video(movieId: Int) -> URLRequest?
    func images(movieId: Int) -> URLRequest?
    func similar(movieId: Int) -> URLRequest?
}

fileprivate enum Path {
    case upcoming
    case detail(Int)
    case video(Int)
    case images(Int)
    case similar(Int)
    
    var rawValue: String {
        switch self {
        case .upcoming:
            return "upcoming"
        case .detail(let movieId):
            return "\(movieId)"
        case .video(let movieId):
            return "\(movieId)/videos"
        case .images(let movieId):
            return "\(movieId)/images"
        case .similar(let movieId):
            return "\(movieId)/similar"
        }
    }
}

struct APIRequest: APIRequestProtocol {
    private let baseURL: String
    private let apiKey: String
    private let language: String
    private let method: String
    
    init(config: RequestConfig = .default) {
        self.baseURL = config.baseURL
        self.apiKey = config.apiKey
        self.language = config.language
        self.method = config.method
    }
    
    private func makeRequest(path: Path, queryItems: [URLQueryItem] = []) -> URLRequest? {
        guard let url = URL(string: baseURL + path.rawValue)else{
            return nil
        }
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        let defaultQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        components.queryItems = components.queryItems.map { $0 + defaultQueryItems + queryItems } ?? defaultQueryItems + queryItems
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json"
        ]
        
        return request
    }
    
    func upcoming(page: Int) -> URLRequest? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        return makeRequest(path: .upcoming, queryItems: queryItems)
    }
    
    func detail(movieId: Int) -> URLRequest? {
        return makeRequest(path: .detail(movieId))
    }
    
    func video(movieId: Int) -> URLRequest? {
        return makeRequest(path: .video(movieId))
    }
    
    func images(movieId: Int) -> URLRequest? {
        return makeRequest(path: .images(movieId))
    }
    
    func similar(movieId: Int) -> URLRequest? {
        return makeRequest(path: .similar(movieId))
    }
}
