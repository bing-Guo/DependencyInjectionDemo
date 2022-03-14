//
//  Analytics.swift
//  DependencyInjectionDemo
//
//  Created by Bing Kuo on 2022/3/10.
//

import Foundation
import UIKit

struct Analytics {
    struct Event {
        var name: String
        var properties: [String: String]
        
        static func tappedRepo(_ repo: GitHub.Repo) -> Event {
            return Event(
                name: "tapped_repo",
                properties: [
                    "repo_name": repo.name,
                    "build": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown",
                    "release": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
                    "screen_height": String(describing: UIScreen.main.bounds.height),
                    "screen_width": String(describing: UIScreen.main.bounds.width),
                    "system_name": UIDevice.current.systemName,
                    "system_version": UIDevice.current.systemVersion,
                ]
            )
        }
    }
    
    func track(_ event: Analytics.Event) {
        print("Tracked", event)
    }
}
