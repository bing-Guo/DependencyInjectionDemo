//
//  ViewController.swift
//  DependencyInjectionDemo
//
//  Created by Bing Kuo on 2022/3/10.
//

import UIKit
import SafariServices

class ReposViewController: UITableViewController {
    let viewModel: ReposViewModel
    
    // MARK: - Initialization
    init(viewModel: ReposViewModel = ReposViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Point-Free Repos"
        self.view.backgroundColor = .white
        
        bindViewModel()
        
        viewModel.loadRepos()
    }
    
    func bindViewModel() {
        viewModel.reposUpdatedClosure = { [weak self] _ in
            self?.tableView.reloadData()
        }
        
        viewModel.errorOccurredClosure = { [weak self] error in
            let alert = UIAlertController(
                title: "Something went wrong",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = viewModel.repos[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.description
        
        let label = UILabel()
        if let pushedAt = repo.pushedAt {
            label.text = pushedAt.asDay(now: Current.date())
        }
        label.sizeToFit()
        
        cell.accessoryView = label
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = viewModel.repos[indexPath.row]
        viewModel.tappedRepo(repo: repo)
        let vc = SFSafariViewController(url: repo.htmlUrl)
        self.present(vc, animated: true, completion: nil)
    }
}

extension Date {
    func asDay(now: Date) -> String? {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.day, .hour, .minute, .second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .abbreviated
        
        return dateComponentsFormatter.string(from: self, to: now)
    }
}
