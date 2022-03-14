//
//  ReposViewModel.swift
//  DependencyInjectionDemo
//
//  Created by Bing Kuo on 2022/3/10.
//

import Foundation

struct Environment {
    var date: () -> Date = Date.init
    var gitHub = GitHub()
}

var Current = Environment()

class ReposViewModel {
    // MARK: - Properties
    var repos: [GitHub.Repo] = [] {
        didSet {
            reposUpdatedClosure?(repos)
        }
    }
    
    // MARK: - Closure
    var reposUpdatedClosure: (([GitHub.Repo]) -> Void)?
    var errorOccurredClosure: ((Error) -> Void)?
    
    func loadRepos() {
        Current.gitHub.fetchRepos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(repos):
                    self?.repos = repos
                        .filter { !$0.archived }
                        .sorted(by: {
                            guard let lhs = $0.pushedAt, let rhs = $1.pushedAt else { return false }
                            return lhs > rhs
                        })
                case let .failure(error):
                    self?.errorOccurredClosure?(error)
                }
            }
        }
    }
    
    func tappedRepo(repo: GitHub.Repo) {
        Analytics().track(.tappedRepo(repo))
    }
}
