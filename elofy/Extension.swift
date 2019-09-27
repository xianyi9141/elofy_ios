//
//  Jiggyo+types.swift
//  Jiggyo
//
//  Created by raptor on 10/01/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func toDate(from: String = "yyyy-MM-dd", to: String = "dd/MM/yyyy") -> String {
        let df = DateFormatter()
        df.dateFormat = from
        guard let date = df.date(from: self) else { return self }
        df.dateFormat = to
        return df.string(from: date)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        get { return UIColor(cgColor: layer.shadowColor!) }
        set { layer.shadowColor = newValue?.cgColor }
    }

    @IBInspectable var shadowSizeX: CGFloat {
        get { return layer.shadowOffset.width }
        set { layer.shadowOffset = CGSize(width: newValue, height: shadowSizeY) }
    }

    @IBInspectable var shadowSizeY: CGFloat {
        get { return layer.shadowOffset.height }
        set { layer.shadowOffset = CGSize(width: shadowSizeX, height: newValue) }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = min(newValue, 1) }
    }

    func lock() {
        if let _ = viewWithTag(10) {
            //View is already locked
        }
        else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
            lockView.tag = 10
            lockView.alpha = 0.0
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            lockView.addSubview(activity)
            activity.startAnimating()
            addSubview(lockView)

            UIView.animate(withDuration: 0.2) {
                lockView.alpha = 1.0
            }
        }
    }

    func unlock() {
        if let lockView = viewWithTag(10) {
            UIView.animate(withDuration: 0.2, animations: {
                lockView.alpha = 0.0
            }) { finished in
                lockView.removeFromSuperview()
            }
        }
    }

    func fadeOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }

    func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }

    func constraint(_ identifier: String) -> NSLayoutConstraint? {
        return constraints.filter { $0.identifier == identifier }.first
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    open class var sky: UIColor { return UIColor(rgb: 0x19C9FB) }
    open class var grass: UIColor { return UIColor(rgb: 0x80C783) }
}

extension UITextField {
    func addToolbar(
        doneTitle: String? = nil,
        onDone: (target: Any, action: Selector)? = nil,
        cancelTitle: String? = nil,
        onCancel: (target: Any, action: Selector)? = nil) {

        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: cancelTitle ?? "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneTitle ?? "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

