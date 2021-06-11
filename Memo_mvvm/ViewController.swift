//
//  ViewController.swift
//  Memo_mvvm
//
//  Created by 박종필 on 2021/06/10.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let buttonBox:UIStackView = UIStackView()
    let buttons:[String] = ["Realm", "CoreData", "Sqlite"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setGUI()
    }

    func setGUI() {
        self.view.addSubview(buttonBox)
        buttonBox.axis = .vertical
        buttonBox.spacing = 10
        buttonBox.snp.makeConstraints({ (make) -> Void in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        })
        
        var tag = 0
        for str in buttons {
            let btn:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            btn.setTitle(str, for: .normal)
            btn.backgroundColor = .red
            btn.tag = tag
            buttonBox.addArrangedSubview(btn)
            
            btn.addTarget(self, action: #selector(onClicked(_:)), for: .touchUpInside)
            
            tag += 1
        }
        
        // - text
        let title:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        title.text = "MVVM + RxSwift + DB"
        title.textAlignment = .center
        title.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(title)
        title.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(buttonBox.snp.top).offset(-100)
            make.centerX.equalTo(buttonBox)
        })
        
        // - navi button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Memo", style: .plain, target: self, action: #selector(addMemo))
    }
    
    @objc func onClicked(_ sender:UIButton) {
        let str = buttons[sender.tag]
        switch str {
        case "Realm":
            let vc = RealmListVC(nibName: "RealmListVC", bundle: nil)
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
        
    }
    
    @objc func addMemo(_ sender:UIButton) {
        let vc = InputVC(nibName: "InputVC", bundle: nil)
        self.present(vc, animated: true, completion: nil)
    }
}

