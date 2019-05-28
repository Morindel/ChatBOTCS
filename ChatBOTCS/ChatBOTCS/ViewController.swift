//
//  ViewController.swift
//  ChatBOTCS
//
//  Created by Jakub Kołodziej on 28/05/2019.
//  Copyright © 2019 Jakub Kołodziej. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let chatVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatVC") as? ChatViewController
        
        UIView.animate(withDuration: 0.5) {
            chatVc?.view.frame = CGRect(x: self.view.frame.origin.x, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 20)
            self.view.addSubview((chatVc?.view)!)
            self.addChild(chatVc!)
            self.didMove(toParent: chatVc)
        }
    }


}

