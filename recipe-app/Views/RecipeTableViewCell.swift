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
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 14
        cardView.layer.masksToBounds = true
        cardView.layer.borderColor = UIColor.separator.cgColor
        cardView.layer.borderWidth = 1
        // Remove shadow and accent
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            cardView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16)
        ])
    }
    
    private func setupImageView() {
        recipeImageView.contentMode = .scaleAspectFill
        recipeImageView.clipsToBounds = true
        recipeImageView.layer.cornerRadius = 12
        recipeImageView.backgroundColor = .tertiarySystemFill
        recipeImageView.layer.borderColor = UIColor.separator.cgColor
        recipeImageView.layer.borderWidth = 1
        cardView.addSubview(recipeImageView)
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeImageView.leftAnchor.constraint(equalTo: cardView.leftAnchor, constant: 12),
            recipeImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 52),
            recipeImageView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func setupLabels() {
        // Title label
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        cardView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leftAnchor.constraint(equalTo: recipeImageView.rightAnchor, constant: 14),
            titleLabel.rightAnchor.constraint(equalTo: cardView.rightAnchor, constant: -16)
        ])
        
        // Type label as subtle pill
        typeLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        typeLabel.textColor = .secondaryLabel
        typeLabel.backgroundColor = .systemFill
        typeLabel.textAlignment = .center
        typeLabel.layer.cornerRadius = 9
        typeLabel.layer.masksToBounds = true
        typeLabel.setContentHuggingPriority(.required, for: .vertical)
        cardView.addSubview(typeLabel)
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            typeLabel.leftAnchor.constraint(equalTo: recipeImageView.rightAnchor, constant: 14),
            typeLabel.heightAnchor.constraint(equalToConstant: 18),
            typeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            typeLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -14)
        ])
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
