//
//  OptionPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/16/24.
//

import UIKit

class OptionPageController: UIViewController {
    
    // MARK: - UI Label
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var poweredLabel: UILabel!
    @IBOutlet weak var sponsoredLabel: UILabel!
    @IBOutlet weak var developedLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var politeLabel: UILabel!
    @IBOutlet weak var birthLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    
    // MARK: - UI Input Field
    @IBOutlet weak var nameField: UITextField!
    
    // MARK: - UI Button
    @IBOutlet weak var nameBtn: UIButton!
    
    // MARK: - UI Switche
    @IBOutlet weak var politeToggle: UISwitch!
    
    // MARK: - UI DatePicker
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    
    // MARK: - Property
    var isEnabled = false
    var currentNickName = ""
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.alpha = 0.0
        self.poweredLabel.alpha = 0.0
        self.sponsoredLabel.alpha = 0.0
        self.developedLabel.alpha = 0.0
        self.nameLabel.alpha = 0.0
        self.politeLabel.alpha = 0.0
        self.nameField.alpha = 0.0
        self.nameBtn.alpha = 0.0
        self.politeToggle.alpha = 0.0
        self.birthLabel.alpha = 0.0
        self.birthDatePicker.alpha = 0.0
        self.editBtn.alpha = 0.0
        self.nameBtn.imageView?.contentMode = .scaleAspectFit
        
        
        tfConfig(tf: nameField)
        nameField.isEnabled = false
        nameField.textColor = UIColor.lightGray
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startAnimation()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.movingLabel()
            
            UIView.animate(withDuration: self.fadeDuration) {
                self.nameLabel.alpha = 1.0
                self.nameField.alpha = 1.0
                self.nameBtn.alpha = 1.0
                self.politeLabel.alpha = 1.0
                self.politeToggle.alpha = 1.0
                self.birthLabel.alpha = 1.0
                self.birthDatePicker.alpha = 1.0
                self.editBtn.alpha = 1.0
            }
            self.titleLabel.translatesAutoresizingMaskIntoConstraints = true
            self.poweredLabel.translatesAutoresizingMaskIntoConstraints = true
            self.sponsoredLabel.translatesAutoresizingMaskIntoConstraints = true
            self.developedLabel.translatesAutoresizingMaskIntoConstraints = true
        }
    }
    
    
    // MARK: - 유저정보 변경 메서드
    func infoChanging() {
        
    }
    
    // MARK: - 애니메이션 메서드
    let fadeDuration: TimeInterval = 1.0
    
    private func startAnimation() {
        
        UIView.animate(withDuration: fadeDuration) {
            self.titleLabel.alpha = 1.0
            self.poweredLabel.alpha = 1.0
            self.sponsoredLabel.alpha = 1.0
            self.developedLabel.alpha = 1.0
            
        }
    }
    // MARK: - 시작 레이아웃 애니메이션 메서드
    private func movingLabel() {
        UIView.animate(withDuration: fadeDuration) {
            self.titleLabel.center.y = self.view.safeAreaInsets.top + self.titleLabel.frame.height / 2 + 20
            
            let bottomY = self.view.bounds.height - self.view.safeAreaInsets.bottom
            let spacing: CGFloat = 8.0
            
            self.developedLabel.center.y = bottomY - spacing - 15
            self.sponsoredLabel.center.y = self.developedLabel.center.y - self.developedLabel.frame.height - spacing
            self.poweredLabel.center.y = self.sponsoredLabel.center.y - self.sponsoredLabel.frame.height - spacing
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
        
        
        if let userName = UserDefaults.standard.string(forKey: "user_name") {
            tf.text = userName
            print("User Name: \(userName)")
        } else {
            print("User Name이 존재하지 않습니다.")
        }
    }
    
    // MARK: - Name Edit 메서드
    @IBAction func editBtnTapped(_ sender: UIButton) {
        isEnabled.toggle()
        
        nameField.isEnabled = isEnabled
        politeToggle.isEnabled = isEnabled
        birthDatePicker.isEnabled = isEnabled
        
        if isEnabled {
            nameField.textColor = UIColor.black
            nameBtn.setBackgroundImage(UIImage(systemName: "checkmark"), for: .normal)
            nameBtn.imageView?.contentMode = .scaleAspectFit
            
            politeToggle.onTintColor = UIColor.tintColor
            birthDatePicker.tintColor = UIColor.black
            
        } else {
            nameField.textColor = UIColor.gray
            nameBtn.setBackgroundImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
            nameBtn.imageView?.contentMode = .scaleAspectFit
            
            politeToggle.onTintColor = UIColor.gray
            birthDatePicker.tintColor = UIColor.gray
        }
        
        // 입력된 텍스트를 저장해두기
        if let currentName = nameField.text {
            currentNickName = currentName
        }
        
    }
    // MARK: - Polite Switch 메서드
    private func ptConfig() {
        let userPolite = UserDefaults.standard.bool(forKey: "user_polite")
        
        print("User Polite: \(userPolite)")
        
        if userPolite == false {
            politeToggle.isOn = false
        } else {
            politeToggle.isOn = true
        }
    }
}
