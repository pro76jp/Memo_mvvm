//
//  InputVC.swift
//  Memo_mvvm
//
//  Created by 박종필 on 2021/06/10.
//

import UIKit
import GrowingTextView
import SnapKit
import Toaster

class InputVC: UIViewController {
    
    private var inputToolbar: UIView!
    private var textView: GrowingTextView!
    private var textViewBottomConstraint: NSLayoutConstraint!
    
    let Picker = UIImagePickerController()
    let memoBox:UIStackView = UIStackView()
    var memoImage:UIImageView?
    let memoContent:UILabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        setGUI()
    }


    func setGUI() {
        self.view.addSubview(memoBox)
        memoBox.axis = .vertical
        memoBox.spacing = 10
        memoBox.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(self.view.snp.top).offset(8)
            make.left.equalTo(self.view.snp.left)
        })
        
        // *** Create Toolbar
        inputToolbar = UIView()
        inputToolbar.backgroundColor = .systemGray
        inputToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputToolbar)
        
        // *** Create GrowingTextView ***
        textView = GrowingTextView()
        textView.delegate = self
        textView.layer.cornerRadius = 4.0
        textView.maxLength = 200
        textView.maxHeight = 70
        textView.trimWhiteSpaceWhenEndEditing = true
        textView.placeholder = "memo add ...."
        textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.translatesAutoresizingMaskIntoConstraints = false
        inputToolbar.addSubview(textView)
        
        // - image add button
        let btnImageAdd:UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        btnImageAdd.backgroundColor = .blue
        inputToolbar.addSubview(btnImageAdd)
        btnImageAdd.addTarget(self, action: #selector(onAddImage), for: .touchUpInside)

        // *** Autolayout ***
//        inputToolbar.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(self.view.snp.left)
//            make.right.equalTo(self.view.snp.right)
//            make.bottom.equalTo(self.view.snp.bottom)
//            make.top.equalTo(textView.snp.top).offset(-8)
//        })
        let topConstraint = textView.topAnchor.constraint(equalTo: inputToolbar.topAnchor, constant: 8)
        topConstraint.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            inputToolbar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            inputToolbar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            inputToolbar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            topConstraint
        ])
        
        btnImageAdd.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(inputToolbar.snp.right).offset(-8)
            make.top.equalTo(inputToolbar.snp.top).offset(8)
        })

//        textView.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(inputToolbar.snp.left).offset(8)
//            make.right.equalTo(inputToolbar.snp.right).offset(-8)
//            make.bottom.equalTo(inputToolbar.safeAreaLayoutGuide.snp.bottom).offset(8)
//        })
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: inputToolbar.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: btnImageAdd.leadingAnchor, constant: -8),
            textViewBottomConstraint
            ])
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = -keyboardHeight - 8
            view.layoutIfNeeded() // TODO: sanpkit 사용시 여기서 문제 .
            
//            textView.snp.makeConstraints({ (make) -> Void in
////                make.left.equalTo(inputToolbar.snp.left).offset(8)
////                make.right.equalTo(inputToolbar.snp.right).offset(-8)
////                make.bottom.equalTo(inputToolbar.safeAreaLayoutGuide.snp.bottom).offset(8)
//                make.bottom.equalTo(inputToolbar.snp.bottom).offset(-keyboardHeight - 8)
//            })
        }
    }
    
    @objc private func tapGestureHandler() {
        view.endEditing(true)
    }
    
    @objc func onAddImage() {
        // https://github.com/hyperoslo/Gallery
        
        self.Picker.sourceType = .photoLibrary
        self.Picker.allowsEditing = true
        self.Picker.mediaTypes = ["public.image"]
        self.Picker.delegate = self
        self.present(self.Picker, animated: true)
    }
}

extension InputVC: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
       UIView.animate(withDuration: 0.2) {
           self.view.layoutIfNeeded()
       }
    }
    
    func textViewDidChange(_ textView: UITextView) {
            
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
}

extension InputVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        
        
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                print("Image Selected")
                
                guard let image = info[.editedImage] as? UIImage else {
                    Toast(text: "이미지 없당..").show()
                    return
                }
                if memoImage == nil {
                    memoImage = UIImageView()
                }
                memoImage!.image = image
                memoBox.addArrangedSubview(memoImage!)
                
            } else {
                Toast(text: "사용못하는 것들..").show()
            }
        }
    }
}
