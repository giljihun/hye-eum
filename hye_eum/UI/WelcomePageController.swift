//
//  WelcomePage.swift
//  hye_eum
//
//  Created by mobicom on 5/13/24.
//

import UIKit

class WelcomePageController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    @IBOutlet weak var openingMent: UILabel!
    @IBOutlet weak var welcome_nextBtn: UIButton!
    
    @IBOutlet weak var logoTextOne: UILabel!
    @IBOutlet weak var logoTextTwo: UILabel!
    @IBOutlet weak var devByLogo: UILabel!
    
    let openingMents : [String] = [
        "오늘 하루는 어땠나요?",
        "오늘 당신에게는 어떤 일들이 있었나요?",
        "당신의 이야기를 저에게 들려주세요."
    ]
    
    var currentMentIndex = 0
    var mentTimer: Timer?
    // 애니메이션 간격 설정 -> 테스트 이후 2.3, 1.5로 변경 요망
    let mentDuration: TimeInterval = 0.2
    let fadeDuration: TimeInterval = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WelcomePageController instance created")
        welcome_nextBtn.alpha = 0.0
        logoTextOne.alpha = 0.0
        logoTextTwo.alpha = 0.0
        devByLogo.alpha = 0.0
        configureOpeningMentLabel()
        startMentAnimation()
    }
    
    // 멘트 디자인
    private func configureOpeningMentLabel() {
        openingMent.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        openingMent.textColor = .darkGray
        
        openingMent.numberOfLines = 0 // 여러 줄 표시 허용
        openingMent.lineBreakMode = .byWordWrapping
        
        
        let attributedString = NSMutableAttributedString(string: openingMent.text ?? "")
        attributedString.addAttribute(.kern, value: 1.2, range: NSRange(location: 0, length: attributedString.length))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0 // 줄 간격 조정
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        openingMent.attributedText = attributedString
        openingMent.textAlignment = .center
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        //UserDefaults.standard.set(true, forKey: "isRegistered")
    }
    
    private func startMentAnimation() {
        openingMent.text = openingMents[currentMentIndex]
        openingMent.alpha = 0.0
        
        UIView.animate(withDuration: fadeDuration) {
            self.openingMent.alpha = 1.0
        }
        
        mentTimer = Timer.scheduledTimer(withTimeInterval: mentDuration, repeats: false) {
            _ in self.changeMent()
        }
    }
    
    private func scheduleNextMent() {
        mentTimer?.invalidate()
        mentTimer = Timer.scheduledTimer(withTimeInterval: mentDuration, repeats: false, block: { _ in
            self.changeMent()
        })
    }
    
    private func changeMent() {
        UIView.animate(withDuration: fadeDuration) {
            self.openingMent.alpha = 0.0
        } completion: { _ in
            self.currentMentIndex = (self.currentMentIndex + 1) % self.openingMents.count

            if self.currentMentIndex == 0 {
                self.mentTimer?.invalidate()
                self.mentTimer = nil

                // 마무리 멘트!
                self.openingMent.text = "그 전에, 당신에 대해 몇가지 물어볼게요. \n\n 아래 버튼을 눌러주세요."
                UIView.animate(withDuration: self.fadeDuration) {
                    self.openingMent.alpha = 1.0
                    self.welcome_nextBtn.alpha = 1.0
                    self.logoTextOne.alpha = 1.0
                    self.logoTextTwo.alpha = 1.0
                    self.devByLogo.alpha = 1.0
                }
                return
            }

            self.openingMent.text = self.openingMents[self.currentMentIndex]
            UIView.animate(withDuration: self.fadeDuration, animations: {
                self.openingMent.alpha = 1.0
            }, completion: { _ in
                self.scheduleNextMent()
            })
        }
        
    }
}

