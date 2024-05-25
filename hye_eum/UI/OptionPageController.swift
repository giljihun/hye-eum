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
    
    // MARK: - UI Switch
    @IBOutlet weak var politeToggle: UISwitch!
    
    // MARK: - UI DatePicker
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    
    // MARK: - Property
    var isEnabled = false
    var currentNickName = ""
    var currentPolite: Bool = false
    var currentBirth: Date = Date()
    let savedUserTag = UserDefaults.standard.integer(forKey: "user_tag")
    
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
        politeToggle.isEnabled = false
        birthDatePicker.isEnabled = false
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
        infoCalling()
    }
    
    
    // MARK: - 유저정보 호출 메서드
    func infoCalling() {
        print("calling!")
        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/users/\(savedUserTag)") else {
            print("Invalid URL")
            return
        }
        
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
                DispatchQueue.main.async {
                    if let userName = jsonResult["user_name"] as? String {
                        self.nameField.text = userName
                        self.currentNickName = userName
                        print(userName)
                    }
                    
                    if let birthString = jsonResult["birth"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        if let birthDate = dateFormatter.date(from: birthString) {
                            self.birthDatePicker.date = birthDate
                            self.currentBirth = birthDate
                        }
                        
                        print(birthString)
                    }
                    
                    if let isPolite = jsonResult["polite"] as? Bool {
                        self.politeToggle.isOn = isPolite
                        self.currentPolite = isPolite
                        print(isPolite)
                    }
                }
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }
    task.resume()
}

    // MARK: - 유저정보 변경 메서드
    func infoEditing() {
        print("editing!")
        
        print(currentBirth, currentPolite, currentNickName)
        guard let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/users/\(savedUserTag)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedUserNames = currentNickName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthDateString = dateFormatter.string(from: currentBirth)
        
        let requestBody: [String: Any] = [
            "user_name": updatedUserNames,
            "birth": birthDateString,
            "polite": currentPolite
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            // Handle the response if needed
            print("User info updated successfully")
        }
        
        task.resume()
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
    
    }
    
    // MARK: - Name Edit 메서드
    @IBAction func editBtnTapped(_ sender: UIButton) {
        isEnabled.toggle()
        
        nameField.isEnabled = isEnabled
        politeToggle.isEnabled = isEnabled
        birthDatePicker.isEnabled = isEnabled
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear], animations: {
            if self.isEnabled {
                self.nameField.textColor = UIColor.black
                self.nameBtn.setBackgroundImage(UIImage(systemName: "checkmark"), for: .normal)
                self.nameBtn.imageView?.contentMode = .scaleAspectFit
                self.nameBtn.tintColor = .black
                self.politeToggle.onTintColor = UIColor.tintColor
                self.birthDatePicker.tintColor = UIColor.black
            } else {
                self.nameField.textColor = UIColor.gray
                self.nameBtn.setBackgroundImage(UIImage(systemName: "pencil.and.outline"), for: .normal)
                self.nameBtn.imageView?.contentMode = .scaleAspectFit
                self.nameBtn.tintColor = .gray
                self.politeToggle.onTintColor = UIColor.gray
                self.birthDatePicker.tintColor = UIColor.gray
            }
        }, completion: nil)
        // 변경 사항이 있는지 확인
        var isChanged = false
        
        if let currentName = self.nameField.text, currentName != self.currentNickName {
            print(currentName)
            self.currentNickName = currentName
            isChanged = true
        }
        
        if self.politeToggle.isOn != self.currentPolite {
            print(self.politeToggle.isOn)
            self.currentPolite = self.politeToggle.isOn
            isChanged = true
        }
        
        if self.birthDatePicker.date != self.currentBirth {
            print(self.birthDatePicker.date)
            self.currentBirth = self.birthDatePicker.date
            isChanged = true
        }
        
        // 변경 사항이 있으면 PATCH 요청 보내기
        if isChanged {
            self.infoEditing()
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
