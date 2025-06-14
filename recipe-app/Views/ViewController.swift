//
//  ViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UINavigationControllerDelegate {
    // UI Components
    let tableView = UITableView()
    var addButton: UIBarButtonItem!
    var filterButton: UIBarButtonItem!
    private var typePickerPopup: RecipeTypePickerPopup?

    // ViewModel
    let viewModel = RecipeListViewModel()

    var selectedCellImageView: UIImageView?
    var selectedDetailImageView: UIImageView?

    override func viewDidLoad() {
        print("ViewController viewDidLoad: setting navigationController.delegate")
        super.viewDidLoad()
        title = "Recipes"
        view.backgroundColor = .white

        setupUI()
        bindViewModel()
        viewModel.loadData()
        navigationController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear: setting navigationController.delegate")
        navigationController?.delegate = self
    }

    private func setupUI() {
        // TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: RecipeTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
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
    }

    private func bindViewModel() {
        viewModel.onDataChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    @objc private func filterTapped() {
        let popup = RecipeTypePickerPopup()
        popup.pickerView.dataSource = self
        popup.pickerView.delegate = self
        let idx: Int
        if let selectedType = viewModel.selectedType,
           let foundIdx = viewModel.recipeTypes.firstIndex(where: { $0.id == selectedType.id }) {
            idx = foundIdx
        } else {
            idx = 0 // Default to 'All'
        }
        popup.pickerView.selectRow(idx, inComponent: 0, animated: false)

        popup.onApply = { [weak self] selectedRow in
            guard let self = self else { return }
            self.viewModel.selectedType = self.viewModel.recipeTypes[selectedRow]
            self.viewModel.filterRecipes()
            self.tableView.reloadData()
        }
        popup.onCancel = { }
        typePickerPopup = popup
        popup.present(in: self.view)
    }

    @objc private func addRecipeTapped() {
        let addVC = AddRecipeViewController()
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
        detailVC.onRecipeUpdated = { [weak self] in
            self?.viewModel.loadData()
        }
        detailVC.onRecipeDeleted = { [weak self] in
            self?.viewModel.loadData()
        }
        // Store references for transition
        selectedCellImageView = cell.recipeImageView
        // Ensure delegate is set just before push
        navigationController?.delegate = self
        print("Set navigationController.delegate = self before push to detail")
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension ViewController {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("[DEBUG] navigationController: \(navigationController)")
        print("[DEBUG] operation: \(operation.rawValue) (\(operation == .push ? "push" : operation == .pop ? "pop" : "other"))")
        print("[DEBUG] fromVC: \(type(of: fromVC)), toVC: \(type(of: toVC))")
        if operation == .push,
           let cellImageView = selectedCellImageView,
           let detailVC = toVC as? RecipeDetailViewController {
            detailVC.loadViewIfNeeded()
            detailVC.view.layoutIfNeeded()
            let destImageView = detailVC.imageView
            print("[DEBUG] Custom animator will be used. cellImageView: \(cellImageView), destImageView: \(destImageView)")
            return RecipeImageTransitionAnimator(originImageView: cellImageView, destinationImageView: destImageView, isPresenting: true)
        } else if operation == .pop,
           let detailVC = fromVC as? RecipeDetailViewController,
           let cellImageView = selectedCellImageView {
            // Find the visible cell for the recipe
            detailVC.loadViewIfNeeded()
            detailVC.view.layoutIfNeeded()
            let originImageView = detailVC.imageView
            print("[DEBUG] Pop animator: originImageView: \(originImageView), cellImageView: \(cellImageView)")
            return RecipeImageTransitionAnimator(originImageView: originImageView, destinationImageView: cellImageView, isPresenting: false)
        } else {
            print("[DEBUG] Custom animator NOT used. Reason:")
            if operation != .push && operation != .pop { print("- Not a push or pop operation") }
            if selectedCellImageView == nil { print("- selectedCellImageView is nil") }
            if !(toVC is RecipeDetailViewController) && !(fromVC is RecipeDetailViewController) { print("- Neither toVC nor fromVC is RecipeDetailViewController") }
            return nil
        }
    }
}
