//
//  PixaImageNetworking.swift
//  ConcurrentImageLoader
//
//  Created by Bhabani on 23/08/20.
//  Copyright © 2020 Bhabani_Shankar. All rights reserved.
//

import Foundation

enum DataResponseError: Error{
    case network, decoding
    
    var reason: String{
        switch self {
        case .decoding:
            return "A error occured while decoding data."
        case .network:
            return "A error occured while fetching data."
        }
    }
}

class PixaNetworking {
    let apiKey = "17995034-1f37847f95057f950c6d21012"
    lazy var baseUrl: URL = {
     return URL(string: "https://pixabay.com/api")!
    }()
    
    let session: URLSession
    
    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
    
    func fetchPxaImageList(page: Int, completion: @escaping (Result<ImageResponse, DataResponseError>) -> () ) {
        var urlComponent = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
        let queryItem = [URLQueryItem(name: "key", value: apiKey),
                        URLQueryItem(name: "page", value: "\(page)"),
                        URLQueryItem(name: "image_type", value: "photo"),
                        URLQueryItem(name: "order", value: "popular"),
                        //URLQueryItem(name: "orientation", value: "vertical"),
                        URLQueryItem(name: "safesearch", value: "true")]
                       
        urlComponent?.queryItems = queryItem
//        print(urlComponent?.url as Any)
        session.dataTask(with: urlComponent!.url!) { (data, response, error) in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 300, let data = data else {
                completion(.failure(.network))
                return
            }
            guard let decodedResponse = try? JSONDecoder().decode(ImageResponse.self, from: data) else {
                completion(.failure(.decoding))
                return
            }
            completion(.success(decodedResponse))
        }.resume()
    }
}
