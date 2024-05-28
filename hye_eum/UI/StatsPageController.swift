import UIKit
import Charts
import SwiftUI

class StatsPageController: UIViewController {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    var emotionData: [String] = ["기쁨", "화남", "슬픔", "즐거움"]
    var countData: [Int] = [0, 0, 0, 0]
    var comment: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 안보이게
        self.navigationController?.navigationBar.isHidden = true
        // 제스처로 뒤로가는 기능 삭제
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        print("BEFORE FETCHING")
        
        fetchStats()
    }
    
    // MARK: - 통계 가져오기
    func fetchStats() {
        let libraryID = UserDefaults.standard.integer(forKey: "library_id")
        print(libraryID)
        let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/statistics/\(libraryID)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let happiness = jsonResult["happiness"] as? Int {
                        self.countData[0] = happiness
                    }
                    
                    if let joy = jsonResult["aggro"] as? Int {
                        self.countData[1] = joy
                    }
                    
                    if let sadness = jsonResult["sadness"] as? Int {
                        self.countData[2] = sadness
                    }
                    
                    if let aggro = jsonResult["joy"] as? Int {
                        self.countData[3] = aggro
                    }
                    
                    if let comment = jsonResult["gpt_comment"] as? String {
                        self.comment = comment
                    }
                    
                    print("countData :" ,self.countData)
                    print("comment :", self.comment)
                    
                    DispatchQueue.main.async {
                        self.drawChart()
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func drawChart() {
        print("AFTER FETCHING")
        print("eD", emotionData)
        print("cD", countData)
        
        if #available(iOS 16.0, *) {
            
            let chart = Chart {

                BarMark(
                    x: .value("Shape Type", emotionData[0]),
                    y: .value("Total Count", min(countData[0], 5))
                )
                .foregroundStyle(Color.yellow)
                
                BarMark(
                    x: .value("Shape Type", emotionData[1]),
                    y: .value("Total Count", min(countData[1], 5))
                )
                .foregroundStyle(Color.red)
                
                BarMark(
                    x: .value("Shape Type", emotionData[2]),
                    y: .value("Total Count", min(countData[2], 5))
                )
                .foregroundStyle(Color.blue)
                
                BarMark(
                    x: .value("Shape Type", emotionData[3]),
                    y: .value("Total Count", min(countData[3], 5))
                )
                .foregroundStyle(Color.orange)
            }
                .chartYScale(domain: 0...5)
                .animation(.easeIn, value: countData)
            
            // 차트를 담을 호스트 뷰 생성
            let hostView = UIHostingController(rootView: chart)
            
            // 차트 크기 설정
            hostView.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 350)
            
            // 차트를 현재 뷰 계층구조에 추가
            view.addSubview(hostView.view)
            
            hostView.view.translatesAutoresizingMaskIntoConstraints = false
            
            // 호스트 뷰의 너비를 슈퍼뷰의 너비에 맞게 조정
            NSLayoutConstraint.activate([
                hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                hostView.view.heightAnchor.constraint(equalTo: hostView.view.widthAnchor, multiplier: 1.2)
            ])
            
            // 호스트 뷰를 commentLabel의 위에 배치하는 제약 조건 추가
            NSLayoutConstraint.activate([
                hostView.view.bottomAnchor.constraint(equalTo: commentLabel.topAnchor, constant: -40),
                hostView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        } else {
            // Fallback on earlier versions
        }
    }
}
