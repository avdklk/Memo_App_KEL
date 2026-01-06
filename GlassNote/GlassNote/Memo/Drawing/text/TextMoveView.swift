//
//  TextMoveView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/6/25.
//
import UIKit

protocol TextMoveViewDelegate {
    func editEnd(text: String, rect: CGRect)
    func editCancel()
}

private enum ActionType {
    case draw
    case move
    case width
    case delete
}

public class TextMoveView: UIView {
    
    private let bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no //자동수정 끔
        textView.backgroundColor = .white.withAlphaComponent(0.5)
        textView.isUserInteractionEnabled = true
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 14)
        return textView
    }()
    
    private let widthView: IconToggleImageView = IconToggleImageView(systemName: "square.resize", title: "크기")
    private let drawView: IconToggleImageView = IconToggleImageView(systemName: "checkmark.seal", title: "적용")
    private let deleteView: IconToggleImageView = IconToggleImageView(systemName: "trash.circle", title: "삭제")
    private let changePositionView: IconToggleImageView = IconToggleImageView(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", title: "위치")
    
    private var delegate: TextMoveViewDelegate?
    private let actionViewWidth: CGFloat = 35
    private let actionViewHeight: CGFloat = 45
    private var actionType: ActionType = .move
    
    init(delegate: TextMoveViewDelegate) {
        super.init(frame: .zero)
        textView.delegate = self
        self.delegate = delegate
        self.setInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        bgView.frame = rect
    }
    
    func setFontSize(fontSize: CGFloat) {
        textView.font = .systemFont(ofSize: fontSize)
    }
    
    func setText(text: String) {
        textView.text = text
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
        return true
    }
    
    private func setInit() {
        self.backgroundColor = .clear
        self.addSubview(bgView)
        self.addSubview(textView)
        
        textView.frame = CGRect(origin: CGPoint(x: 0, y: actionViewHeight), size: CGSize(width: 200, height: 200))
        
        self.addSubview(widthView)
        widthView.isUserInteractionEnabled = false
        widthView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthView.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            widthView.widthAnchor.constraint(equalToConstant: actionViewWidth),
            widthView.heightAnchor.constraint(equalToConstant: actionViewHeight),
            widthView.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0)
        ])
        
        self.addSubview(drawView)
        drawView.isUserInteractionEnabled = false
        drawView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            drawView.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            drawView.widthAnchor.constraint(equalToConstant: actionViewWidth),
            drawView.heightAnchor.constraint(equalToConstant: actionViewHeight),
            drawView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: 0)
        ])
        
        self.addSubview(changePositionView)
        changePositionView.isUserInteractionEnabled = false
        changePositionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changePositionView.leadingAnchor.constraint(equalTo: textView.trailingAnchor),
            changePositionView.widthAnchor.constraint(equalToConstant: actionViewWidth),
            changePositionView.heightAnchor.constraint(equalToConstant: actionViewHeight),
            changePositionView.topAnchor.constraint(equalTo: textView.topAnchor, constant: 0)
        ])
        
        self.addSubview(deleteView)
        deleteView.isUserInteractionEnabled = false
        deleteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteView.leadingAnchor.constraint(equalTo: changePositionView.leadingAnchor),
            deleteView.widthAnchor.constraint(equalToConstant: actionViewWidth),
            deleteView.heightAnchor.constraint(equalToConstant: actionViewHeight),
            deleteView.bottomAnchor.constraint(equalTo: changePositionView.topAnchor, constant: 0)
        ])
        let panGR = ImmediatePanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        panGR.cancelsTouchesInView = false
        bgView.addGestureRecognizer(panGR)
    }
    
    @objc private func didPan(sender: ImmediatePanGestureRecognizer) {
        autoreleasepool { _didPan(sender: sender) }
    }
    
    private func _didPan(sender: ImmediatePanGestureRecognizer) {
        switch sender.state {
        case .possible:
            print("possible")
        case .began:
            let p = sender.location(in: self)
            if changePositionView.frame.contains(p) {
                actionType = .move
            } else if widthView.frame.contains(p) {
                actionType = .width
            } else if deleteView.frame.contains(p) {
                actionType = .delete
            } else if drawView.frame.contains(p) {
                actionType = .draw
            }
        case .changed:
            let p = sender.location(in: self)
            
            switch self.actionType {
            case .move:
                let newTvX = p.x - textView.frame.width
                let newTvY = p.y + textView.frame.height
                let tvXPlusIconView = p.x + widthView.frame.width
                
                if newTvX < self.frame.minX || (p.y + widthView.frame.height) < self.frame.minY ||
                    tvXPlusIconView > self.frame.maxX || newTvY > self.frame.maxY {return}
                
                let newP = CGPoint(x: p.x - textView.frame.width, y: p.y)
                textView.frame.origin = newP
                textView.layoutIfNeeded()
            case .width:
                var x = p.x
                var y = p.y
                
                if p.x > self.frame.maxX - widthView.frame.width  {
                    x = self.frame.maxX - widthView.frame.width
                } else if p.x < self.frame.minX {
                    x = self.frame.minX
                }
                
                if p.y > self.frame.maxY {
                    y = self.frame.maxY
                } else if p.y < self.frame.minY + widthView.frame.height {
                    y = self.frame.minY + textView.frame.height + widthView.frame.height
                }
                
                let newWidth = max(x - textView.frame.minX, 0)
                let newHeight = max(y - textView.frame.minY, 0)
                textView.frame.size = CGSize(width: newWidth, height: newHeight)
                textView.layoutIfNeeded()
            case .delete:
                print("delete changed")
            case .draw:
                print("none changed")
            }
        case .ended:
            switch self.actionType {
            case .move:
//                let newP = makeMovePoint(p: p)
//                textView.frame.origin = newP
                print("end monve")
            case .width:
//                let newRect = makeWidthPoint(p: p)
//                textView.frame = newRect
                print("end width")
            case .delete:
                delegate?.editCancel()
            case .draw:
                delegate?.editEnd(text: textView.text, rect: textView.frame)
            }
            
            self.endEditing(true)
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        case .recognized:
            print("recognize")
        @unknown default:
            print("didpan")
        }
    }
    
    private func makeMovePoint(p: CGPoint) -> CGPoint {
        var newP = CGPoint(x: p.x - textView.frame.width, y: p.y)
        if textView.frame.minX < self.frame.minX {
            newP.x = self.frame.minX
        }
        
        if textView.frame.minY < self.frame.minY {
            newP.y = self.frame.minY
        }
        
        if textView.frame.maxX > self.frame.maxX {
            newP.x = self.frame.maxX - textView.frame.width
        }
        
        if textView.frame.maxY > self.frame.maxY {
            newP.y = self.frame.maxY - textView.frame.height
        }
        
        return newP
    }
    
    private func makeWidthPoint(p: CGPoint) -> CGRect {
        let basicWidth = abs(p.x - textView.frame.minX)
        let basicHeight = abs(p.y - textView.frame.minY)
        
        var newRect = CGRect(origin: textView.frame.origin, size: CGSize(width: basicWidth, height: basicHeight))
        
        if textView.frame.minX < self.frame.minX {
            let newWidth = abs(p.x - self.frame.minX)
            newRect.origin.x = self.frame.minX
            newRect.size.width = newWidth
        }
        
        if textView.frame.minY < self.frame.minY {
            newRect.origin.y = self.frame.minY
            let newHeight = abs(p.y - self.frame.minY)
            newRect.size.height = newHeight
        }
        
        if textView.frame.maxX > self.frame.maxX {
            newRect.origin.x = abs(self.frame.maxX - textView.frame.width)
            let newWidth = abs(self.frame.maxX - textView.frame.minX)
            newRect.size.width = newWidth
        }
        
        if textView.frame.maxY > self.frame.maxY {
            newRect.origin.y = abs(self.frame.maxY - textView.frame.height)
            let newHeight = abs(self.frame.maxY - textView.frame.minY)
            newRect.size.height = newHeight
        }
        return newRect
    }
}

extension TextMoveView: UITextViewDelegate {
    
}
