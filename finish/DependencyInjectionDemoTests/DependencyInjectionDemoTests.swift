//
//  DependencyInjectionDemoTests.swift
//  DependencyInjectionDemoTests
//
//  Created by Bing Kuo on 2022/3/10.
//

import XCTest
import Foundation
@testable import DependencyInjectionDemo

extension Environment {
    static let mock = Environment(
        date: { Date(timeIntervalSinceReferenceDate: 547152051) },
        gitHub: .mock
    )
}

extension GitHub {
    static let mock = GitHub(
        fetchRepos: { callback in
            callback(.success([
                GitHub.Repo(
                    archived: false,
                    description: "Blob's blog",
                    htmlUrl: URL(string: "https://www.pointfree.co")!,
                    name: "Bloblog",
                    pushedAt: Date(timeIntervalSinceReferenceDate: 547152021)
                )
            ]))
        }
    )
}

class DependencyInjectionDemoTests: XCTestCase {
    var viewModel: ReposViewModel!
    
    override func setUpWithError() throws {
        super.setUp()
        Current = .mock
        viewModel = ReposViewModel()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        viewModel = nil
    }
    
    func testSuccessCase() throws {
        // given
        let expectation = expectation(description: "callback happend")
        
        viewModel.reposUpdatedClosure = { _ in
            expectation.fulfill()
        }
        
        // when
        viewModel.loadRepos()
        
        // then
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(viewModel.repos.count, 1)
        XCTAssertEqual(viewModel.repos.first!.pushedAt!.asDay(now: Current.date()), "30s")
    }
    
    func testFailureCase() throws {
        // given
        let expectation = expectation(description: "callback happend")
        Current.gitHub.fetchRepos = { callback in
            callback(.failure(
                NSError(
                    domain: "co.pointfree",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Ooops!"]
                )
            ))
        }
        
        viewModel.errorOccurredClosure = { _ in
            expectation.fulfill()
        }
        
        // when
        viewModel.loadRepos()
        
        // then
        wait(for: [expectation], timeout: 1)
    }
}
