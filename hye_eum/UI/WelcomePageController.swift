//
//  WelcomePage.swift
//  hye_eum
//
//  Created by mobicom on 5/13/24.
//

import UIKit

class WelcomePageController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "isRegistered")
    }
    
    
    
}
