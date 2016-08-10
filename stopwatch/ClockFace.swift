import UIKit

class ClockFace: UIView {

    let dotWidth = CGFloat(8)

    var clockHand = CAShapeLayer()
    var midLayer = CALayer()
    var centerDot = CALayer()
    var currentSeconds = 0.0

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	init(containerSize: CGSize = CGSize(width: ClockFace.clockHandSize(), height: ClockFace.clockHandSize())) {
		super.init(frame: CGRect (origin: CGPointZero, size: containerSize))
		
        backgroundColor = UIColor.clearColor()
        setColorScheme()
        clockHand.path = getHandPath(extended: false)
		
		let scale = (CGFloat(ClockFace.clockHandSize()) / containerSize.width) + (CGFloat(ClockFace.clockHandSize()) / containerSize.height)
		NSLog("\(scale)")
		clockHand.lineWidth = 0.01 * (scale / 2)
		
        midLayer.addSublayer(clockHand)
        midLayer.setAffineTransform(CGAffineTransform.init(a: frame.width/4.0, b: 0, c: 0, d: frame.height / 4.0, tx: frame.width / 2.0, ty: frame.height / 2.0))
        scaleDot(0)
        layer.addSublayer(midLayer)
        layer.addSublayer(centerDot)
    }

    func getHandPath(extended extended : Bool) -> CGPath {
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, 0)
        CGPathAddLineToPoint(path, nil, 0, extended ? -2 : 0)
        return path
    }
    
    func animate(seconds: Double) {
        
        if seconds == currentSeconds { //don't run the animation on every call (run it 10 times a second).
            return
        }
        currentSeconds = seconds;
        
        let angle = seconds * 6.0
        let rotation = CGAffineTransformMakeRotation(CGFloat(Double(angle) / 180.0 * M_PI))
        self.clockHand.setAffineTransform(rotation)
    }
    
    func scaleDot(size : CGFloat) {
        centerDot.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        centerDot.bounds = CGRect(x: 0, y: 0, width: size, height: size)
        centerDot.cornerRadius = size / 2
    }
    
    func hide() {
        animateLayer(clockHand,
            duration: 0.4,
            animation: { layer in
                layer.path = self.getHandPath(extended: false)
            },
            properties: "path"
        )
        animateLayer(centerDot,
                     duration: 0.4, delay: 0.25,
                     timingFunction: CAMediaTimingFunction(controlPoints: 0.4, 0, 1, 1),
                     animation: { layer in
                        self.scaleDot(0)
            }, properties: "position", "bounds", "cornerRadius"
        )
    }
    
    func show() {
        hidden = false
        animateLayer(clockHand,
            duration: 1, delay: 0.7,
            timingFunction: CAMediaTimingFunction(controlPoints: 0, 1, 1, 1),
            animation: { layer in
                layer.path = self.getHandPath(extended: true)
            },
            properties: "path"
        )
        animateLayer(centerDot,
                     duration: 0.5,
                     timingFunction: CAMediaTimingFunction(controlPoints: 0, 2, 0.5, 1),
                     animation: { layer in
                        self.scaleDot(self.dotWidth)
            }, properties: "position", "bounds", "cornerRadius"
        )
    }


    

    func setColorScheme() {
		centerDot.backgroundColor = AppDelegate.instance.colorScheme.dotColor.CGColor
		clockHand.strokeColor = AppDelegate.instance.colorScheme.handColor.CGColor
    }

    static func clockHandSize() -> Double {
        if(AppDelegate.isIPhone5orLower()){
            return 300.0
        } else {
            return 330.0
        }
    }

    static func clockHandLocation(superView: UIView, clockFaceView: UIView) -> CGPoint {

        //if small, x points from top, if large, put in center
        if(AppDelegate.isIPhone5orLower()) {
            return CGPointMake(superView.center.x, 64 + clockFaceView.bounds.height / 2)
        }
        return superView.center
    }
}

