//
//  CreateDiaryPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/16/24.
//

import UIKit

class CreateDiaryPageController: UIViewController, UITextFieldDelegate {
    
    // MARK: - UI Label
    
    @IBOutlet weak var comChatLabel: UILabel!
    @IBOutlet weak var myChatLabel: UILabel!
    
    // MARK: - UI TextField
    
    @IBOutlet weak var myTextField: UITextField!
    
    
    // MARK: - UI Button
    
    @IBOutlet weak var enterChatBtn: UIButton!
    @IBOutlet weak var doneChatBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    // MARK: - Properties
    var questionArray: [String] = []
    var savedQA = ""
    let initialQuestion = "당신의 오늘 하루에 대해 들려주세요!"
    let alignment = UserDefaults.standard.string(forKey: "user_alignment")!
    var emotion = ""
    var consolation = ""
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 네비게이션 바 안보이게
        self.navigationController?.navigationBar.isHidden = true
        // 제스처로 뒤로가는 기능 삭제
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        // 키보드 나타남/사라짐을 감지하는 Notification 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        myTextField.delegate = self
        
        tfConfig(tf: myTextField)
        comlabelConfig(label: comChatLabel)
        myChatLabel.numberOfLines = 0
        myChatLabel.lineBreakMode = .byWordWrapping
        myChatLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        myChatLabel.textAlignment = .center
        myChatLabel.textColor = UIColor.lightGray
        
        // for open animation
        comChatLabel.alpha = 0.0
        myChatLabel.alpha = 0.0
        myTextField.alpha = 0.0
        enterChatBtn.alpha = 0.0
        doneChatBtn.alpha = 0.0
        startAnimation()
        comChatLabel.text = initialQuestion
    }
    
    // MARK: - 질문 전송 메서드
    @IBAction func sendBtnTapped(_ sender: UIButton) {
        guard let userAnswer = myTextField.text, !userAnswer.isEmpty else {
            return
        }
        
        // 최초 질문인 경우
        if questionArray.isEmpty {
            let qnaString = "Q : \(initialQuestion) A : \(userAnswer)"
            questionArray.append(qnaString)
            
        } else {
            // 이전 답변과 새로운 질문으로 qnaString 생성
            var newQnA = ""
            let lastQnA = comChatLabel.text

            newQnA = "Q : \(lastQnA!) A : \(userAnswer)"

            // 배열에 저장
            if !newQnA.isEmpty {
                questionArray.append(newQnA)
            }
        }
        
        print("저장된질문배열! : ", questionArray)
        
        // POST 요청
        sendPostRequest(qnaString: questionArray.last ?? "")
    }
    
    // 리턴버튼으로 제출버튼 누르기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 숨기기
        sendBtnTapped(UIButton()) // 제출 액션 수행
        return true
    }
    
    func sendPostRequest(qnaString: String) {
        
        self.myTextField.alpha = 0.0
        self.comChatLabel.alpha = 0.0
        self.myChatLabel.alpha = 0.0
        
        let ments = ["음..", "오..", "흐음..", "!"]
        
        UIView.animate(withDuration: fadeDuration) {
            self.myTextField.alpha = 1.0
            self.comChatLabel.alpha = 1.0
            self.myTextField.text = ""
            self.comChatLabel.text = ments.randomElement()
        }
        
        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/question-generation") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print(qnaString)
        // Request body 생성
        let requestBody: [String: String] = [
            "qna_string": qnaString,
            "alignment": alignment,
            "polite" : "경어"
        ]
        
        print("Request body: \(requestBody)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let error {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                self.comChatLabel.alpha = 0.0
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let newQuestion = jsonResponse["question"] as? String {
                    print("newQuestion : ", newQuestion)
                    DispatchQueue.main.async {

                        UIView.animate(withDuration: self.fadeDuration) {
                            
                            self.comChatLabel.alpha = 1.0
                            
                            self.comChatLabel.text = newQuestion
                            
                            // 이전 질문과 답
                            self.myChatLabel.alpha = 1.0
                            
                            if let lastQuestion = self.questionArray.last {
                                let components = lastQuestion.components(separatedBy: "A :")
                                if components.count == 2 {
                                    let formattedText = "\(components[0].trimmingCharacters(in: .whitespaces))\nA: \(components[1].trimmingCharacters(in: .whitespaces))"
                                    self.myChatLabel.text = formattedText
                                } else {
                                    // 구분자가 없는 경우 처리
                                    self.myChatLabel.text = lastQuestion
                                }
                            }
                        }
                    }
                } else {
                    print("Invalid response format")
                }
            } catch let error {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    @IBAction func endBtnTapped(_ sender: UIButton) {
        for item in questionArray {
            savedQA += "\(item) "
        }
        print(savedQA)

        // 감정 생성
        let emotionAlertController = UIAlertController(title: "감정 분석중", message: "당신의 감정을 분석 중입니다. \n 잠시만 기다려주세요.", preferredStyle: .alert)
        present(emotionAlertController, animated: true, completion: nil)

        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/emotion-generation") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = [
            "qna_string": savedQA,
            "alignment": alignment
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let error {
            print("Error serializing JSON: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                emotionAlertController.dismiss(animated: true, completion: nil)

                if let error = error {
                    print("Error: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let get_emotion = jsonResponse["emotion"] as? String,
                           let get_consolation = jsonResponse["consolation"] as? String {
                            print("Emotion: \(get_emotion)")
                            print("Consolation: \(get_consolation)")
                            self.emotion = get_emotion
                            self.consolation = get_consolation

                            // 이미지 생성 요청
                            self.generateImage(qnaString: self.savedQA, emotion: get_emotion)
                        }
                    }
                } catch let error {
                    print("Error parsing JSON: \(error)")
                }
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            task.resume()
        }
    }

    // MARK: - Image Generation
    private func generateImage(qnaString: String, emotion: String) {
        let imageAlertController = UIAlertController(title: "이미지 생성중", message: "당신의 이미지를 생성 중입니다. \n 잠시만 기다려주세요.", preferredStyle: .alert)
        present(imageAlertController, animated: true, completion: nil)

        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/image-generation") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: String] = [
            "qna_string": qnaString,
            "emotion": emotion
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch let error {
            print("Error serializing JSON: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                imageAlertController.dismiss(animated: true, completion: nil)

                if let error = error {
                    print("Error: \(error)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let imageURL = jsonResponse["image_url"] as? String {
                            print("Image URL: \(imageURL)")

                            // 다음 뷰 컨트롤러로 이동하며 imageURL 전달
                            if let nextVC = UIStoryboard(name: "CreateDiaryPage", bundle: nil).instantiateViewController(withIdentifier: "CreateCommentPageController") as? CreateCommentPageController {
                                nextVC.imageURL = imageURL
                                nextVC.qnaString = self.savedQA
                                nextVC.emotion = self.emotion
                                self.navigationController?.pushViewController(nextVC, animated: true)
                            }
                        }
                    }
                } catch let error {
                    print("Error parsing JSON: \(error)")
                }
            }
        }

        task.resume()
    }
    // MARK: - 애니메이션 메서드
    let fadeDuration: TimeInterval = 1.0
    
    private func startAnimation() {
        
        UIView.animate(withDuration: fadeDuration) {
            self.comChatLabel.alpha = 1.0
            self.myChatLabel.alpha = 1.0
            self.myTextField.alpha = 1.0
            self.enterChatBtn.alpha = 1.0
            self.doneChatBtn.alpha = 1.0
        }
    }
    
    // MARK: - TextField Config
    private func tfConfig(tf : UITextField) {
        // 기본 테두리 스타일 설정
        tf.borderStyle = .none
        tf.layer.cornerRadius = 8.0
        tf.layer.borderWidth = 1.0
        tf.placeholder = "Enter your mind"
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.autocorrectionType = .no
        tf.font = UIFont.systemFont(ofSize: 16.0)
        
        let borderLayer = CALayer()
        borderLayer.frame = tf.bounds
        borderLayer.borderColor = UIColor.lightGray.cgColor
        borderLayer.borderWidth = 1.0
        borderLayer.cornerRadius = 8.0
        
        borderLayer.shadowColor = UIColor.black.cgColor
        borderLayer.shadowOpacity = 0.7
        borderLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        borderLayer.shadowRadius = 4.0
        
        tf.layer.addSublayer(borderLayer)
        tf.layer.masksToBounds = false
        
        
        
    }
    
    // MARK: - Label Config
    private func comlabelConfig(label: UILabel) {
        let text = label.text ?? ""
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10 // 원하는 줄 간격 설정
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.kern, value: 2, range: NSRange(location: 0, length: attributedString.length)) // 글자 사이 간격 설정
        label.attributedText = attributedString
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
    }
    
    private func mylabelConfig(label: UILabel) {
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        
        let verticalPadding: CGFloat = 8.0
        label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y + verticalPadding, width: label.frame.width, height: label.frame.height - verticalPadding * 2.0)
        
        let labelSize = label.sizeThatFits(CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let textWidth = labelSize.width
        let textHeight = labelSize.height
        
        let borderLayer = CALayer()
        let borderOffset: CGFloat = -1.0
        let borderWidth = min(textWidth - borderOffset, label.bounds.width)
        borderLayer.frame = CGRect(x: borderOffset, y: textHeight + verticalPadding, width: borderWidth, height: 1)
        borderLayer.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        
        label.layer.addSublayer(borderLayer)
    }
    
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // 키보드가 보여질 때 로직
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            
            // 키보드 높이만큼 뷰 올리기
            self.view.frame.origin.y = -keyboardHeight
            
            // comChatLabel의 제약 조건 변경
            if let comChatLabelConstraint = self.view.constraints.first(where: { $0.identifier == "comChatLabelBottomConstraint" }) {
                comChatLabelConstraint.constant = keyboardHeight
                
                // 애니메이션 효과를 주기 위해 layoutIfNeeded() 호출
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }

    // 키보드가 사라질 때 로직
    @objc func keyboardWillHide(notification: NSNotification) {
        // 뷰 원래 위치로 되돌리기
        self.view.frame.origin.y = 0
        
        // comChatLabel의 제약 조건 원래 값으로 되돌리기
        if let comChatLabelConstraint = self.view.constraints.first(where: { $0.identifier == "comChatLabelBottomConstraint" }) {
            comChatLabelConstraint.constant = 494.67
            
            // 애니메이션 효과를 주기 위해 layoutIfNeeded() 호출
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

