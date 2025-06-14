import UIKit
import SnapKit
import SDWebImage

class RecipeDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let viewModel: RecipeDetailViewModel
    var onRecipeUpdated: (() -> Void)?
    var onRecipeDeleted: (() -> Void)?

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView = UIImageView()
    let titleField = UITextField()
    let typeLabel = UILabel()
    let ingredientsField = UITextView()
    let stepsField = UITextView()
    let saveButton = UIButton(type: .system)
    let deleteButton = UIButton(type: .system)

    // Editing
    var isEditingRecipe = false {
        didSet {
            updateEditingState()
        }
    }

    init(recipe: Recipe) {
        self.viewModel = RecipeDetailViewModel(recipe: recipe)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Recipe Detail"
        view.backgroundColor = .systemBackground
        setupUI()
        displayRecipe()
        updateEditingState()
    }

    func setupUI() {
        // Enable image tap in edit mode
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture);
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // Image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 24
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.15
        imageView.layer.shadowOffset = CGSize(width: 0, height: 8)
        imageView.layer.shadowRadius = 16
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }

        // Title
        titleField.borderStyle = .none
        titleField.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleField.textAlignment = .center
        titleField.textColor = .label
        contentView.addSubview(titleField)
        titleField.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(40)
        }

        // Type
        typeLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        typeLabel.textColor = .systemBlue
        typeLabel.textAlignment = .center
        contentView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(24)
        }

        // Ingredients Card
        let ingredientsCard = UIView()
        ingredientsCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        ingredientsCard.layer.cornerRadius = 16
        ingredientsCard.layer.masksToBounds = false
        ingredientsCard.layer.shadowColor = UIColor.black.cgColor
        ingredientsCard.layer.shadowOpacity = 0.07
        ingredientsCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        ingredientsCard.layer.shadowRadius = 10
        contentView.addSubview(ingredientsCard)
        ingredientsCard.snp.makeConstraints { make in
            make.top.equalTo(typeLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
        }
        let ingredientsLabel = UILabel()
        ingredientsLabel.text = "Ingredients"
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
            make.height.equalTo(70)
        }

        // Steps Card
        let stepsCard = UIView()
        stepsCard.backgroundColor = UIColor.secondarySystemBackground.withAlphaComponent(0.7)
        stepsCard.layer.cornerRadius = 16
        stepsCard.layer.masksToBounds = false
        stepsCard.layer.shadowColor = UIColor.black.cgColor
        stepsCard.layer.shadowOpacity = 0.07
        stepsCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        stepsCard.layer.shadowRadius = 10
        contentView.addSubview(stepsCard)
        stepsCard.snp.makeConstraints { make in
            make.top.equalTo(ingredientsCard.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(16)
        }
        let stepsLabel = UILabel()
        stepsLabel.text = "Steps"
        stepsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        stepsCard.addSubview(stepsLabel)
        stepsLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(16)
        }
        stepsField.layer.cornerRadius = 10
        stepsField.backgroundColor = .clear
        stepsField.font = UIFont.systemFont(ofSize: 16)
        stepsField.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        stepsCard.addSubview(stepsField)
        stepsField.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview().inset(12)
            make.height.equalTo(100)
        }

        // Save Button
        saveButton.setTitle("Save Changes", for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 12
        saveButton.layer.shadowColor = UIColor.systemBlue.cgColor
        saveButton.layer.shadowOpacity = 0.15
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 8
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        contentView.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(stepsCard.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(60)
            make.height.equalTo(48)
        }

        // Delete Button
        deleteButton.setTitle("Delete Recipe", for: .normal)
        deleteButton.setTitleColor(.white, for: .normal)
        deleteButton.backgroundColor = .systemRed
        deleteButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        deleteButton.layer.cornerRadius = 12
        deleteButton.layer.shadowColor = UIColor.systemRed.cgColor
        deleteButton.layer.shadowOpacity = 0.13
        deleteButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        deleteButton.layer.shadowRadius = 8
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(60)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-32)
        }

        // Edit button in nav bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
    }

    func displayRecipe() {
        if let image = viewModel.image {
            imageView.image = image
            imageView.tintColor = nil
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
        }
        titleField.text = viewModel.title
        typeLabel.text = "Type: \(viewModel.typeName)"
        ingredientsField.text = viewModel.ingredientsText()
        stepsField.text = viewModel.stepsText()
    }

    func updateEditingState() {
        let editing = isEditingRecipe
        titleField.isUserInteractionEnabled = editing
        ingredientsField.isEditable = editing
        stepsField.isEditable = editing
        saveButton.isHidden = !editing
        deleteButton.isHidden = !editing
        navigationItem.rightBarButtonItem?.isEnabled = !editing
        imageView.alpha = editing ? 0.85 : 1.0
    }

    @objc func imageTapped() {
        guard isEditingRecipe else { return }
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @objc func editTapped() {
        isEditingRecipe = true
    }

    @objc func saveTapped() {
        guard let title = titleField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Missing Info", message: "Please enter a title.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        viewModel.title = title
        viewModel.setIngredients(from: ingredientsField.text)
        viewModel.setSteps(from: stepsField.text)
        viewModel.image = imageView.image
        viewModel.updateRecipe()
        isEditingRecipe = false
        onRecipeUpdated?()
    }

    @objc func deleteTapped() {
        let alert = UIAlertController(title: "Delete Recipe", message: "Are you sure you want to delete this recipe?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.deleteRecipe()
            self.onRecipeDeleted?()
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
