//
//  UIView + Chain.swift
//  sleeping
//
//  Created by 이경은 on 4/7/25.
//


import UIKit

extension UIView: Chainable {}

extension Chain where Origin: UIView {
    public func addView( to: UIView ) -> Chain {
        to.addSubview(origin)
        return self
    }

    public func addSubView( view: UIView ) -> Chain {
        origin.addSubview(view)
        return self
    }
    
    public func fillParant( constant : CGFloat ) -> Chain {
        return fillParant(topConstant: constant, bottomConstant: -constant, leadConstant: constant, trailConstant: -constant)
    }
    
    public func fillParant( topConstant : CGFloat = 0.0, bottomConstant : CGFloat = 0.0, leadConstant : CGFloat = 0.0, trailConstant : CGFloat = 0.0 ) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let superView = origin.superview {
            origin.topAnchor.constraint(equalTo: superView.topAnchor, constant: topConstant).isActive = true
            origin.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottomConstant).isActive = true
            origin.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leadConstant).isActive = true
            origin.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: trailConstant).isActive = true
        }
        return self
    }
    
    public func fillParantWithAnchor( topAnchor : NSLayoutYAxisAnchor? = nil, bottomAnchor : NSLayoutYAxisAnchor? = nil,
                                      leadAnchor : NSLayoutXAxisAnchor? = nil, trailAnchor : NSLayoutXAxisAnchor? = nil,
                                      constant : CGFloat ) -> Chain {
        return fillParantWithAnchor(topAnchor:topAnchor, bottomAnchor:bottomAnchor, leadAnchor:leadAnchor, trailAnchor:trailAnchor,
                          topConstant: constant, bottomConstant: -constant, leadConstant: constant, trailConstant: -constant)
    }
    
    public func fillParantWithAnchor( topAnchor : NSLayoutYAxisAnchor? = nil, bottomAnchor : NSLayoutYAxisAnchor? = nil,
                                      leadAnchor : NSLayoutXAxisAnchor? = nil, trailAnchor : NSLayoutXAxisAnchor? = nil,
                                      topConstant : CGFloat = 0.0, bottomConstant : CGFloat = 0.0, leadConstant : CGFloat = 0.0, trailConstant : CGFloat = 0.0 ) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let superView = origin.superview {
            origin.topAnchor.constraint(equalTo: topAnchor ?? superView.topAnchor, constant: topConstant).isActive = true
            origin.bottomAnchor.constraint(equalTo: bottomAnchor ?? superView.bottomAnchor, constant: bottomConstant).isActive = true
            origin.leadingAnchor.constraint(equalTo: leadAnchor ?? superView.leadingAnchor, constant: leadConstant).isActive = true
            origin.trailingAnchor.constraint(equalTo: trailAnchor ?? superView.trailingAnchor, constant: trailConstant).isActive = true
        }
        return self
    }

    public func fillParantWithAnchor( superView : UIView, constant: CGFloat = 0.0) -> Chain {
        return fillParantWithAnchor(topAnchor:superView.topAnchor, bottomAnchor: superView.bottomAnchor, leadAnchor:superView.leadingAnchor, trailAnchor:superView.trailingAnchor,
                          topConstant: constant, bottomConstant: -constant, leadConstant: constant, trailConstant: -constant)
    }
    
    public func fillSafeAreaGuide(constant: CGFloat = 0.0) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let superView = origin.superview {
            origin.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor, constant: constant).isActive = true
            origin.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor, constant: -constant).isActive = true
            origin.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor, constant: constant).isActive = true
            origin.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor, constant: -constant).isActive = true
        }
        return self
    }

    public func center( multiWidth: CGFloat, multiHeight: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let superView = origin.superview {
            origin.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: multiWidth).isActive = true
            origin.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: multiHeight).isActive = true
            origin.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
            origin.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        }
        return self
    }
    
    public func center(multiWidth: CGFloat? = nil, multiHeight: CGFloat? = nil, width: CGFloat?, height: CGFloat?) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let superView = origin.superview {
            if let width = width { origin.widthAnchor.constraint(equalToConstant: width).isActive = true }
            if let height = height { origin.heightAnchor.constraint(equalToConstant: height).isActive = true }
            if let multiWidth = multiWidth { origin.widthAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.widthAnchor, multiplier: multiWidth).isActive = true }
            if let multiHeight = multiHeight { origin.heightAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.heightAnchor, multiplier: multiHeight).isActive = true }
            origin.centerXAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerXAnchor).isActive = true
            origin.centerYAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        }
        return self
    }
    
    public func left(equalTo: NSLayoutXAxisAnchor? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.leadingAnchor.constraint(equalTo: equalTo, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func right(equalTo: UIView? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.trailingAnchor.constraint(equalTo: equalTo.trailingAnchor, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func right(equalTo: NSLayoutXAxisAnchor? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.trailingAnchor.constraint(equalTo: equalTo, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func right(greater: UIView? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let greater = greater {
            origin.trailingAnchor.constraint(greaterThanOrEqualTo: greater.trailingAnchor, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.trailingAnchor.constraint(greaterThanOrEqualTo: superView.trailingAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func right(less: UIView? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let less = less {
            origin.trailingAnchor.constraint(lessThanOrEqualTo: less.trailingAnchor, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.trailingAnchor.constraint(lessThanOrEqualTo: superView.trailingAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func bottom(equalTo: NSLayoutYAxisAnchor? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.bottomAnchor.constraint(equalTo: equalTo, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func bottom(greater: NSLayoutYAxisAnchor? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let greater = greater {
            origin.bottomAnchor.constraint(greaterThanOrEqualTo: greater, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.bottomAnchor.constraint(greaterThanOrEqualTo: superView.bottomAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func top(equalTo: NSLayoutYAxisAnchor? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.topAnchor.constraint(equalTo: equalTo, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.topAnchor.constraint(equalTo: superView.topAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func width(constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        origin.widthAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    public func height(constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        origin.heightAnchor.constraint(equalToConstant: constant).isActive = true
        return self
    }
    
    public func width(equalTo: NSLayoutDimension? = nil, multiWidth: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.widthAnchor.constraint(equalTo: equalTo, multiplier: multiWidth).isActive = true
        } else if let superView = origin.superview {
            origin.widthAnchor.constraint(equalTo: superView.widthAnchor, multiplier: multiWidth).isActive = true
        }
        return self
    }
    
    public func width(greater: NSLayoutDimension? = nil, multiWidth: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let greater = greater {
            origin.widthAnchor.constraint(greaterThanOrEqualTo: greater, multiplier: multiWidth).isActive = true
        } else if let superView = origin.superview {
            origin.widthAnchor.constraint(greaterThanOrEqualTo: superView.widthAnchor, multiplier: multiWidth).isActive = true
        }
        return self
    }
    
    public func width(less: NSLayoutDimension? = nil, multiWidth: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let less = less {
            origin.widthAnchor.constraint(lessThanOrEqualTo: less, multiplier: multiWidth).isActive = true
        } else if let superView = origin.superview {
            origin.widthAnchor.constraint(lessThanOrEqualTo: superView.widthAnchor, multiplier: multiWidth).isActive = true
        }
        return self
    }
    
    public func ratio(width: CGFloat, heght: CGFloat) -> Chain {
        origin.widthAnchor.constraint(equalTo: origin.heightAnchor, multiplier: width/heght).isActive = true
        return self
    }
    
    public func height(equalTo: NSLayoutDimension? = nil, multiHeight: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.heightAnchor.constraint(equalTo: equalTo, multiplier: multiHeight).isActive = true
        } else if let superView = origin.superview {
            origin.heightAnchor.constraint(equalTo: superView.heightAnchor, multiplier: multiHeight).isActive = true
        }
        return self
    }
    
    public func centerY(equalTo: UIView? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.centerYAnchor.constraint(equalTo: equalTo.centerYAnchor, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: constant).isActive = true
        }
        return self
    }
    
    public func centerX(equalTo: UIView? = nil, constant: CGFloat) -> Chain {
        origin.translatesAutoresizingMaskIntoConstraints = false
        if let equalTo = equalTo {
            origin.centerXAnchor.constraint(equalTo: equalTo.centerXAnchor, constant: constant).isActive = true
        } else if let superView = origin.superview {
            origin.centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: constant).isActive = true
        }
        return self
    }
    

    public func corner( Radius: CGFloat ) -> Chain {
        origin.layer.masksToBounds = true
        origin.layer.cornerRadius = Radius
        return self
    }

    public func border( Width: CGFloat ) -> Chain {
        origin.layer.borderWidth = Width
        return self
    }

    public func border( Color: UIColor ) -> Chain {
        origin.layer.borderColor = Color.cgColor
        return self
    }

    public func setBackgroundColor( color: UIColor ) -> Chain {
        origin.backgroundColor = color
        return self
    }

    public func transform( angle: CGFloat ) -> Chain {
        origin.transform = CGAffineTransformMakeRotation(angle)
        return self
    }

    public func setAlpha( alpha: CGFloat ) -> Chain {
        origin.alpha = alpha
        return self
    }
}
