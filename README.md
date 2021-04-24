# Swift_Pagination_Analysis

# Swift Pagination Example, Infinite Scrolling - 1 

### 간단한 설명

1. fetchData에 pagination이란 flag를 단다 
2. 스크롤뷰 끝에 다다랐을 때 데이터를 로드하게 시킨다. 

```swift
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
```

# Swift Pagination Examples - 2

### 간단한 설명

1. cell 두 개 준비 (loading, display)
2. section별로 구분
3. API 호출해주고 페이징할 숫자만큼 tableView에 데이터를 넣어준다.
4. ScrollViewDidScroll로 마지막에 다다랐을 때 페이징


```swift
//
//  ViewController.swift
//  InfiniteScrollingPerPage
//
//  Created by paige shin on 2021/04/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var cellDatas = [CellData]()
    
    var isPaging = false
    var hasNextPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self 
        tableView.register(UINib(nibName: "MyCell", bundle: nil), forCellReuseIdentifier: "MyCell")
        tableView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellReuseIdentifier: "LoadingCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        paging()
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cellDatas.count
        } else if section == 1 && isPaging && hasNextPage {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as? MyCell else {
                return UITableViewCell()
            }
            
            let data = cellDatas[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.timeZone = .current
            dateFormatter.dateFormat = "yyyy. MM. dd"
            
            cell.titleLabel.text = data.title
            cell.dateLabel.text = dateFormatter.string(from: data.date)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath) as? LoadingCell else {
                return UITableViewCell()
            }
            
            cell.start()
            
            return cell
        
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
}

extension ViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 스크롤이 테이블 뷰 Offset의 끝에 가게 되면 다음 페이지를 호출
        if offsetY > (contentHeight - height) {
            if isPaging == false && hasNextPage {
                beginPaging()
            }
        }
    }
    
    func beginPaging() {
        isPaging = true // 현재 페이징이 진행 되는 것을 표시
        // Section 1을 reload하여 로딩 셀을 보여줌 (페이징 진행 중인 것을 확인할 수 있도록)
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // 페이징 메소드 호출
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.paging()
        }
    }
    
    func paging() {
        let index = cellDatas.count
        
        var datas: [CellData] = []
        
        for i in index..<(index + 20) {
            let data = CellData(title: "Title\(i)", date: Date().addingTimeInterval(TimeInterval(86400 * i)))
            datas.append(data)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.cellDatas.append(contentsOf: datas) // 데이터는 계속해서 append 시켜줌 (페이징의 핵심!)
            
            self.hasNextPage = self.cellDatas.count > 300 ? false : true // 다음 페이지가 있는지 여부를 표시
            self.isPaging = false // 페이징이 종료 되었음을 표시
            
            self.tableView.reloadData()
        }
    }
}

struct CellData {
    
    let title: String
    let date: Date
    
}
```