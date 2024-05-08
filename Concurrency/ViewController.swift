//
//  ViewController.swift
//  Concurrency
//
//  Created by 이중엽 on 5/8/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var oneImageView: UIImageView!
    @IBOutlet var twoImageView: UIImageView!
    @IBOutlet var threeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    @IBAction func callButtonClicked(_ sender: UIButton) {
        
        // Network.shared.fetchThumbnail { image in
        //
        //     DispatchQueue.main.async {
        //         self.oneImageView.image = image
        //     }
        // }
        
        // Network.shared.fetchThumbnailURLSession { response in
        //     
        //     switch response {
        //     case .success(let success):
        //         
        //         DispatchQueue.main.async {
        //             self.oneImageView.image = success
        //         }
        //     case .failure(let failure):
        //         print(failure)
        //     }
        // }

        
        // Task {
        //     
        //     let result = try await Network.shared.fetchThumbnailAsyncAwait()
        //     oneImageView.image = result
        //     
        //     let result2 = try await Network.shared.fetchThumbnailAsyncAwait()
        //     twoImageView.image = result2
        //     
        //     let result3 = try await Network.shared.fetchThumbnailAsyncAwait()
        //     threeImageView.image = result3
        // }
        
        // 4. AsyncLet
        // Task {
        //     
        //     let images = try await Network.shared.fetchThumbnailAsyncLet()
        //     oneImageView.image = images[0]
        //     twoImageView.image = images[1]
        //     threeImageView.image = images[2]
        // }
        
        // 5. TaskGroup
        Task {
            
            let images = try await Network.shared.fetchThumbnailTaskGroup()
            oneImageView.image = images[10]
            twoImageView.image = images[11]
            threeImageView.image = images[12]
        }
    }
}

