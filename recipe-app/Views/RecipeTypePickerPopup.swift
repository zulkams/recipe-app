import UIKit

class RecipeTypePickerPopup: UIView {
    let backgroundView = UIView()
    let cardView = UIView()
    let pickerView = UIPickerView()
    let applyButton = UIButton(type: .system)
    let cancelButton = UIButton(type: .system)
    var onApply: ((Int) -> Void)?
    var onCancel: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Background
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        backgroundView.alpha = 0
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        // Card
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.masksToBounds = true
        addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 320),
            cardView.heightAnchor.constraint(equalToConstant: 260)
        ])
        
        // Picker
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            pickerView.leftAnchor.constraint(equalTo: cardView.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: cardView.rightAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        // Buttons
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, applyButton])
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        cardView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leftAnchor.constraint(equalTo: cardView.leftAnchor),
            buttonStack.rightAnchor.constraint(equalTo: cardView.rightAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cancelButton.backgroundColor = .clear
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        applyButton.setTitle("Apply", for: .normal)
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        applyButton.backgroundColor = .systemBlue
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
    }
    
    func present(in parent: UIView) {
        frame = parent.bounds
        parent.addSubview(self)
        backgroundView.alpha = 0
        cardView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        cardView.alpha = 0
        UIView.animate(withDuration: 0.22) {
            self.backgroundView.alpha = 1
            self.cardView.alpha = 1
            self.cardView.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.18, animations: {
            self.backgroundView.alpha = 0
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    @objc private func applyTapped() {
        onApply?(pickerView.selectedRow(inComponent: 0))
        dismiss()
    }
    @objc private func cancelTapped() {
        onCancel?()
        dismiss()
    }
}
