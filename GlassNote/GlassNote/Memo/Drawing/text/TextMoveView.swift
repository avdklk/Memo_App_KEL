//
//  TextMoveView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/6/25.
//
import UIKit

protocol TextMoveViewDelegate {
    func editStart()
    func editEnd(text: String, rect: CGRect)
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
        textView.clipsToBounds = true
        textView.autocorrectionType = .no
        textView.backgroundColor = .yellow
        textView.isUserInteractionEnabled = true
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 14)
//        textView.backgroundColor = .clear
        return textView
    }()
    
    private let widthView: IconToggleImageView = IconToggleImageView(systemName: "square.resize", title: "크기")
    private let drawView: IconToggleImageView = IconToggleImageView(systemName: "checkmark.seal", title: "적용")
    private let deleteView: IconToggleImageView = IconToggleImageView(systemName: "trash.circle", title: "삭제")
    private let changePositionView: IconToggleImageView = IconToggleImageView(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left", title: "위치")

    private var delegate: TextMoveViewDelegate?
    private let actionViewWidth: CGFloat = 25
    private let actionViewHeight: CGFloat = 30
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
        return true
    }
    
    private func setInit() {
        self.backgroundColor = .clear
        self.addSubview(bgView)
        self.addSubview(textView)
        
        textView.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        
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
                textView.frame.origin = CGPoint(x: p.x - textView.frame.width, y: p.y)
            case .width:
                let newWidth = abs(p.x - textView.frame.minX)
                let newHeight = abs(p.y - textView.frame.minY)
                textView.frame.size = CGSize(width: newWidth, height: newHeight)
                textView.layoutIfNeeded()
            case .delete:
                print("delete changed")
            case .draw:
                print("none changed")
            }
        case .ended:
            switch self.actionType {
            case .move, .width:
                print("move, width,end")
            case .delete:
                delegate?.editEnd(text: "", rect: .zero)
            case .draw:
                delegate?.editEnd(text: textView.text, rect: textView.frame)
            }
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
}

extension TextMoveView: UITextViewDelegate {
    
}
