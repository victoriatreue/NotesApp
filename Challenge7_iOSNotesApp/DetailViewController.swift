//
//  DetailViewController.swift
//  Challenge7_iOSNotesApp
//
//  Created by Victoria Treue on 6/9/21.
//

import UIKit

public var newNote = true

class DetailViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    public var completion: ((String, String, String, Date) -> Void)?
    public var existingNoteCompletion: ((Bool) -> Void)?
    
    var note: Note?
    
    
    // MARK: - Lifecycle Hooks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        titleTextField.delegate = self
        bodyTextView.delegate = self

        // UI Set Up
        titleTextField.becomeFirstResponder()
        navigationItem.largeTitleDisplayMode = .never

        // UI Bar Button Items
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(activityViewController))
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveNote))
        done.tintColor = UIColor.darkGray
        navigationItem.rightBarButtonItem = done
        
        // Navigation Center
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        if let note = note {
            newNote = false
            titleTextField.text = note.title
            bodyTextView.text = note.body
        } else {
            bodyTextView.text = "Type your note here ..."
            bodyTextView.alpha = 0.3
        }
    }
    
    
    // MARK: - Save Note
    
    @objc func saveNote() {
        
        if newNote {
            let date = Date.convertToString(Date())
            if let text = titleTextField.text, !text.isEmpty,
               let body = bodyTextView.text, !body.isEmpty,
               body != "Type your note here ..." {
                completion?(text, bodyTextView.text, date(), Date())
            } else {
                completion = nil 
                navigationController?.popViewController(animated: true)
            }
        }
        
        if !newNote {
            let date = Date.convertToString(Date())
            if let text = titleTextField.text, !text.isEmpty,
               let body = bodyTextView.text, !body.isEmpty,
               body != "Type your note here ..." {
                note?.title = titleTextField.text!
                note?.body = bodyTextView.text
                note?.dateStr = date()
                note?.date = Date()
                existingNoteCompletion?(true)
            }
        }
    }
    
    
    // MARK: - @objc Functions
    
    @objc func activityViewController() {
        
        guard let bodyText = bodyTextView.text, !bodyTextView.text.isEmpty else { return }
        guard let title = titleTextField.text, titleTextField.text != nil else { return }
        
        let combinedText = "\(title)\n\(bodyText)"
        
        let activity = UIActivityViewController(activityItems: [combinedText], applicationActivities: [])
        
        activity.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        
        present(activity, animated: true, completion: nil)
    }
    
    
    // MARK: - Notification Center
    
    @objc func adjustKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bodyTextView.contentInset = .zero
        } else { bodyTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0) }
        
        bodyTextView.scrollIndicatorInsets = bodyTextView.contentInset
        
        let selectedRange = bodyTextView.selectedRange
        bodyTextView.scrollRangeToVisible(selectedRange)
    }
    
}


// MARK: - Text Field Delegate

extension DetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            bodyTextView.becomeFirstResponder()
        }
        return true
    }
}


// MARK: Text View Delegate

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type your note here ..." {
            textView.text = nil
            textView.alpha = 1.0
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Type your note here ..."
            textView.alpha = 0.3
        }
    }
}
