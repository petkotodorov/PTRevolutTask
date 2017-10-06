//
//  ApiClient.swift
//  PTRevolutTask
//
//  Created by Petko Todorov on 10/3/17.
//  Copyright © 2017 Petko Todorov. All rights reserved.
//

import Foundation

class ApiClient {
    
    static let shared = ApiClient()
    private init() {}
    
    private let session = URLSession(configuration: .default)
    private let baseUrl = "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml"
    
    func fetchRates(completionHandler: @escaping (ResponseResult) -> (Void)) {
        guard let url = URL(string: baseUrl) else { return }
        session.dataTask(with: url) { (data, response, error) in
            let responseResult = self.handleResponse(data: data, response: response, error: error)
            DispatchQueue.main.async {
                completionHandler(responseResult)
            }
        }.resume()
    }
}

extension ApiClient {
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> ResponseResult {
        if let error = error {
            return ResponseResult.failure(error.localizedDescription)
        } else if let data = data,
            let response = response as? HTTPURLResponse {
            if response.statusCode != 200 {
                return ResponseResult.failure("Something went wrong..")
            }
            return ResponseResult.success(data)
        }
        return ResponseResult.failure("Invalid error")
    }
}
