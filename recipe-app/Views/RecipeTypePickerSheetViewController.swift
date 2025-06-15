//
//  RecipeTypePickerSheetViewController.swift
//  recipe-app
//
//  Created by Zul Kamal on 14/06/2025.
//

import UIKit

class RecipeTypePickerSheetViewController: UIViewController {
    var recipeTypes: [RecipeType] = []
    var selectedType: RecipeType?
    var onApply: ((RecipeType) -> Void)?
    var onCancel: (() -> Void)?
    private let pickerView = UIPickerView()
    private let cancelButton = UIButton(type: .system)
    private let doneButton = UIButton(type: .system)
    private let buttonStack = UIStackView()
    private var selectedRow: Int = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let sheet = self.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupFilterBottomSheet()
    }

    private func setupFilterBottomSheet() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 0
        buttonStack.addArrangedSubview(cancelButton)
        buttonStack.addArrangedSubview(doneButton)
        view.addSubview(buttonStack)
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(pickerView)
        if let selectedType = selectedType,
           let idx = recipeTypes.firstIndex(where: { $0.id == selectedType.id }) {
            pickerView.selectRow(idx, inComponent: 0, animated: false)
            selectedRow = idx
        }
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(buttonStack.snp.bottom)
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func cancelTapped() {
        onCancel?()
        dismiss(animated: true)
    }
    @objc private func doneTapped() {
        let type = recipeTypes[selectedRow]
        onApply?(type)
        dismiss(animated: true)
    }
}

extension RecipeTypePickerSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeTypes[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRow = row
    }
}
