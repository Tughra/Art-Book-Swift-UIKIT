//
//  DetailBookViewController.swift
//  MyArtBook
//
//  Created by Tugra Zeyrek on 17.12.2022.
//

import UIKit

class DetailBookViewController: UIViewController {
    
    let name:String?;
    let image:UIImage?;
    init(name: String?, image: UIImage?) {
        self.name = name;
        self.image = image;
        super.init(nibName: nil, bundle: nil);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
   
    override func viewDidLoad() {
        
        let dataLabel:UIImageView = UIImageView();
        let width:Double = view.frame.size.width;
        let height:Double = view.frame.size.height;
        dataLabel.image = image;
        dataLabel.frame = CGRect(x: 0 ,y: 0.5*(height-width), width: width, height: width);
        view.backgroundColor = .white;
        navigationItem.title = name;
        view.addSubview(dataLabel);
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
