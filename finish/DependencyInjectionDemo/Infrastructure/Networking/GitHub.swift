//
//  GitHub.swift
//  DependencyInjectionDemo
//
//  Created by Bing Kuo on 2022/3/10.
//

import Foundation

struct GitHub {
    struct Repo: Decodable {
        var archived: Bool
        var description: String?
        var htmlUrl: URL
        var name: String
        var pushedAt: Date?
    }
    
    // Static:     (@escaping ((Result<[GitHub.Repo], Error>) -> Void)) -> ()
    // non-Static: (GitHub) -> (@escaping ((Result<[GitHub.Repo], Error>) -> Void)) -> ()
    var fetchRepos = GitHub.fetchRepos(onComplete:)
    
    // use static
    private static func fetchRepos(onComplete completionHandler: (@escaping (Result<[GitHub.Repo], Error>) -> Void)) {
        GitHub.dataTask("orgs/pointfreeco/repos", completionHandler: completionHandler)
    }
    
    private static func dataTask<T: Decodable>(_ path: String, completionHandler: (@escaping (Result<T, Error>) -> Void)) {
        let request = URLRequest(url: URL(string: "https://api.github.com/" + path)!)
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            do {
                if let error = error {
                    throw error
                } else if let data = data {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    completionHandler(.success(try decoder.decode(T.self, from: data)))
                } else {
                    fatalError()
                }
            } catch let finalError {
                completionHandler(.failure(finalError))
            }
        }.resume()
    }
}
