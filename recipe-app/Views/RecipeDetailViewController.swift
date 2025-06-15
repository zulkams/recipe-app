//
//  RecipeDetailViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit
import SnapKit
import SDWebImage

class RecipeDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let viewModel: RecipeDetailViewModel
    var onRecipeUpdated: (() -> Void)?

    // UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let imageView = UIImageView()
    let titleField = UITextField()
    let typeLabel = UILabel()
    let ingredientsField = UITextView()
    let stepsField = UITextView()

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
    }

    func setupUI() {
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
        ingredientsCard.backgroundColor = UIColor.systemGray6
        ingredientsCard.layer.cornerRadius = 16
        ingredientsCard.layer.masksToBounds = false
        ingredientsCard.layer.shadowColor = UIColor.black.cgColor
        ingredientsCard.layer.shadowOpacity = 0.15
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
        ingredientsField.isScrollEnabled = false
        ingredientsCard.addSubview(ingredientsField)
        ingredientsField.snp.makeConstraints { make in
            make.top.equalTo(ingredientsLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview().inset(12)
        }

        // Steps Card
        let stepsCard = UIView()
        stepsCard.backgroundColor = UIColor.systemGray6
        stepsCard.layer.cornerRadius = 16
        stepsCard.layer.masksToBounds = false
        stepsCard.layer.shadowColor = UIColor.black.cgColor
        stepsCard.layer.shadowOpacity = 0.15
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
        stepsField.isScrollEnabled = false // Allow UITextView to expand
        stepsCard.addSubview(stepsField)
        stepsField.snp.makeConstraints { make in
            make.top.equalTo(stepsLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview().inset(12)
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
        let addVC = AddRecipeViewController(recipeToEdit: viewModel.recipe)
        addVC.onRecipeEdited = { [weak self] in
            self?.viewModel.reloadRecipe()
            self?.displayRecipe()
            self?.onRecipeUpdated?()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
}
