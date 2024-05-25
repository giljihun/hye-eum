//
//  CreateDiaryPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/16/24.
//

import UIKit

class CreateDiaryPageController: UIViewController {
    
    // MARK: - UI Label
    
    @IBOutlet weak var comChatLabel: UILabel!
    @IBOutlet weak var myChatLabel: UILabel!
    
    // MARK: - UI TextField
    
    @IBOutlet weak var myTextField: UITextField!
    
    
    
    // MARK: - UI Button
    
    @IBOutlet weak var enterChatBtn: UIButton!
    @IBOutlet weak var doneChatBtn: UIButton!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Create Diary"
        
        tfConfig(tf: myTextField)
        comlabelConfig(label: comChatLabel)
        mylabelConfig(label: myChatLabel)
        
        // for open animation
        comChatLabel.alpha = 0.0
        myChatLabel.alpha = 0.0
        myTextField.alpha = 0.0
        enterChatBtn.alpha = 0.0
        doneChatBtn.alpha = 0.0
        startAnimation()
        
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
        borderLayer.shadowOpacity = 0.5
        borderLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        borderLayer.shadowRadius = 4.0
        
        tf.layer.addSublayer(borderLayer)
        tf.layer.masksToBounds = false
        
    }
    
    // MARK: - Label Config
    private func comlabelConfig(label: UILabel) {
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.textAlignment = .center
        
        let borderLayer = CALayer()
        borderLayer.frame = label.bounds
        borderLayer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        borderLayer.borderWidth = 1.0
        borderLayer.cornerRadius = 8.0
        
        borderLayer.shadowColor = UIColor.black.cgColor
        borderLayer.shadowOpacity = 0.8
        borderLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        borderLayer.shadowRadius = 4.0
        
        label.layer.addSublayer(borderLayer)
        label.layer.masksToBounds = false
        
        let borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        let borderWidth: CGFloat = 1.0
        let cornerRadius: CGFloat = 8.0
        
        label.layer.borderColor = borderColor
        label.layer.borderWidth = borderWidth
        label.layer.cornerRadius = cornerRadius
        
        let padding: CGFloat = 8.0
        label.frame = CGRect(x: padding, y: label.frame.origin.y, width: label.frame.width - padding * 2.0, height: label.frame.height)
    }
    
    private func mylabelConfig(label: UILabel) {
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        
        let borderLayer = CALayer()
        borderLayer.frame = label.bounds
        borderLayer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        borderLayer.borderWidth = 1.0
        borderLayer.cornerRadius = 8.0
        
        borderLayer.shadowColor = UIColor.black.cgColor
        borderLayer.shadowOpacity = 0.8
        borderLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        borderLayer.shadowRadius = 4.0
        
        label.layer.addSublayer(borderLayer)
        label.layer.masksToBounds = false
        
        let borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        let borderWidth: CGFloat = 1.0
        let cornerRadius: CGFloat = 8.0
        
        label.layer.borderColor = borderColor
        label.layer.borderWidth = borderWidth
        label.layer.cornerRadius = cornerRadius
        
        let padding: CGFloat = 8.0
        label.frame = CGRect(x: padding, y: label.frame.origin.y, width: label.frame.width - padding * 2.0, height: label.frame.height)
    }
}
