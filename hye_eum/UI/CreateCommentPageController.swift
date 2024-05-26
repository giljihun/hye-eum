//
//  CreateCommentPageController.swift
//  hye_eum
//
//  Created by mobicom on 5/26/24.
//

import UIKit

class CreateCommentPageController: UIViewController {

    // MARK: - Properties
    var qnaString: String = ""
    var emotion: String = ""
    var imageURL: String = ""
    
    // MARK: - UI ImageView
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print(qnaString)
        print(emotion)
    }

    // MARK: - Methods
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        task.resume()
    }
    
}
