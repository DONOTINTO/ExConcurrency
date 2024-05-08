//
//  Network.swift
//  Concurrency
//
//  Created by 이중엽 on 5/8/24.
//

import UIKit

enum JackError: Error {
    case invalidResponse
    case unknown
    case invalidImage
}


@MainActor // swift concurrency를 작성해둔 코드에서 다시 메인 쓰레드로 돌려주는 역할 수행
class Network {
    
    static let shared = Network()
    
    private init() { }
    
    static let url = URL(string: "https://picsum.photos/200/300")!
    
    // DispatchQueue
    func fetchThumbnail(completionHandler: @escaping (UIImage) -> Void) {
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: Network.url)
                
                if let image = UIImage(data: data) {
                    completionHandler(image)
                } else {
                    completionHandler(UIImage(systemName: "star")!)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func fetchThumbnail2(completionHandler: @escaping (UIImage?, JackError?) -> Void) {
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: Network.url)
                
                if let image = UIImage(data: data) {
                    completionHandler(image, nil)
                } else {
                    completionHandler(nil, .invalidImage)
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func fetchThumbnail3(completionHandler: @escaping (Result<UIImage, JackError>) -> Void) {
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: Network.url)
                
                if let image = UIImage(data: data) {
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(.invalidImage))
                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func fetchThumbnailURLSession(completionHandler: @escaping (Result<UIImage, JackError>) -> Void) {
        
        let request = URLRequest(url: Network.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        print("0000")
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("1111")
            guard let data else {
                completionHandler(.failure(.unknown))
                return
            }
            
            guard error == nil else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completionHandler(.failure(.invalidImage))
                return
            }
            
            completionHandler(.success(image))
            
        }.resume()
        print("2222")
    }
    
    func fetchThumbnailAsyncAwait() async throws -> UIImage {
     
        let request = URLRequest(url: Network.url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        
        // await: 비동기를 동기처럼 작업할테니, 응답이 올 때까지 딱 기다려
        let (data, response) = try await URLSession.shared.data(for: request)
        
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            
            throw JackError.invalidResponse
        }
        
        guard let image = UIImage(data: data) else {
            
            throw JackError.invalidImage
        }
        
        return image
    }
    
    func fetchThumbnailAsyncLet() async throws -> [UIImage] {
        
        async let result = Network.shared.fetchThumbnailAsyncAwait()
        async let result2 = Network.shared.fetchThumbnailAsyncAwait()
        async let result3 = Network.shared.fetchThumbnailAsyncAwait()
        
        return try await [result, result2, result3]
    }
    
    func fetchThumbnailTaskGroup() async throws -> [UIImage] {
        
        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            
            for item in 0 ... 40 {
                
                group.addTask {
                    try await Network.shared.fetchThumbnailAsyncAwait()
                }
            }
            
            var resultImage: [UIImage] = []
            
            for try await item in group {
                resultImage.append(item)
            }
            
            return resultImage
        }
    }
}
