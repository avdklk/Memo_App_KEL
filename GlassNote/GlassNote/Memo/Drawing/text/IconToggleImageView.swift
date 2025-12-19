//
//  IconToggleImageView.swift
//  GlassNote
//
//  Created by 하고 싶은 걸 하고 살자 on 12/10/25.
//
import UIKit

final class IconToggleImageView: UIView {

    let imageView = UIImageView()
    let label: UILabel = {
       let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10)
        label.lineBreakMode = .byCharWrapping
        label.numberOfLines = 0
        return label
    }()
//    var tapAction: (() -> Void)?

    // 외부에서 토글해도 UI 갱신되도록
    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    // MARK: - Init

    init(systemName: String, title: String?) {
//        self.tapAction = tapAction
        super.init(frame: .zero)
        setup(systemName: systemName, title: title)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(systemName: "circle", title: nil)
    }

    // MARK: - Setup

    private func setup(systemName: String, title: String?) {
        // 이미지뷰 설정
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = .white      // foregroundColor(.white)
        imageView.contentMode = .scaleAspectFit

        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // padding(.horizontal, 8).padding(.vertical, 8)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
//            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1)
        ])

        if let title = title {
            label.text = title
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            // padding(.horizontal, 8).padding(.vertical, 8)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 1),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
                label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
        }
        
        // 배경 모양 (RoundedRectangle(cornerRadius: 8))
        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderWidth = 1

        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor

        
        // 기본 상태 스타일
//        updateAppearance()

//        // 탭 제스처로 “버튼처럼” 동작하게
//        isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//        addGestureRecognizer(tap)
    }

    private func updateAppearance() {
        // fill:
        //   isSelected ? Color.white.opacity(0.22) : Color.white.opacity(0.08)
        let bgAlpha: CGFloat = isSelected ? 0.22 : 0.08
        backgroundColor = UIColor.white.withAlphaComponent(bgAlpha)

        // strokeBorder:
        //   Color.white.opacity(isSelected ? 0.6 : 0.2)
        let borderAlpha: CGFloat = isSelected ? 0.6 : 0.2
        layer.borderColor = UIColor.white.withAlphaComponent(borderAlpha).cgColor
    }

    // MARK: - Tap

//    @objc private func handleTap() {
//        tapAction?()
//        isSelected.toggle()
//    }
}

