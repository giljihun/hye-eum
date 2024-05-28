//
//  MyCollectionViewCell.swift
//  hye_eum
//
//  Created by mobicom on 5/25/24.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {

    // MARK: - Book Struct
    struct LibraryResponse: Codable {
        let id: Int
        let user_id: Int
        let books: [Book]
        let statistics: Statistics
        let bookCount: Int
    }

    struct Book: Codable {
        let id: Int
        let library_id: Int
        let image: String
        let comment: String
        let detail_story: String
        let emotion: String
        let created_at: String
    }

    struct Statistics: Codable {
        let happiness: Int
        let aggro: Int
        let sadness: Int
        let joy: Int
        let gpt_comment: String
    }
    
    // MARK: - UI ImageView
    @IBOutlet weak var thumbnail: UIImageView!
    
    // MARK: - UI labels
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailMentLabel: UILabel!
    
    // MARK: - Configure Cell
    func configure(with book: MainPageController.LibraryResponse.Book) {

        thumbnail.image = nil
        emotionLabel.text = ""
        dateLabel.text = ""
        
        // 이미지 설정 (URL을 통해 이미지를 로드하는 비동기 함수 필요)
        if let imageURL = URL(string: book.image) {
            loadImage(from: imageURL)
        }
        
        emotionLabel.text = book.emotion
        dateLabel.text = formatDate(book.created_at)
    }
    // MARK: - detail 멘트 애니메이션
    func detailMentLabelAnimation() {
        let fadeDuration = 1.5 // 페이드 인 시간 설정
        let scaleDuration = 1.3 // 크기 조정 시간 설정
        let scaleMultiplier: CGFloat = 1.1 // 크기를 키우는 배수 설정
        
        // 애니메이션 1: 페이드 인 및 크기 조정
        UIView.animate(withDuration: fadeDuration, animations: {
            self.detailMentLabel.alpha = 1.0
            self.detailMentLabel.transform = CGAffineTransform(scaleX: scaleMultiplier, y: scaleMultiplier)
        }, completion: { _ in
            // 애니메이션 2: 원래 크기로 되돌리기
            UIView.animate(withDuration: scaleDuration, animations: {
                self.detailMentLabel.transform = CGAffineTransform.identity
            }, completion: { _ in
                // 애니메이션 반복
                self.detailMentLabelAnimation()
            })
        })
    }
    
    // MARK: - Load Thumbnail Image
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.thumbnail.image = UIImage(data: data)
                }
            }
        }.resume()
    }
    // MARK: - Date Formatter
    
    private func formatDate(_ dateString: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            displayFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            return displayFormatter.string(from: date)
        }
        
        return nil
    }
    
    // MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        detailMentLabelAnimation()
        
        contentView.layer.cornerRadius = 16.0
        contentView.layer.masksToBounds = true
    
        // 그림자 설정
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        
        thumbnail.contentMode = .scaleAspectFit
        
        //둥근 테두리
        thumbnail.layer.cornerRadius = 16
        
        //그림자
        thumbnail.layer.masksToBounds = false
        thumbnail.layer.shadowOffset = CGSize(width: 2, height: 2)
        thumbnail.layer.shadowOpacity = 0.5
        thumbnail.layer.shadowRadius = 4
        thumbnail.layer.shadowColor = UIColor.gray.cgColor
        
    }
}
