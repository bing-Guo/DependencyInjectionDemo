//
//  DependencyInjectionDemoTests.swift
//  DependencyInjectionDemoTests
//
//  Created by Bing Kuo on 2022/3/10.
//

import XCTest
import Foundation
@testable import DependencyInjectionDemo

struct GitHubMock: GitHubProtocol {
    let result: Result<[GitHub.Repo], Error>
    
    // happy path: default return .success case
    init(result: Result<[GitHub.Repo], Error> = .success([
        GitHub.Repo(
            archived: false,
            description: "Blob's blog",
            htmlUrl: URL(string: "https://www.pointfree.co")!,
            name: "Bloblog",
            pushedAt: Date(timeIntervalSinceReferenceDate: 547152021)
        )
    ])) {
        self.result = result
    }
    
    func fetchRepos(onComplete completionHandler: @escaping (Result<[GitHub.Repo], Error>) -> Void) {
        completionHandler(result)
    }
}

class DependencyInjectionDemoTests: XCTestCase {
    override func setUpWithError() throws {
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testSuccessCase() throws {
        // given
        let expectation = expectation(description: "callback happend")
        let viewModel = ReposViewModel(
            date: { Date(timeIntervalSinceReferenceDate: 547152051) },
            gitHub: GitHubMock()
        )
        
        viewModel.reposUpdatedClosure = { _ in
            expectation.fulfill()
        }
        
        // when
        viewModel.loadRepos()
        
        // then
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(viewModel.repos.count, 1)
        XCTAssertEqual(viewModel.repos.first!.pushedAt!.asDay(now: viewModel.date())!, "30s")
    }
    
    func testFailureCase() throws {
        // given
        let expectation = expectation(description: "callback happend")
        let viewModel = ReposViewModel(
            date: { Date(timeIntervalSinceReferenceDate: 547152051) },
            gitHub: GitHubMock(result: .failure(
                NSError(
                    domain: "co.pointfree",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Ooops!"]
                )
            ))
        )
        
        viewModel.errorOccurredClosure = { _ in
            expectation.fulfill()
        }
        
        // when
        viewModel.loadRepos()
        
        // then
        wait(for: [expectation], timeout: 1)
    }
}
