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
        
        // ???????????? ????????? ??? Offset??? ?????? ?????? ?????? ?????? ???????????? ??????
        if offsetY > (contentHeight - height) {
            if isPaging == false && hasNextPage {
                beginPaging()
            }
        }
    }
    
    func beginPaging() {
        isPaging = true // ?????? ???????????? ?????? ?????? ?????? ??????
        // Section 1??? reload?????? ?????? ?????? ????????? (????????? ?????? ?????? ?????? ????????? ??? ?????????)
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: 1), with: .none)
        }
        
        // ????????? ????????? ??????
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
            self.cellDatas.append(contentsOf: datas) // ???????????? ???????????? append ????????? (???????????? ??????!)
            
            self.hasNextPage = self.cellDatas.count > 300 ? false : true // ?????? ???????????? ????????? ????????? ??????
            self.isPaging = false // ???????????? ?????? ???????????? ??????
            
            self.tableView.reloadData()
        }
    }
}


struct CellData {
    
    let title: String
    let date: Date
    
}
