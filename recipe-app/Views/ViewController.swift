//
//  ViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    private func showLoadingIndicator() {
        loadingIndicator.startAnimating()
        loadingIndicator.isHidden = false
    }
    private func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
    }
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    // UI Components
    let tableView = UITableView()
    var addButton: UIBarButtonItem!
    var filterButton: UIBarButtonItem!

    // ViewModel
    let viewModel = RecipeListViewModel()

    var selectedCellImageView: UIImageView?
    var selectedDetailImageView: UIImageView?

    override func viewDidLoad() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        super.viewDidLoad()
        title = "Recipes"
        view.backgroundColor = .systemBackground

        setupUI()
        bindViewModel()
        showLoadingIndicator()
        view.isUserInteractionEnabled = false
        viewModel.loadData { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.view.isUserInteractionEnabled = true
                self?.tableView.reloadData()
            }
        }
        navigationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }

    private let floatingLogoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("⎋", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.layer.cornerRadius = 28
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.2
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        btn.addTarget(nil, action: #selector(logoutTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private func setupUI() {
        // TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: RecipeTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }

        // Add Button
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRecipeTapped))
        filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterTapped))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = filterButton

        // Floating Logout Button
        view.addSubview(floatingLogoutButton)
        floatingLogoutButton.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).inset(24)
        }
    }

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func filterTapped() {
        let sheetVC = RecipeTypePickerSheetViewController()
        sheetVC.recipeTypes = viewModel.recipeTypes
        sheetVC.selectedType = viewModel.selectedType
        sheetVC.onApply = { [weak self] selectedType in
            self?.viewModel.selectedType = selectedType
            self?.viewModel.filterRecipes()
        }
        sheetVC.onCancel = { }
        sheetVC.modalPresentationStyle = .pageSheet
        if let sheet = sheetVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(sheetVC, animated: true)
    }

    @objc private func logoutTapped() {
        floatingLogoutButton.isEnabled = false
        floatingLogoutButton.alpha = 0.6
        AuthAPI.shared.logout { [weak self] result in
            DispatchQueue.main.async {
                self?.floatingLogoutButton.isEnabled = true
                self?.floatingLogoutButton.alpha = 1.0
                switch result {
                case .success:
                    let loginVC = LoginViewController()
                    loginVC.modalPresentationStyle = .fullScreen
                    self?.present(loginVC, animated: true)
                case .failure(let error):
                    let alert = UIAlertController(title: "Logout Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

    @objc private func addRecipeTapped() {
        let addVC = AddRecipeViewController(preloadedTypes: viewModel.recipeTypes)
        addVC.onRecipeAdded = { [weak self] in
            self?.viewModel.loadData()
        }
        navigationController?.pushViewController(addVC, animated: true)
    }
}

// MARK: - UIPickerView DataSource & Delegate
extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.recipeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.recipeTypes[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Do nothing here. Only update filter when Apply is tapped in the popup.
    }
}

// MARK: - UITableView DataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredRecipes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecipeTableViewCell.identifier, for: indexPath) as? RecipeTableViewCell else {
            return UITableViewCell()
        }
        let recipe = viewModel.filteredRecipes[indexPath.row]
        cell.configure(with: recipe)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell else { return }
        UIView.animate(withDuration: 0.08, animations: {
            cell.cardView.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }, completion: { _ in
            UIView.animate(withDuration: 0.10) {
                cell.cardView.transform = .identity
            }
        })
        tableView.deselectRow(at: indexPath, animated: true)
        let recipe = viewModel.filteredRecipes[indexPath.row]
        let detailVC = RecipeDetailViewController(recipe: recipe)
        detailVC.preloadedTypes = viewModel.recipeTypes
        detailVC.onRecipeUpdated = { [weak self] in
            self?.viewModel.loadData()
        }
        // Store references for transition
        selectedCellImageView = cell.recipeImageView
        // Ensure delegate is set just before push
        navigationController?.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push,
           let cellImageView = selectedCellImageView,
           let detailVC = toVC as? RecipeDetailViewController {
            detailVC.loadViewIfNeeded()
            detailVC.view.layoutIfNeeded()
            let destImageView = detailVC.imageView
            return RecipeImageTransitionAnimator(originImageView: cellImageView, destinationImageView: destImageView, isPresenting: true)
        } else if operation == .pop,
           let detailVC = fromVC as? RecipeDetailViewController,
           let cellImageView = selectedCellImageView {
            // Find the visible cell for the recipe
            detailVC.loadViewIfNeeded()
            detailVC.view.layoutIfNeeded()
            let originImageView = detailVC.imageView
            return RecipeImageTransitionAnimator(originImageView: originImageView, destinationImageView: cellImageView, isPresenting: false)
        } else {
            return nil
        }
    }
}
