//
//  detailPage.swift
//  hye_eum
//
//  Created by mobicom on 5/28/24.
//
import UIKit

class DetailPageController: UIViewController {
    // UI 요소를 연결할 IBOutlet 추가

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    // 전달받을 책 정보 프로퍼티
    var book: MainPageController.LibraryResponse.Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.alpha = 0.0
        self.emotionLabel.alpha = 0.0
        self.dateLabel.alpha = 0.0
        self.textView.alpha = 0.0
        
        // 텍스트뷰 스타일 설정
        textView.layer.borderWidth = 2.0
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.cornerRadius = 10.0
        textView.layer.masksToBounds = true
        
        textView.textAlignment = .left
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.font = UIFont(name: "나눔명조", size: 18.0)
        
        // 그림자 효과 설정
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 0, height: 2)
        textView.layer.shadowOpacity = 0.7
        textView.layer.shadowRadius = 10.0
        

        
        // 이미지 그림자 효과 설정
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 4.0
        imageView.layer.masksToBounds = false
        
        updateUI()
    }
    
    private func updateUI() {
        print("updatingUI..")
        
        guard let book = book else {
            return
        }
        
        // 이미지 로드
        if let imageURL = URL(string: book.image) {
            loadImage(from: imageURL)
        }
        
        emotionLabel.text = "이 날의 감정 : \(book.emotion)"
        dateLabel.text = "[\(formatDate(book.created_at)!)]"

        let formattedDetailStory = formatDetailStory(book.detail_story)
        textView.text = formattedDetailStory
    }
    
    // detail_story 포맷팅 함수
    private func formatDetailStory(_ detailStory: String) -> String {
        let lines = detailStory.components(separatedBy: "Q :")
        var formattedLines: [String] = []
        
        for line in lines {
            let parts = line.components(separatedBy: "A :")
            if parts.count == 2 {
                let question = parts[0].trimmingCharacters(in: .whitespaces)
                let answer = parts[1].trimmingCharacters(in: .whitespaces)
                let formattedLine = "Q. \(question)\nA. \(answer)\n\n"
                formattedLines.append(formattedLine)
            }
        }
        
        return formattedLines.joined()
    }
    
    // 이미지 로드 함수
    private func loadImage(from url: URL) {
        
        print("loadImage..")
        
        let fadeDuration: TimeInterval = 2.0
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
                UIView.animate(withDuration: fadeDuration) {
                    self.imageView.alpha = 1.0
                    self.dateLabel.alpha = 1.0
                }
                UIView.animate(withDuration: fadeDuration + 0.5) {
                    self.emotionLabel.alpha = 1.0
                }
                UIView.animate(withDuration: fadeDuration + 1) {
                    self.textView.alpha = 1.0
                }
            }
        }.resume()
    }
    
    // 날짜 포맷 함수
    private func formatDate(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy. MM. dd"
            return dateFormatter.string(from: date)
        }
        
        return nil
    }
    
    // 닫기 버튼 액션 추가
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
