import UIKit
import DGCharts

struct LibraryResponse: Codable {
    let id: Int
    let userId: Int
    let books: [Book]
    let statistics: [Statistics]
    let bookCount: Int

    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", books, statistics, bookCount = "book_count"
    }

    struct Book: Codable {
        let id: Int
        let libraryId: Int
        let image: String
        let comment: String
        let detailStory: String
        let emotion: String
        let createdAt: String

        enum CodingKeys: String, CodingKey {
            case id, libraryId = "library_id", image, comment, detailStory = "detail_story", emotion, createdAt = "created_at"
        }
    }

    struct Statistics: Codable {
        let happiness: Int
        let aggro: Int
        let sadness: Int
        let joy: Int
        let gptComment: String

        enum CodingKeys: String, CodingKey {
            case happiness, aggro, sadness, joy, gptComment = "gpt_comment"
        }
    }
}

class StatsPageController: UIViewController, BarChartDataProvider {
    
    var barData: BarChartData?
    var isDrawBarShadowEnabled: Bool = false
    var isDrawValueAboveBarEnabled: Bool = false
    var isHighlightFullBarEnabled: Bool = false
    
    let chartXMin: Double = 0.0
    let chartXMax: Double = 3.0
    let chartYMin: Double = 0.0
    var chartYMax: Double = 0.0
    let maxHighlightDistance: CGFloat = 500.0
    var xRange: Double {
        return chartXMax - chartXMin
    }
    var centerOffsets: CGPoint = .zero
    var data: ChartData? {
        return barData
    }
    
    let maxVisibleCount: Int = 10
    @IBOutlet weak var chartView: BarChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLibrary { [weak self] libraryResponses in
            if let libraryResponse = libraryResponses?.first {
                self?.setupChart(with: libraryResponse)
            }
        }
    }
    
    // MARK: - Book 객체 가져오기
    func fetchLibrary(completion: @escaping ([LibraryResponse]?) -> Void) {
        let userTag = UserDefaults.standard.integer(forKey: "user_tag")
        let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/library?user_tag=\(userTag)")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let libraryResponses = try JSONDecoder().decode([LibraryResponse].self, from: data)
                    completion(libraryResponses)
                    print(libraryResponses)
                } catch {
                    print("Error decoding library: \(error)")
                    completion(nil)
                }
                
            } else {
                print("Error fetching library: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
            }
        }.resume()
    }
    
    func setupChart(with libraryResponse: LibraryResponse) {
        
        print("SettingUp! Chat!")
            
        guard let statistics = libraryResponse.statistics.first else {
            return
        }

        let entries = [
            BarChartDataEntry(x: 0, y: Double(statistics.happiness), data: "Happiness"),
            BarChartDataEntry(x: 1, y: Double(statistics.aggro), data: "Aggro"),
            BarChartDataEntry(x: 2, y: Double(statistics.sadness), data: "Sadness"),
            BarChartDataEntry(x: 3, y: Double(statistics.joy), data: "Joy")
        ]

        let dataSet = BarChartDataSet(entries: entries, label: "Emotions")
        barData = BarChartData(dataSet: dataSet)

        chartView.data = barData
        chartView.largeContentTitle = "Emotion Statistics"
        chartView.xAxis.labelPosition = .bottom
        chartView.animate(yAxisDuration: 1.0)

        chartYMax = Double(max(statistics.happiness, statistics.aggro, statistics.sadness, statistics.joy))
    }
        
        func getTransformer(forAxis axis: YAxis.AxisDependency) -> Transformer {
            return chartView.getTransformer(forAxis: axis)
        }
        
        func isInverted(axis: YAxis.AxisDependency) -> Bool {
            return chartView.isInverted(axis: axis)
        }
        
        var lowestVisibleX: Double {
            return chartXMin
        }
        
        var highestVisibleX: Double {
            return chartXMax
        }
    }
