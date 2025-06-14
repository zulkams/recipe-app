import UIKit
import SnapKit
import SDWebImage
// Import Recipe and RecipeType

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleField = UITextField()
    let typePicker = UIPickerView()
    let imageView = UIImageView()
    let pickImageButton = UIButton(type: .system)
    let ingredientsField = UITextView()
    var stepFields: [UITextField] = []
    var stepCards: [UIView] = []
    let stepsStackView = UIStackView()
    let addStepButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    // ViewModel
    let viewModel = AddRecipeViewModel()
    var onRecipeAdded: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Recipe"
        view.backgroundColor = .systemBackground
        setupUI()
    }

    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // Title Card
        let titleCard = UIView()
        titleCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        titleCard.layer.cornerRadius = 16
        titleCard.layer.shadowColor = UIColor.black.cgColor
        titleCard.layer.shadowOpacity = 0.08
        titleCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        titleCard.layer.shadowRadius = 8
        contentView.addSubview(titleCard)
        titleCard.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.left.right.equalToSuperview().inset(16)
        }
        titleField.placeholder = "Recipe Title"
        titleField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleField.borderStyle = .none
        titleField.backgroundColor = .clear
        titleCard.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        // Type Picker Card
        let typeCard = UIView()
        typeCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        typeCard.layer.cornerRadius = 16
        typeCard.layer.shadowColor = UIColor.black.cgColor
        typeCard.layer.shadowOpacity = 0.08
        typeCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        typeCard.layer.shadowRadius = 8
        contentView.addSubview(typeCard)
        typeCard.snp.makeConstraints { make in
            make.top.equalTo(titleCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        typePicker.dataSource = self
        typePicker.delegate = self
        typeCard.addSubview(typePicker)
        typePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
            make.height.equalTo(80)
        }

        // Image Card
        let imageCard = UIView()
        imageCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        imageCard.layer.cornerRadius = 16
        imageCard.layer.shadowColor = UIColor.black.cgColor
        imageCard.layer.shadowOpacity = 0.08
        imageCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageCard.layer.shadowRadius = 8
        contentView.addSubview(imageCard)
        imageCard.snp.makeConstraints { make in
            make.top.equalTo(typeCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        imageView.backgroundColor = .tertiarySystemFill
        imageCard.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(12)
            make.height.equalTo(140)
        }
        pickImageButton.setTitle("Pick Image", for: .normal)
        pickImageButton.setTitleColor(.white, for: .normal)
        pickImageButton.backgroundColor = .systemBlue
        pickImageButton.layer.cornerRadius = 10
        pickImageButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        pickImageButton.addTarget(self, action: #selector(pickImageTapped), for: .touchUpInside)
        imageCard.addSubview(pickImageButton)
        pickImageButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(38)
            make.width.greaterThanOrEqualTo(120)
        }

        // Ingredients Card
        let ingredientsCard = UIView()
        ingredientsCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        ingredientsCard.layer.cornerRadius = 16
        ingredientsCard.layer.shadowColor = UIColor.black.cgColor
        ingredientsCard.layer.shadowOpacity = 0.08
        ingredientsCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        ingredientsCard.layer.shadowRadius = 8
        contentView.addSubview(ingredientsCard)
        ingredientsCard.snp.makeConstraints { make in
            make.top.equalTo(imageCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ingredients (comma separated)"
        ingredientsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ingredientsCard.addSubview(ingredientsLabel)
        ingredientsLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        ingredientsField.layer.cornerRadius = 10
        ingredientsField.backgroundColor = .clear
        ingredientsField.font = UIFont.systemFont(ofSize: 16)
        ingredientsField.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        ingredientsCard.addSubview(ingredientsField)
        ingredientsField.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview().inset(12)
            make.height.equalTo(60)
        }

        // Steps Card
        let stepsCard = UIView()
        stepsCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        stepsCard.layer.cornerRadius = 16
        stepsCard.layer.shadowColor = UIColor.black.cgColor
        stepsCard.layer.shadowOpacity = 0.08
        stepsCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        stepsCard.layer.shadowRadius = 8
        contentView.addSubview(stepsCard)
        stepsCard.snp.makeConstraints { make in
            make.top.equalTo(ingredientsCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        let stepsLabel = UILabel()
        stepsLabel.text = "Steps"
        stepsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        stepsCard.addSubview(stepsLabel)
        stepsLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        // Stack view for step fields
        stepsStackView.axis = .vertical
        stepsStackView.spacing = 8
        stepsCard.addSubview(stepsStackView)
        stepsStackView.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
        }
        // Add Step button
        addStepButton.setTitle("+ Add Step", for: .normal)
        addStepButton.setTitleColor(.systemBlue, for: .normal)
        addStepButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addStepButton.addTarget(self, action: #selector(addStepField), for: .touchUpInside)
        stepsCard.addSubview(addStepButton)
        addStepButton.snp.makeConstraints { make in
            make.top.equalTo(stepsStackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(36)
        }
        // Start with one step field
        addStepField()

        // Save Button (floating)
        saveButton.setTitle("Save Recipe", for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 22
        saveButton.layer.shadowColor = UIColor.black.cgColor
        saveButton.layer.shadowOpacity = 0.15
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 8
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(stepsCard.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-40)
        }

    }

    @objc func pickImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            viewModel.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @objc func saveTapped() {
        viewModel.title = titleField.text ?? ""
        viewModel.setIngredients(from: ingredientsField.text)
        // Collect all step fields
        let steps = stepFields.compactMap { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        viewModel.steps = steps
        // type and image are already bound
        guard let recipe = viewModel.createRecipe() else {
            let alert = UIAlertController(title: "Missing Info", message: "Please fill in all fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        DataManager.shared.addRecipe(recipe)
        onRecipeAdded?()
        navigationController?.popViewController(animated: true)
    }

    @objc func addStepField() {
        let card = UIView()
        card.backgroundColor = UIColor.systemBackground
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.07
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        // Step number circle
        let numberLabel = UILabel()
        numberLabel.text = "\(stepFields.count + 1)"
        numberLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        numberLabel.textColor = .white
        numberLabel.textAlignment = .center
        numberLabel.backgroundColor = .systemBlue
        numberLabel.layer.cornerRadius = 16
        numberLabel.clipsToBounds = true
        card.addSubview(numberLabel)
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberLabel.widthAnchor.constraint(equalToConstant: 32),
            numberLabel.heightAnchor.constraint(equalToConstant: 32),
            numberLabel.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 12),
            numberLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        // Step text field
        let stepField = UITextField()
        stepField.placeholder = "Step description"
        stepField.font = UIFont.systemFont(ofSize: 16)
        stepField.backgroundColor = .secondarySystemBackground
        stepField.layer.cornerRadius = 8
        stepField.clearButtonMode = .whileEditing
        stepField.autocapitalizationType = .sentences
        card.addSubview(stepField)
        stepField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepField.leftAnchor.constraint(equalTo: numberLabel.rightAnchor, constant: 12),
            stepField.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stepField.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            stepField.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -52),
            stepField.heightAnchor.constraint(equalToConstant: 36)
        ])

        // Remove button (icon)
        let removeButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .bold)
        removeButton.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: config), for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.addTarget(self, action: #selector(removeStepField(_:)), for: .touchUpInside)
        card.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            removeButton.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        stepFields.append(stepField)
        stepCards.append(card)
        stepsStackView.addArrangedSubview(card)
        // Animate appearance
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut], animations: {
            card.alpha = 1
            card.transform = .identity
        }, completion: nil)
        updateStepNumbers()
    }

    @objc func removeStepField(_ sender: UIButton) {
        guard let card = sender.superview, let index = stepCards.firstIndex(of: card) else { return }
        stepFields.remove(at: index)
        stepCards.remove(at: index)
        UIView.animate(withDuration: 0.18, animations: {
            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            self.stepsStackView.removeArrangedSubview(card)
            card.removeFromSuperview()
            self.updateStepNumbers()
        })
    }

    private func updateStepNumbers() {
        for (i, card) in stepCards.enumerated() {
            if let numberLabel = card.subviews.first(where: { $0 is UILabel }) as? UILabel {
                numberLabel.text = "\(i + 1)"
            }
        }
    }

}

extension AddRecipeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.recipeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.recipeTypes[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedType = viewModel.recipeTypes[row]
    }
}
