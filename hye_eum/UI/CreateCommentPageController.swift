//
//  CreateCommentPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/26/24.
//

import UIKit

class CreateCommentPageController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Properties
    var qnaString: String = ""
    var emotion: String = ""
    var imageURL: String = ""
    private let emotions = ["기쁨", "슬픔", "즐거움", "화남"]
    private var selectedEmotion: String?
    
    // MARK: - UI ImageView
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - UI TextView
    @IBOutlet weak var commentTextView: UITextView!
    
    // MARK: - UI PickerView
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - UI Button
    @IBOutlet weak var doneBtn: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imageView.alpha = 0.0
        commentTextView.alpha = 0.0
        pickerView.alpha = 0.0
        doneBtn.alpha = 0.0
        
        
        print(qnaString)
        print(emotion)
        
        loadImage(from: imageURL)
        
        // PickerView 설정
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // PickerView의 초기 선택 항목 설정
        pickerView.selectRow(0, inComponent: 0, animated: false)
        selectedEmotion = emotion
        
        // commentTextView 설정
        commentTextView.layer.borderWidth = 1.0
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.layer.cornerRadius = 8.0
    }
    
    // MARK: - 이미지 로드 메서드
    private func loadImage(from urlString: String) {
        let loadingAlert = UIAlertController(title: "이미지 불러오는 중!", message: "이미지를 불러오는 중입니다. 잠시만 기다려주세요.", preferredStyle: .alert)
        present(loadingAlert, animated: true, completion: nil)
        
        guard let url = URL(string: urlString) else {
            loadingAlert.dismiss(animated: true, completion: nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else {
                    loadingAlert.dismiss(animated: true, completion: nil)
                    return
                }
                
                loadingAlert.dismiss(animated: true, completion: nil)
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    return
                }
                
                // 이미지 불러오기
                UIView.animate(withDuration: 1.2) {
                    self.commentTextView.alpha = 1.0
                    self.pickerView.alpha = 1.0
                    self.doneBtn.alpha = 1.0
                    self.imageView.alpha = 1.0
                
                    self.imageView.image = image
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - 완료 버튼 메서드
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        guard let comment = commentTextView.text, !comment.isEmpty else {
            // 댓글이 입력되지 않은 경우 처리
            print("코멘트를 입력하세요!")
            return
        }
        
        guard let selectedEmotion = selectedEmotion else {
            // 감정이 선택되지 않은 경우 처리
            print("감정을 선택하세요!")
            return
        }
        
        // POST 요청
        sendPostRequest(comment: comment, emotion: selectedEmotion)
    }
    
    // MARK: - book 생성 메서드
    private func sendPostRequest(comment: String, emotion: String) {
        
        // * 엔드라인 기준 library_id == user_tag
        let libraryID = UserDefaults.standard.integer(forKey: "user_tag")
        
        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/books") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "library_id": libraryID,
            "image": imageURL,
            "comment": comment,
            "detail_story": qnaString,
            "emotion": emotion
        ]
        
        print("requestBody(books) : \(libraryID), \(imageURL), \(comment), \(qnaString), \(emotion)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let error {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let loadingAlert = UIAlertController(title: "일기 저장중", message: "일기를 저장하고 있어요.\n잠시만 기다려주세요.", preferredStyle: .alert)
        present(loadingAlert, animated: true, completion: nil)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                loadingAlert.dismiss(animated: true, completion: nil)
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                print("HTTP status code: \(httpResponse.statusCode)")
                
                guard let _ = data else {
                    print("No data received")
                    return
                }
                
                print("Response data: \(String(data: data!, encoding: .utf8) ?? "")")
                
                // 메인 페이지로 이동
                self.navigateToMainPage()
            }
        }
        task.resume()
    }
    
    // 메인가기
    private func navigateToMainPage() {
        if let goMainVC = UIStoryboard(name: "CreateCommentPage", bundle: nil).instantiateViewController(withIdentifier: "MainPageController") as? MainPageController {
            navigationController?.pushViewController(goMainVC, animated: true)
        }
        
//        // 루트 뷰 컨트롤러로 돌아가기
//        guard let rootViewController = navigationController?.viewControllers.first else {
//            return
//        }
//        
//        navigationController?.popToViewController(rootViewController, animated: true)
    }
    
    
    // MARK: - PickerView Delegate & DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return emotions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return emotions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedEmotion = emotions[row]
    }
}
