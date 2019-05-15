//
//  FullScreenImageViewController.swift
//  jChat
//
//  Created by Jeevan on 15/05/19.
//  Copyright © 2019 Jeevan. All rights reserved.
//

import UIKit

class FullScreenImageViewController: UIViewController {
    
    @IBOutlet weak var fullImageView: UIImageView!
    var fullImageData : Data?
    override func viewDidLoad() {
        super.viewDidLoad()

        if let imageData = fullImageData {
            fullImageView.image = UIImage(data: imageData)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
