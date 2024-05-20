//
//  InfoPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/16/24.
//

import UIKit

class InputPageController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var inputBtn: UIButton!
    
    // 질문, 질문 : 답변 저장 배열
    let questions: [String] = [
        "만약 당신의 성격이 음식이라면, 그 음식은 무엇일까요?",
        "만약 당신의 삶이 책 한 권이라면, 그 책의 제목은 무엇이 될까요?",
        "만약 당신의 일상 생활이 영화 속 한 장면이라면, 어떤 장면이 될 것 같나요?",
        "만약 당신의 성격이 동물로 비유된다면, 어떤 동물이 가장 잘 어울릴까요?",
        "만약 당신이 특별한 수퍼파워를 한 가지 가질 수 있다면, 그것은 무엇이 되고 싶나요?",
        "당신이 하나의 색으로 표현된다면, 그 색은 무엇인가요?",
        "만약 당신이 오늘의 날씨라면, 어떤 날씨가 될 것 같나요?",
        "만약 당신의 취미가 하나의 노래로 표현된다면, 그 노래는 무엇인가요?",
        "만약 당신의 삶이 하나의 영화라면, 그 영화의 장르는 무엇이 될 것 같나요?",
        "당신이 하나의 계절로 비유된다면, 그 계절은 무엇인가요?",
        "당신이 좋아하는 동화 속 캐릭터는 누구인가요?",
        "당신이 좋아하는 음악 장르가 있다면, 그 장르는 무엇인가요?",
        "당신이 오늘 무엇을 하루 종일 할 수 있다면, 무엇을 하고 싶나요?",
        "당신이 좋아하는 스포츠가 있다면, 그 스포츠는 무엇인가요?",
        "당신이 가장 좋아하는 요리는 무엇인가요?",
        "당신이 좋아하는 영화 장르가 있다면, 그 장르는 무엇인가요?",
        "만약 당신의 성격이 하나의 도시로 비유된다면, 어떤 도시가 어울릴까요?",
        "당신이 가장 좋아하는 계절은 어느 것인가요?",
        "당신이 아침을 시작할 때, 가장 좋아하는 방법은 무엇인가요?",
        "당신이 휴식을 취할 때, 선호하는 방식은 무엇인가요?",
        "당신의 성격을 나타내는 한 마디는 무엇인가요?"
    ]
    var usedQuestions: Set<String> = []
    var questionIndex: Int = 0
    
    var savedQnA: [(question: String, answer: String)] = []
    
    // 애니메이션
    let fadeDuration: TimeInterval = 1.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 키보드 나타남/사라짐을 감지하는 Notification 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
           tap.cancelsTouchesInView = false
           view.addGestureRecognizer(tap)
        
        questionLabel.alpha = 0.0
        
        inputTextField.delegate = self
        // 기본 테두리 스타일 설정
        inputTextField.borderStyle = .none
        inputTextField.layer.cornerRadius = 8.0
        inputTextField.layer.borderWidth = 1.0
        inputTextField.placeholder = "Enter your mind"
        inputTextField.layer.borderColor = UIColor.lightGray.cgColor
        inputTextField.autocorrectionType = .no
        
        // 텍스트 필드 좌측 여백 설정
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: inputTextField.frame.height))
        inputTextField.leftView = paddingView
        inputTextField.leftViewMode = .always
        
        configureQuestionLabel()
        presentQuestion()
    }
    
    // 멘트 디자인
    private func configureQuestionLabel() {
        questionLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        questionLabel.textColor = .darkGray
        questionLabel.numberOfLines = 0 // 여러 줄 표시 허용
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.textAlignment = .center
    }
    
    // 질문 로직
    func presentQuestion() {
        if questionIndex < 5 {
            let randomQuestion = getRandomQuestion()
            questionLabel.text = randomQuestion
            questionLabel.numberOfLines = 0
            questionLabel.lineBreakMode = .byWordWrapping
            questionLabel.textAlignment = .center
            UIView.animate(withDuration: fadeDuration) {
                self.questionLabel.alpha = 1.0
            }
            usedQuestions.insert(randomQuestion)
            questionIndex += 1
        } else {
            // 질문이 다 끝났을 때
            displayFinalMessage()
        }
    }
    
    func getRandomQuestion() -> String {
        let remainingQuestions = questions.filter { !usedQuestions.contains($0) }
        guard let randomQuestion = remainingQuestions.randomElement() else {
            return "No more questions"
        }
        return randomQuestion
    }
    
    @IBAction func submitAnswer(_ sender: UIButton) {
        guard let answer = inputTextField.text, !answer.isEmpty else {
            return
        }
        
        let question = questionLabel.text ?? ""
        savedQnA.append((question: "Q. \(question)", answer: "A. \(answer)"))
        
        inputTextField.text = ""
        
        questionLabel.alpha = 0.0
        presentQuestion()
    }
    
    // 리턴버튼으로 제출버튼 누르기
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // 키보드 숨기기
        submitAnswer(UIButton()) // 제출 액션 수행
        return true
    }
    
    // 5회 답변이 끝날때 나오는 메시지
    func displayFinalMessage() {
        let finalMessage = "음..! 당신에 대해서 알아갈 수 있어서 좋아요! \n 추가적으로 몇가지만 더 물어볼게요!"
        questionLabel.text = finalMessage
        UIView.animate(withDuration: fadeDuration) {
            self.questionLabel.alpha = 1.0
        }
        inputTextField.alpha = 0.0
        inputBtn.alpha = 0.0

        print(savedQnA)
        
    }
    
    // 키보드가 보여질 때 로직
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            self.view.frame.origin.y = -keyboardHeight / 2 // 필요에 따라 조정
        }
    }
    
    // 키보드 사라질 때 로직
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}
