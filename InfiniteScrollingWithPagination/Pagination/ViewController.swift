//
//  ViewController.swift
//  Pagination
//
//  Created by paige shin on 2021/04/24.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    private let apiService = APIService()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        apiService.fetchData(pagination: false, completion: { [weak self] result in
                switch result {
                    case .success(let data):
                        self?.data.append(contentsOf: data)
                        DispatchQueue.main.async {
                            self?.tableView.reloadData()
                        }
                    case .failure(_):
                    break
                }
            }
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        return footerView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - 100 - scrollView.frame.size.height {
            // Fetch More Data
            guard !apiService.isPaginating else {
                print("Already Fetching More Data...")
                return
            }
            self.tableView.tableFooterView = createSpinnerFooter()
            print("Fetch more data")
            apiService.fetchData(pagination: true) { [weak self] result in
                DispatchQueue.main.async {
                    self?.tableView.tableFooterView = nil
                }
                switch result {
                case .success(let moreData):
                    self?.data.append(contentsOf: moreData)
                    DispatchQueue.main.async { [weak self] in
                        self?.tableView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    

}

class APIService {
    
    var isPaginating = false
    
    func fetchData(pagination: Bool = false, completion: @escaping(Result<[String], Error>) -> Void) {
        
        if pagination {
            self.isPaginating = true
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            let originalData = [
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
                "Apple",
                "Google",
                "Facebook",
            ]
            let newData = ["banana", "oranges", "grapes", "Food"]
            
            completion(.success(pagination ? newData : originalData))
            
            if pagination {
                self.isPaginating = false
            }
        })
    }
    
    
}
