//
//  AddRecipeViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit
import SnapKit
import SDWebImage
// Import Recipe and RecipeType

class AddRecipeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var editingRecipe: Recipe?
    var onRecipeEdited: (() -> Void)?

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleField = UITextField()
    let typePicker = UIPickerView()
    let typePickerSpinner = UIActivityIndicatorView(style: .medium)
    private var isTypeLoading = false
    let imageView = UIImageView()
    let pickImageButton = UIButton(type: .system)
    var ingredientFields: [UITextField] = []
    var ingredientCards: [UIView] = []
    let ingredientsStackView = UIStackView()
    let addIngredientButton = UIButton(type: .system)
    var stepFields: [UITextField] = []
    var stepCards: [UIView] = []
    let stepsStackView = UIStackView()
    let addStepButton = UIButton(type: .system)
    let saveButton = UIButton(type: .system)

    // ViewModel
    let viewModel = AddRecipeViewModel()
    var onRecipeAdded: (() -> Void)?
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    convenience init(recipeToEdit: Recipe? = nil) {
        self.init(nibName: nil, bundle: nil)
        self.editingRecipe = recipeToEdit
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prefillIfNeeded()
        if viewModel.recipeTypes.isEmpty {
            isTypeLoading = true
            typePicker.isHidden = true
            typePickerSpinner.isHidden = false
            typePickerSpinner.startAnimating()
            viewModel.loadTypes { [weak self] in
                DispatchQueue.main.async {
                    self?.isTypeLoading = false
                    self?.typePickerSpinner.stopAnimating()
                    self?.typePicker.isHidden = false
                    self?.typePickerSpinner.isHidden = true
                    self?.typePicker.reloadAllComponents()
                }
            }
        } else {
            isTypeLoading = false
            typePicker.isHidden = false
            typePickerSpinner.isHidden = true
            typePickerSpinner.stopAnimating()
        }
    }

    func prefillIfNeeded() {
        if let recipe = editingRecipe {
            title = "Edit Recipe"
        } else {
            title = "Add Recipe"
        }
        view.backgroundColor = .systemBackground
        if let recipe = editingRecipe {
            prefillFields(with: recipe)
        }
    }

    func prefillFields(with recipe: Recipe) {
        titleField.text = recipe.title
        if let idx = viewModel.recipeTypes.firstIndex(where: { $0.id == recipe.type.id }) {
            typePicker.selectRow(idx, inComponent: 0, animated: false)
            viewModel.selectedType = viewModel.recipeTypes[idx]
        }
        if let data = recipe.imageData, let image = UIImage(data: data) {
            imageView.image = image
            viewModel.image = image
        }
        // Prefill ingredients
        for card in ingredientCards { ingredientsStackView.removeArrangedSubview(card); card.removeFromSuperview() }
        ingredientCards.removeAll(); ingredientFields.removeAll()
        for ingredient in recipe.ingredients {
            addIngredientField()
            ingredientFields.last?.text = ingredient
        }
        if recipe.ingredients.isEmpty { addIngredientField() }
        // Prefill steps
        for card in stepCards { stepsStackView.removeArrangedSubview(card); card.removeFromSuperview() }
        stepCards.removeAll(); stepFields.removeAll()
        for step in recipe.steps {
            addStepField()
            stepFields.last?.text = step
        }
        if recipe.steps.isEmpty { addStepField() }
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
        titleCard.backgroundColor = UIColor.systemGray6
        titleCard.layer.cornerRadius = 16
        titleCard.layer.shadowColor = UIColor.black.cgColor
        titleCard.layer.shadowOpacity = 0.15
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
        typeCard.backgroundColor = UIColor.systemGray6
        typeCard.layer.cornerRadius = 16
        typeCard.layer.shadowColor = UIColor.black.cgColor
        typeCard.layer.shadowOpacity = 0.15
        typeCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        typeCard.layer.shadowRadius = 8
        contentView.addSubview(typeCard)
        typeCard.snp.makeConstraints { make in
            make.top.equalTo(titleCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(140)
        }
        typePicker.dataSource = self
        typePicker.delegate = self
        typeCard.addSubview(typePicker)
        typePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        // Add spinner in center of typeCard
        typeCard.addSubview(typePickerSpinner)
        typePickerSpinner.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        // Initial visibility
        typePicker.isHidden = isTypeLoading
        typePickerSpinner.isHidden = !isTypeLoading
        if isTypeLoading {
            typePickerSpinner.startAnimating()
        } else {
            typePickerSpinner.stopAnimating()
        }

        // Image Card
        let imageCard = UIView()
        imageCard.backgroundColor = UIColor.systemGray6
        imageCard.layer.cornerRadius = 16
        imageCard.layer.shadowColor = UIColor.black.cgColor
        imageCard.layer.shadowOpacity = 0.15
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
        contentView.addSubview(ingredientsCard)
        ingredientsCard.snp.makeConstraints { make in
            make.top.equalTo(imageCard.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ingredients"
        ingredientsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ingredientsCard.addSubview(ingredientsLabel)
        ingredientsLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(16)
        }
        // Ingredients StackView
        ingredientsStackView.axis = .vertical
        ingredientsStackView.spacing = 10
        ingredientsCard.addSubview(ingredientsStackView)
        ingredientsStackView.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }
        // Add Ingredient Button
        addIngredientButton.setTitle("+ Add Ingredient", for: .normal)
        addIngredientButton.setTitleColor(.systemBlue, for: .normal)
        addIngredientButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        addIngredientButton.addTarget(self, action: #selector(addIngredientField), for: .touchUpInside)
        ingredientsCard.addSubview(addIngredientButton)
        addIngredientButton.snp.makeConstraints { make in
            make.top.equalTo(ingredientsStackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(36)
        }
        // Add initial ingredient field
        addIngredientField()

        // Steps Card
        let stepsCard = UIView()
        contentView.addSubview(stepsCard)
        stepsCard.snp.makeConstraints { make in
            make.top.equalTo(ingredientsCard.snp.bottom).offset(10)
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
        if editingRecipe != nil {
            saveButton.setTitle("Save Changes", for: .normal)
        } else {
            saveButton.setTitle("Save Recipe", for: .normal)
        }
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
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
            if editingRecipe != nil {
                make.bottom.equalToSuperview().offset(-100)
            } else {
                make.bottom.equalToSuperview().offset(-40)
            }
        }

        // Delete Button (if editing)
        if editingRecipe != nil {
            let deleteButton = UIButton(type: .system)
            deleteButton.setTitle("Delete Recipe", for: .normal)
            deleteButton.setTitleColor(.white, for: .normal)
            deleteButton.backgroundColor = .systemRed
            deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            deleteButton.layer.cornerRadius = 10
            deleteButton.layer.shadowColor = UIColor.black.cgColor
            deleteButton.layer.shadowOpacity = 0.15
            deleteButton.layer.shadowOffset = CGSize(width: 0, height: 4)
            deleteButton.layer.shadowRadius = 8
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
            contentView.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.top.equalTo(saveButton.snp.bottom).offset(20)
                make.left.right.equalToSuperview().inset(32)
                make.height.equalTo(44)
            }
        }
    }

    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self, let editingRecipe = self.editingRecipe else { return }
            DataManager.shared.deleteRecipe(editingRecipe)
            self.onRecipeEdited?()
            self.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
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
        // Collect all ingredient fields
        let ingredients = ingredientFields.compactMap { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        viewModel.ingredients = ingredients
        // Collect all step fields
        let steps = stepFields.compactMap { $0.text?.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        viewModel.steps = steps
        if !viewModel.isValid() {
            let alert = UIAlertController(title: "Missing Info", message: "Please fill in all required fields.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        if let editingRecipe = editingRecipe {
            // Update the existing recipe
            let updatedRecipe = Recipe(
                id: editingRecipe.id,
                title: viewModel.title,
                type: viewModel.selectedType!,
                imageData: viewModel.image?.jpegData(compressionQuality: 0.8),
                ingredients: viewModel.ingredients,
                steps: viewModel.steps
            )
            DataManager.shared.updateRecipe(updatedRecipe)
            onRecipeEdited?()
        } else {
            guard let recipe = viewModel.createRecipe() else {
                let alert = UIAlertController(title: "Missing Info", message: "Please fill in all fields.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }
            DataManager.shared.addRecipe(recipe)
            onRecipeAdded?()
        }
        navigationController?.popViewController(animated: true)
    }

    @objc func addIngredientField() {
        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.layer.shadowRadius = 6
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        // Ingredient text field
        let ingredientField = UITextField()
        ingredientField.placeholder = " Ingredient "
        ingredientField.font = UIFont.systemFont(ofSize: 16)
        ingredientField.backgroundColor = .secondarySystemBackground
        ingredientField.layer.cornerRadius = 8
        ingredientField.clearButtonMode = .whileEditing
        ingredientField.autocapitalizationType = .sentences
        card.addSubview(ingredientField)
        ingredientField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ingredientField.leftAnchor.constraint(equalTo: card.leftAnchor, constant: 16),
            ingredientField.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            ingredientField.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            ingredientField.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -52),
            ingredientField.heightAnchor.constraint(equalToConstant: 36)
        ])
        // Remove button (icon)
        let removeButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 19, weight: .bold)
        removeButton.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: config), for: .normal)
        removeButton.tintColor = .systemRed
        removeButton.addTarget(self, action: #selector(removeIngredientField(_:)), for: .touchUpInside)
        card.addSubview(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            removeButton.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            removeButton.rightAnchor.constraint(equalTo: card.rightAnchor, constant: -12),
            removeButton.widthAnchor.constraint(equalToConstant: 28),
            removeButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        ingredientFields.append(ingredientField)
        ingredientCards.append(card)
        ingredientsStackView.addArrangedSubview(card)
        // Animate appearance
        UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut], animations: {
            card.alpha = 1
            card.transform = .identity
        }, completion: nil)
    }

    @objc func removeIngredientField(_ sender: UIButton) {
        guard let card = sender.superview, let index = ingredientCards.firstIndex(of: card) else { return }
        ingredientFields.remove(at: index)
        ingredientCards.remove(at: index)
        UIView.animate(withDuration: 0.18, animations: {
            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            self.ingredientsStackView.removeArrangedSubview(card)
            card.removeFromSuperview()
        })
    }

    @objc func addStepField() {
        let card = UIView()
        card.backgroundColor = UIColor.systemGray6
        card.layer.cornerRadius = 14
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
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
        stepField.placeholder = " Step description "
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
