//
//  File.swift
//  
//
//  Created by suranga fernando on 22/1/21.
//

import Foundation
import UIKit

@objc public class  SFBottomAlertSheetViewController:UIViewController {
    
    static let kSGStoryboardName: String = "SGPopupViewStoryBoard"
    
    // Class Constants
    private let kSGImageViewSize = CGSize(width: 72.0, height: 72.0)
    private let kSGMainViewCornerRadius: CGFloat = 20.0
    private var kSGContainerHeight: CGFloat = 24.0
    private let kSGMainViewSpaceBetweenItems: CGFloat = 24.0
    private let kSGMainViewLastItemBottomPadding: CGFloat = 32.0
    private let kSGButtonHeight: CGFloat = 44.0
    private let kSGButtonLeftRightPadding: CGFloat = 24.0
    private let kSGTextLeftRightPadding: CGFloat = 40.0
    private let kSGTitleHeight: CGFloat = 20.0
    private let kSGSubTitleHeight: CGFloat = 60.0
    private let KSGAnimationDuration: TimeInterval = 0.4
    
    // Configuration variables
    @objc var dismissOnOutsideTap: Bool = false
    @objc var dismissOnAction: Bool = true
    
    @objc var image: UIImage?
    @objc var titleText: String?
    @objc var subTitleText: String?
    @objc var actionButtonTitle: String = NSLocalizedString("Done", comment: "")
    @objc var dismissButtonTitle: String?
    
    @objc var onDismissClosure: () -> Void = {}
    @objc var onActionClosure: () -> Void = {}
    @objc var onLoadClosure: () -> Void = {}
    
    @IBOutlet public var mainView: UIView!
    
    @objc
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        self.mainView.removeFromSuperview()
    }
    
    @IBAction func dismissPopupOnTap(_ sender: Any) {
        if dismissOnOutsideTap {
            self.moveContainerOffScreen()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mainView.frame = self.offScreenRect()
        if #available(iOS 11.0, *) {
            self.view.layer.cornerRadius = CGFloat(kSGMainViewCornerRadius)
            self.view.clipsToBounds = true
            self.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
        } else {
            // Fallback on earlier versions
        }
        self.view.addSubview(self.mainView)
        self.moveContainerOnScreen()
    }
    
    func setUpView() {
        
        if let image = self.image {
            let imageView = UIImageView(frame: CGRect(x: (self.view.bounds.size.width / 2) - (kSGImageViewSize.width / 2), y: kSGContainerHeight, width: kSGImageViewSize.width, height: kSGImageViewSize.height))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            self.mainView.addSubview(imageView)
            self.kSGContainerHeight += kSGImageViewSize.height + kSGMainViewSpaceBetweenItems
        }
        
        if let title = self.titleText {
            let titleLabel = UILabel(frame: CGRect(x: kSGTextLeftRightPadding, y: self.kSGContainerHeight, width: self.view.bounds.size.width - kSGTextLeftRightPadding * 2, height: kSGTitleHeight))
            titleLabel.text = title
            //titleLabel.font = SGFonts.alertTitle
            //titleLabel.textColor = UIColor.appColor(SGAssetsColor.navy1400)!
            titleLabel.textAlignment = .center
            self.mainView.addSubview(titleLabel)
            
            self.kSGContainerHeight += kSGTitleHeight + kSGMainViewSpaceBetweenItems
        }
        
        if let subTitle = self.subTitleText {
            let subTitleLabel = UILabel(frame: CGRect(x: kSGTextLeftRightPadding, y: self.kSGContainerHeight, width: self.view.frame.size.width - kSGTextLeftRightPadding * 2, height: kSGSubTitleHeight))
            subTitleLabel.text = subTitle
            subTitleLabel.numberOfLines = .zero
           // subTitleLabel.font = SGFonts.body1
            subTitleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            subTitleLabel.textAlignment = .center
           // subTitleLabel.textColor = UIColor.appColor(SGAssetsColor.navy1400)!
            // To a dynamic size to fit to the content
            subTitleLabel.sizeToFit()
            let newDynamicHeight = subTitleLabel.bounds.size.height
            // Set a new frame  using new dynamic height
            subTitleLabel.frame = CGRect(x: kSGTextLeftRightPadding, y: self.kSGContainerHeight, width: self.view.frame.size.width - kSGTextLeftRightPadding * 2, height: newDynamicHeight)
            
            self.mainView.addSubview(subTitleLabel)
            
            self.kSGContainerHeight += newDynamicHeight + kSGMainViewSpaceBetweenItems
        }
        
        let actionButton = UIButton(frame: CGRect(x: kSGButtonLeftRightPadding, y: self.kSGContainerHeight, width: self.view.frame.size.width - kSGButtonLeftRightPadding * 2, height: kSGButtonHeight))
        actionButton.setTitle(self.actionButtonTitle, for: .normal)
        //actionButton.titleLabel?.font = SGFonts.buttonFonts
        actionButton.addTarget(self, action: #selector(actionClicked), for: .touchUpInside)
        self.mainView.addSubview(actionButton)
        
        if let dismissButtonTitle = self.dismissButtonTitle {
            self.kSGContainerHeight += kSGButtonHeight + kSGMainViewSpaceBetweenItems
            
            let dismissButton = UIButton(frame: CGRect(x: kSGButtonLeftRightPadding, y: self.kSGContainerHeight, width: self.view.frame.size.width - kSGButtonLeftRightPadding * 2, height: kSGButtonHeight ))
            dismissButton.setTitle(dismissButtonTitle, for: .normal)
            dismissButton.addTarget(self, action: #selector(dismissClicked), for: .touchUpInside)
            
            self.mainView.addSubview(dismissButton)
            
            if #available(iOS 11.0, *) {
                self.kSGContainerHeight += kSGButtonHeight + kSGMainViewLastItemBottomPadding + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            if #available(iOS 11.0, *) {
                self.kSGContainerHeight += kSGButtonHeight + kSGMainViewSpaceBetweenItems + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom)!
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @objc
    func dismissClicked(_ sender: UIButton) {
        self.moveContainerOffScreen()
    }
    
    @objc
    func actionClicked(_ sender: UIButton) {
        self.onActionClosure()
        if self.dismissOnAction {
            self.moveContainerOffScreen()
        }
    }
    
    func onScreenRect() -> CGRect {
        let offsetX: CGFloat = .zero
        let offsetY: CGFloat = self.view.bounds.height - self.mainView.bounds.height
        
        return CGRect(x: offsetX, y: offsetY, width: self.view.bounds.width, height: self.kSGContainerHeight)
    }
    
    func offScreenRect() -> CGRect {
        let offsetX: CGFloat = .zero
        let offsetY: CGFloat = self.view.bounds.height
        
        return CGRect(x: offsetX, y: offsetY, width: self.view.bounds.width, height: self.kSGContainerHeight)
    }
    
    func moveContainerOnScreen() {
        UIView.animate(withDuration: KSGAnimationDuration, delay: .zero, animations: {
            self.mainView.frame = self.onScreenRect()
            self.view.setNeedsLayout()
        }, completion: { (_: Bool) in
            self.onLoadClosure()
        })
    }
    
    func moveContainerOffScreen() {
        UIView.animate(withDuration: KSGAnimationDuration, delay: .zero, animations: {
            self.mainView.frame = self.offScreenRect()
            self.view.setNeedsLayout()
        }, completion: { (_: Bool) in
            self.dismiss(animated: true) {
                self.onDismissClosure()
            }
        })
    }
    
    @objc
    func present() {
        self.setUpView()
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(self, animated: true, completion: nil)
        }
    }
    
    @objc
    static func viewControllerFromStoryBoard() -> SFBottomAlertSheetViewController {
        let storyboard = UIStoryboard(name: kSGStoryboardName, bundle: nil)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "SFBottomAlertSheetViewController") as! SFBottomAlertSheetViewController
        viewController.providesPresentationContextTransitionStyle = true
        viewController.definesPresentationContext = true
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewController.view.backgroundColor = UIColor(red: .zero, green: .zero, blue: .zero, alpha: 0.6)
        return viewController
    }
    
    static func alertWith(title: String?, description: String?, image: UIImage?, actionButtonText: String?, dismissButtonText: String?) -> SFBottomAlertSheetViewController {
        let viewController = viewControllerFromStoryBoard()
        
        viewController.image = image
        viewController.titleText = title
        viewController.subTitleText = description
        
        if let text = actionButtonText {
            viewController.actionButtonTitle = text
        }
        viewController.dismissButtonTitle = dismissButtonText
        return viewController
    }
    
    static func alertWith(title: String?, description: String?, image: UIImage?, actionButtonText: String?) -> SFBottomAlertSheetViewController {
        let viewController = viewControllerFromStoryBoard()
        
        viewController.image = image
        viewController.titleText = title
        viewController.subTitleText = description
        
        if let text = actionButtonText {
            viewController.actionButtonTitle = text
        }
        viewController.dismissButtonTitle = nil
        return viewController
    }
    
}
