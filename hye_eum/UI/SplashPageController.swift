//
//  LaunchScreenController.swift
//  hye_eum
//
//  Created by mobicom on 5/13/24.
//

import UIKit

class SplashPageController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        DeviceManager.shared.adjustFontSize(for: titleLabel, textStyle: "splashLogo")
        DeviceManager.shared.adjustFontSize(for: titleLabel2, textStyle: "splashLogo")
    }
}
