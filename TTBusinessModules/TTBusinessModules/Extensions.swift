//
//  Extensions.swift
//  NMBusinessModules
//
//  Created by MnzfM on 8.03.2021.
//

import UIKit
import TTBaseModel

extension UIStoryboard {
    func instance<T: UIViewController>(of type: T.Type) -> T {
        let identifier = String(describing: T.self)
        return self.instantiateViewController(withIdentifier: identifier) as! T
    }
}

extension Date {
    
    init(dateString:String, format:String="yyyy-MM-dd" ) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        //(self as NSDate).type(of: init)(timeInterval:0, since:d)
        self.init(timeInterval:0, since:d)
    }
    
    static func from(_ year:Int, month:Int, day:Int) -> Date {
        var c = DateComponents()
        c.year = year
        c.month = month
        c.day = day
        
        let gregorian = Calendar(identifier:Calendar.Identifier.gregorian)
        let date = gregorian.date(from: c)
        return date!
    }
    
    static func parse(_ dateStr:String, format:String="yyyy-MM-dd") -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = format
        dateStringFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateStringFormatter.date(from: dateStr)!
    }

    static func time(_ date:Date) -> String {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "HH:mm"
        dateStringFormatter.timeZone = TimeZone(secondsFromGMT: 3600*3)
        dateStringFormatter.locale = Locale(identifier: "tr_TR")
//        dateStringFormatter.timeZone = TimeZone.current
//        dateStringFormatter.locale = Locale.current
        return dateStringFormatter.string(from: date)
    }
    
    static func timeStringToDate(_ date: String) -> Date {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "HH:mm"
        dateStringFormatter.timeZone = TimeZone(secondsFromGMT: 3600*3)
        dateStringFormatter.locale = Locale(identifier: "tr_TR")
        return dateStringFormatter.date(from: date)!
    }
    
    static func hour(_ date:Date) -> Int {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "HH"
        dateStringFormatter.timeZone = TimeZone.current
        dateStringFormatter.locale = Locale.current
        return Int(dateStringFormatter.string(from: date))!
    }
    
    static func minute(_ date:Date) -> Int {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "mm"
        dateStringFormatter.timeZone = TimeZone.current
        dateStringFormatter.locale = Locale.current
        return Int(dateStringFormatter.string(from: date))!
    }
    
    static func stringFromTimeInterval(_ interval:TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        let ms = Int((interval.truncatingRemainder(dividingBy: 1)) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
    
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }
    
    static func timeFromTimeInterval(_ interval:TimeInterval) -> (hour:Int, minute:Int, second: Int) {
        
        let ti = NSInteger(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return (hours,minutes,seconds)
    }
    
    func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
        let delta = TimeInterval(initTimeZone.secondsFromGMT() - targetTimeZone.secondsFromGMT())
        return addingTimeInterval(delta)
    }
}

extension BaseViewModel {
    @discardableResult
    func handle<R, T>(result: Result<R, BaseError>, withSetState: Bool = true) -> T? where R: BaseResponse<T>, T: Model {
        switch result {
        case .success(let response):
            if withSetState {
                state.value = .populate
            }
            return response.data
        case .failure(_):
            if withSetState {
                state.value = .error
            }
//            errorState.value = .server(error)
        }
        return nil
    }
}

extension UIView {
    
    open var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    open var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    open var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    open var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
    
    open var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leadingAnchor
        }
        return leadingAnchor
    }
    
    open var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.trailingAnchor
        }
        return trailingAnchor
    }
    
    open var safeCenterXAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.centerXAnchor
        }
        return centerXAnchor
    }
    
    open var safeCenterYAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.centerYAnchor
        }
        return centerYAnchor
    }
    
    open var safeHeightAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.heightAnchor
        }
        return heightAnchor
    }
    
    open var safeWidthAnchor: NSLayoutDimension {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.widthAnchor
        }
        return widthAnchor
    }
    
    enum FillOption {
        case center
        case fill
        case fillTop
        case fillBottom
        case fillBottomOfTop
    }
    
    func fillSuperView(with option: FillOption) {
        guard let superView = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch option {
        case .center:
            NSLayoutConstraint.activate([
                self.safeCenterXAnchor.constraint(equalTo: superView.safeCenterXAnchor),
                self.safeCenterYAnchor.constraint(equalTo: superView.safeCenterYAnchor),
            ])
        case .fill:
            NSLayoutConstraint.activate([
                self.safeTopAnchor.constraint(equalTo: superView.safeTopAnchor),
                self.safeBottomAnchor.constraint(equalTo: superView.safeBottomAnchor),
                self.safeLeadingAnchor.constraint(equalTo: superView.safeLeadingAnchor),
                self.safeTrailingAnchor.constraint(equalTo: superView.safeTrailingAnchor)
                ])
        case .fillTop:
            NSLayoutConstraint.activate([
                self.safeTopAnchor.constraint(equalTo: superView.safeTopAnchor),
                self.safeLeadingAnchor.constraint(equalTo: superView.safeLeadingAnchor),
                self.safeTrailingAnchor.constraint(equalTo: superView.safeTrailingAnchor)
            ])
        case .fillBottom:
            NSLayoutConstraint.activate([
                self.safeBottomAnchor.constraint(equalTo: superView.safeBottomAnchor),
                self.safeLeadingAnchor.constraint(equalTo: superView.safeLeadingAnchor),
                self.safeTrailingAnchor.constraint(equalTo: superView.safeTrailingAnchor)
            ])
        case .fillBottomOfTop:
            NSLayoutConstraint.activate([
                self.safeBottomAnchor.constraint(equalTo: superView.safeTopAnchor),
                self.safeLeadingAnchor.constraint(equalTo: superView.safeLeadingAnchor),
                self.safeTrailingAnchor.constraint(equalTo: superView.safeTrailingAnchor)
            ])
        }
    }
    
    func setGradientBackground(colors: [CGColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.shouldRasterize = true
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}


// MARK: - View Controller
extension UIViewController {
    
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
    
    func add(child: UIViewController, to containerView: UIView) {

        addChild(child)
        child.view.frame = containerView.bounds
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
