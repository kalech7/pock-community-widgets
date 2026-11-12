//
//  NowPlayingItemView.swift
//  Better Now Playing
//
//  Created by Pierluigi Galdi on 17/02/2019.
//  Copyright © 2019 Pierluigi Galdi. All rights reserved.
//

import Foundation
import AppKit
import PockKit

extension String {
    func truncate(length: Int, trailing: String = "…") -> String {
        return self.count > length ? String(self.prefix(length)) + trailing : self
    }
}

class NowPlayingItemView: PKDetailView {
    
    /// Overrideable
    public var didTap: (() -> Void)?
    public var didSwipeLeft: (() -> Void)?
    public var didSwipeRight: (() -> Void)?
    public var didLongPress: (() -> Void)?
    
    /// Data
    private var nowPLayingItem: NowPlayingItem?
    private var containerConstraints: [NSLayoutConstraint] = []
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageSquareConstraint: NSLayoutConstraint?
    private var bounceSourceKey: String?
    private var glowSourceKey: String?
    private var pendingGlowSourceKey: String?
    
    /// Returns the inset in points based on the artworkSize preference:
    /// 0 = Extra Large (0pt = 60px), 1 = Large (1pt = 56px), 2 = Medium (2pt = 52px), 3 = Small (3pt = 48px)
    private var artworkInset: CGFloat {
        let size: Int = Preferences[.artworkSize]
        return CGFloat(size)
    }
    
    /// The extra width the image takes beyond PKDetailView's assumed 24pt
    private var artworkWidthBonus: CGFloat {
        let imageSize = 30 - (artworkInset * 2)
        return max(0, imageSize - 24)
    }

    /// The effective maxWidth to apply, accounting for fixed-width mode.
    /// In dynamic mode this is 160 + artworkWidthBonus (unchanged behaviour).
    /// In fixed mode it is the user-entered pixel value + artworkWidthBonus so the
    /// image size correction in updateConstraint() still works correctly.
    private var effectiveMaxWidth: CGFloat {
        if Preferences[.fixedWidthEnabled] {
            let pixels: Int = Preferences[.fixedWidthPixels]
            let base = CGFloat(max(40, pixels))  // clamp to a sensible minimum
            return base + artworkWidthBonus
        }
        return 160 + artworkWidthBonus
    }

    override func didLoad() {
        canScrollTitle = true
        canScrollSubtitle = true
        titleView.numberOfLoop = 1
        subtitleView.numberOfLoop = 1
        
        imageView.wantsLayer = true
        imageView.layer?.masksToBounds = true
        
        // Keep title and artist tight together regardless of image size
        labelsContainer.distribution = .fillEqually
        labelsContainer.spacing = 0
        labelsContainer.alignment = .leading
        for textView in [titleView, subtitleView].compactMap({ $0 }) {
            // The marquee draws a second copy while scrolling. Clip both copies
            // to the text lane so they cannot cross onto the album artwork.
            textView.wantsLayer = true
            textView.layer?.masksToBounds = true
            textView.trailingAnchor.constraint(equalTo: labelsContainer.trailingAnchor).isActive = true
        }
        imageView.heightAnchor.constraint(equalTo: contentContainer.heightAnchor).isActive = true
        
        updateUIState(for: nil)
        super.didLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFixedWidthChange),
            name: Notification.Name(didChangeFixedWidthNotification),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(didChangeFixedWidthNotification), object: nil)
    }
    
    @objc private func handleFixedWidthChange() {
        updateUIState(for: nowPLayingItem)
        updateConstraint()
    }
    
    override func updateConstraint() {
        guard let container = contentContainer, let superview = container.superview else {
            return
        }

        let inset = artworkInset
        container.translatesAutoresizingMaskIntoConstraints = false
        deactivateContentContainerEdgeConstraints(container, in: superview)

        NSLayoutConstraint.deactivate(containerConstraints)
        containerConstraints = [
            container.topAnchor.constraint(equalTo: superview.topAnchor, constant: inset),
            container.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -inset),
            container.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ]
        containerConstraints.enumerated().forEach { index, constraint in
            constraint.identifier = "nowPlaying.contentContainer.edge.\(index)"
        }
        NSLayoutConstraint.activate(containerConstraints)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        if shouldHideIcon {
            imageSquareConstraint?.isActive = false
            let constraint = imageWidthConstraint ?? imageView.widthAnchor.constraint(equalToConstant: 0)
            constraint.identifier = "nowPlaying.image.width"
            constraint.constant = 0
            constraint.isActive = true
            imageWidthConstraint = constraint
        } else {
            imageWidthConstraint?.isActive = false
            let constraint = imageSquareConstraint ?? imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            constraint.identifier = "nowPlaying.image.square"
            constraint.isActive = true
            imageSquareConstraint = constraint
        }

        // Correct width constraint — PKDetailView assumes 24pt image, we use actual size
        let actualImagePt = 30 - (inset * 2)
        let correctedWidth = contentWidth - 24 + actualImagePt + contentContainer.spacing

        // In fixed-width mode, always use exactly effectiveMaxWidth regardless of
        // how wide the text content measures — this is what locks the widget size.
        let cappedWidth: CGFloat
        if Preferences[.fixedWidthEnabled] {
            cappedWidth = effectiveMaxWidth
        } else {
            cappedWidth = maxWidth > 0 ? min(correctedWidth, maxWidth) : correctedWidth
        }

        if let widthConstraint = container.constraints.first(where: { $0.identifier == "contentContainer.width" }) {
            widthConstraint.constant = cappedWidth
            widthConstraint.isActive = true
        } else {
            let widthConstraint = container.widthAnchor.constraint(equalToConstant: cappedWidth)
            widthConstraint.identifier = "contentContainer.width"
            widthConstraint.isActive = true
        }
    }

    private func deactivateContentContainerEdgeConstraints(_ container: NSView, in superview: NSView) {
        superview.constraints.forEach { constraint in
            guard constraint.firstItem as AnyObject? === container || constraint.secondItem as AnyObject? === container else {
                return
            }
            let attributes: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing]
            guard attributes.contains(constraint.firstAttribute) || attributes.contains(constraint.secondAttribute) else {
                return
            }
            constraint.isActive = false
        }
    }
    
    override func layout() {
        super.layout()
        if !shouldHideIcon {
            let radius = imageView.bounds.height / 2 * 0.35
            imageView.layer?.cornerRadius = radius
            // Keep anchor point at center for bounce animation
            if let layer = imageView.layer, layer.anchorPoint != CGPoint(x: 0.5, y: 0.5) {
                let frame = layer.frame
                layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                layer.frame = frame
            }
            // Keep glow overlay frame in sync with image size if it exists
            imageView.layer?.sublayers?
                .filter { $0.name == "glowOverlayLayer" }
                .forEach {
                    $0.frame = imageView.layer!.bounds
                    $0.cornerRadius = radius
                }
        }
    }
    
    // PKDetailView.startBounceAnimation() is in a non-open extension so can't be overridden.
    // We add our own smoother animation directly and call this instead.
    private func startSmoothBounceAnimation(for track: String) {
        guard let layer = imageView?.layer, bounceSourceKey != track else { return }
        bounceSourceKey = track
        let bounce = CABasicAnimation(keyPath: "transform.scale")
        bounce.fromValue = 0.88
        bounce.toValue = 1.0
        bounce.duration = 0.55
        bounce.autoreverses = true
        bounce.timingFunction = CAMediaTimingFunction(controlPoints: 0.45, 0.0, 0.55, 1.0)
        layer.add(bounce, forKey: "kBounceAnimationKey")
    }
    
    /// Returns the average luminance of the current artwork (0=black, 1=white)
    private func artworkLuminance() -> CGFloat {
        guard let image = imageView.image,
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return 0.5 }
        // Scale down to 1x1 to get average color cheaply
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixel = [UInt8](repeating: 0, count: 4)
        guard let ctx = CGContext(data: &pixel, width: 1, height: 1,
                                  bitsPerComponent: 8, bytesPerRow: 4,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return 0.5 }
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        let r = CGFloat(pixel[0]) / 255
        let g = CGFloat(pixel[1]) / 255
        let b = CGFloat(pixel[2]) / 255
        // Perceived luminance formula
        return 0.299 * r + 0.587 * g + 0.114 * b
    }

    private func startGlowAnimation() {
        guard let imageLayer = imageView?.layer else { return }
        let sourceKey = pendingGlowSourceKey ?? ""
        if glowSourceKey == sourceKey,
           imageLayer.sublayers?.contains(where: { $0.name == "glowOverlayLayer" }) == true {
            return
        }
        stopGlowAnimation()
        
        // Choose glow color and direction based on artwork luminance
        let luminance = artworkLuminance()
        let glowLayer = CAGradientLayer()
        glowLayer.frame = imageLayer.bounds
        glowLayer.cornerRadius = imageLayer.cornerRadius
        glowLayer.masksToBounds = true
        glowLayer.zPosition = 1000
        glowLayer.name = "glowOverlayLayer"
        glowLayer.type = .radial
        glowLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        glowLayer.opacity = 0
        
        // Scale glow opacity with luminance — light art needs stronger glow to be visible
        let glowOpacity = Float(0.5 + (luminance * 0.5))  // range: 0.5 (dark) to 1.0 (light)
        let gradientAlpha = 0.9 + (luminance * 0.1)       // range: 0.9 (dark) to 1.0 (light)
        
        glowLayer.colors = [
            NSColor.white.withAlphaComponent(gradientAlpha).cgColor,
            NSColor.white.withAlphaComponent(0.0).cgColor
        ]
        glowLayer.endPoint = CGPoint(x: 0.6, y: 0.6)
        glowLayer.compositingFilter = "screenBlendMode"
        imageLayer.addSublayer(glowLayer)
        
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.0
        pulse.toValue = glowOpacity
        pulse.duration = 0.75
        pulse.autoreverses = true
        pulse.timingFunction = CAMediaTimingFunction(controlPoints: 0.45, 0.0, 0.55, 1.0)
        glowLayer.add(pulse, forKey: "kGlowAnimationKey")
        
        let expand = CABasicAnimation(keyPath: "endPoint")
        expand.fromValue = CGPoint(x: 0.6, y: 0.6)
        expand.toValue = CGPoint(x: 1.2, y: 1.2)
        expand.duration = pulse.duration
        expand.autoreverses = true
        expand.timingFunction = CAMediaTimingFunction(controlPoints: 0.45, 0.0, 0.55, 1.0)
        glowLayer.add(expand, forKey: "kGlowExpandKey")
        glowSourceKey = sourceKey
    }
    
    private func stopGlowAnimation() {
        glowSourceKey = nil
        imageView?.layer?.removeAnimation(forKey: "kDimAnimationKey")
        imageView?.layer?.opacity = 1.0
        imageView?.layer?.sublayers?
            .filter { $0.name == "glowOverlayLayer" }
            .forEach { $0.removeFromSuperlayer() }
        imageView?.layer?.superlayer?.sublayers?
            .filter { $0.name == "glowShadowLayer" }
            .forEach { $0.removeFromSuperlayer() }
        imageView?.layer?.superlayer?.superlayer?.sublayers?
            .filter { $0.name == "glowShadowLayer" }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    internal func updateUIState(for item: NowPlayingItem?) {
        self.nowPLayingItem = item
        defer {
            updateForNowPlayingState()
        }
        guard let item = self.nowPLayingItem, let client = item.client else {
            let appBundleIdentifier: String = Preferences[.defaultPlayer]
            imageView.image = NSWorkspace.shared.applicationIcon(for: appBundleIdentifier, fallbackFileType: "mp3")
            updateLabels(title: NSWorkspace.shared.applicationName(for: appBundleIdentifier), subtitle: nil)
            return
        }
        if let artwork = item.artwork {
            imageView.image = artwork
        } else {
            imageView.image = client.icon
        }
        let artworkSize: Int = Preferences[.artworkSize]
        pendingGlowSourceKey = "\(item.title ?? "")|\(item.artist ?? "")|\(item.artwork != nil)|\(artworkSize)"
        var title = item.title ?? (item.artist == nil ? client.displayName : "Missing title") ?? "Missing title"
        if title.isEmpty {
            title = "Missing title"
        }
        updateLabels(title: title, subtitle: item.artist ?? (item.title != nil ? client.displayName : nil))
    }

    private func updateLabels(title: String?, subtitle: String?) {
        let width = effectiveMaxWidth
        let widthChanged = maxWidth != width
        if widthChanged { maxWidth = width }
        let speed: Double? = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion ? 0 : nil
        if widthChanged || (titleView.text as String? ?? "") != (title ?? "") {
            set(title: title, speed: speed)
        }
        if widthChanged || (subtitleView.text as String? ?? "") != (subtitle ?? "") {
            set(subtitle: subtitle, speed: speed)
        }
        subtitleView.isHidden = subtitle?.isEmpty ?? true
    }

    private func updateForNowPlayingState() {
        let playing = nowPLayingItem?.isPlaying == true && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        if playing, Preferences[.animateIconWhilePlaying], let item = nowPLayingItem {
            startSmoothBounceAnimation(for: "\(item.title ?? "")|\(item.artist ?? "")|\(item.album ?? "")")
        } else {
            bounceSourceKey = nil
            stopBounceAnimation()
        }
        if playing && Preferences[.artworkGlow] {
            startGlowAnimation()
        } else {
            stopGlowAnimation()
        }
    }

    override open func didTapHandler() {
        self.didTap?()
    }
    
    override open func didSwipeLeftHandler() {
        if Preferences[.invertSwipeGesture] {
            self.didSwipeRight?()
        } else {
            self.didSwipeLeft?()
        }
    }
    
    override open func didSwipeRightHandler() {
        if Preferences[.invertSwipeGesture] {
            self.didSwipeLeft?()
        } else {
            self.didSwipeRight?()
        }
    }
    
    override func didLongPressHandler() {
        self.didLongPress?()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        prepareForHiddenState()
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if superview == nil {
            prepareForHiddenState()
        } else {
            self.updateUIState(for: nowPLayingItem)
        }
    }

    internal func prepareForHiddenState() {
        bounceSourceKey = nil
        stopBounceAnimation()
        stopGlowAnimation()
        for textView in [titleView, subtitleView].compactMap({ $0 }) {
            textView.speed = 0
            textView.set(speed: 0)
        }
    }
    
}
