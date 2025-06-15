//
//  RecipeTableViewCell.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    static let identifier = "RecipeTableViewCell"

    
    let cardView = UIView()
    let recipeImageView = UIImageView()
    let titleLabel = UILabel()
    let typeLabel = UILabel()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupCardView()
        setupImageView()
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCardView() {
        cardView.backgroundColor = UIColor.systemGray6
        cardView.layer.cornerRadius = 14
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)
        // shadow
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.15
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().inset(16)
        }
    }
    
    private func setupImageView() {
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.backgroundColor = .tertiarySystemFill
        recipeImageView.layer.borderColor = UIColor.separator.cgColor
        recipeImageView.layer.borderWidth = 1
        cardView.addSubview(recipeImageView)
        recipeImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(52)
        }
    }
    
    private func setupLabels() {
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(recipeImageView.snp.right).offset(14)
            make.right.equalToSuperview().inset(16)
        }
        
        // Type label
        typeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        typeLabel.textColor = .secondaryLabel
        typeLabel.textAlignment = .center
        typeLabel.setContentHuggingPriority(.required, for: .vertical)
        cardView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.left.equalTo(recipeImageView.snp.right).offset(14)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(44)
            make.bottom.lessThanOrEqualToSuperview().inset(14)
        }
    }
    
    func configure(with recipe: Recipe) {
        titleLabel.text = recipe.title
        typeLabel.text = recipe.type.name
        if let data = recipe.imageData, let image = UIImage(data: data) {
            recipeImageView.image = image
            recipeImageView.tintColor = nil
        } else {
            recipeImageView.image = UIImage(systemName: "photo")
            recipeImageView.tintColor = .systemGray3
        }
    }
}
