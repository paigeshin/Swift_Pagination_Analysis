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
