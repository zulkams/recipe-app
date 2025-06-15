//
//  RecipeImageTransitionAnimator.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit

class RecipeImageTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.36
    var originImageView: UIImageView?
    var destinationImageView: UIImageView?
    var isPresenting: Bool = true

    init(originImageView: UIImageView?, destinationImageView: UIImageView?, isPresenting: Bool) {
        self.originImageView = originImageView
        self.destinationImageView = destinationImageView
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        print("RecipeImageTransitionAnimator: animateTransition called")
        print("originImageView: \(String(describing: originImageView)), destinationImageView: \(String(describing: destinationImageView))")
        if let originImageView = originImageView, let destinationImageView = destinationImageView {
            print("origin frame: \(originImageView.frame), dest frame: \(destinationImageView.frame)")
        }
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let originImageView = originImageView,
              let destinationImageView = destinationImageView else {
            transitionContext.completeTransition(true)
            return
        }
        // Use placeholder if image is nil
        let originImage = originImageView.image ?? UIImage(systemName: "photo")

        let containerView = transitionContext.containerView
        let toView = toVC.view!
        toView.frame = transitionContext.finalFrame(for: toVC)
        toView.alpha = 0
        containerView.addSubview(toView)

        // Snapshot of the image
        let imageSnapshot = UIImageView(image: originImage)
        imageSnapshot.contentMode = .scaleAspectFill
        imageSnapshot.clipsToBounds = true
        imageSnapshot.layer.cornerRadius = originImageView.layer.cornerRadius
        imageSnapshot.frame = containerView.convert(originImageView.bounds, from: originImageView)
        containerView.addSubview(imageSnapshot)
        originImageView.isHidden = true
        destinationImageView.isHidden = true

        // Animate
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
            imageSnapshot.frame = containerView.convert(destinationImageView.bounds, from: destinationImageView)
            imageSnapshot.layer.cornerRadius = destinationImageView.layer.cornerRadius
            toView.alpha = 1
        }, completion: { _ in
            originImageView.isHidden = false
            destinationImageView.isHidden = false
            imageSnapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
