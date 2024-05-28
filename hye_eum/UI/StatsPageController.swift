import UIKit
import Charts

class StatsPageController: UIViewController {
    
    @IBOutlet weak var commentLabel: UILabel!
    
    var emotionData: [String] = ["기쁨", "화남", "슬픔", "즐거움"]
    var countData: [Int] = [0, 0, 0, 0]
    var comment: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStats()
        
    }
    
    
    // MARK: - 데이터 적용

    
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
                    
                    if let joy = jsonResult["joy"] as? Int {
                        self.countData[1] = joy
                    }
                    
                    if let sadness = jsonResult["sadness"] as? Int {
                        self.countData[2] = sadness
                    }
                    
                    if let aggro = jsonResult["aggro"] as? Int {
                        self.countData[3] = aggro
                    }
                    
                    if let comment = jsonResult["gpt_comment"] as? String {
                        self.comment = comment
                    }
                    
                    print(self.countData)
                    print(self.comment)
                    
//                    DispatchQueue.main.async {
//
//                    }
                    
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
