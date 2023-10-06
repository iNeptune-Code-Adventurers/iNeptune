//
//  ViewController.swift
//  2주차 위클리미션
//
//  Created by 제민우 on 2023/10/02.
//

import UIKit

final class ViewController: UIViewController {

    private let dummyVC = DummyViewController()
    
    private var productsArray: [ProductModel] = []
    
    private var productDataManager = ProductDataManager()
    
    private let productTableView = UITableView()
    
    private let postFloatingButton = PostFloatingButton()
    
    private var widthConstraint: NSLayoutConstraint?
    
    let refreshControl = UIRefreshControl()

    lazy var myNeighborhoodButton: UIButton = {
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.attributedTitle = AttributedString("대연제4동", attributes: container)
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        config.image = UIImage(systemName: "chevron.down", withConfiguration: symbolConfig)
        config.imagePlacement = .trailing
        config.imagePadding = 3
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let button = UIButton(configuration: config)
        
        let mainNeighborhood = UIAction(
            title: "내 동네",
            image: nil,
            handler: { _ in print("내 동네")}
        )
        let subNeighborhood = UIAction(
            title: "다른 동네",
            image: nil,
            handler: { _ in print("다른 동네")}
        )
        let setMyNeighborhood = UIAction(
            title: "내 동네 설정하기",
            image: nil,
            handler: { _ in print("내 동네 설정하기")}
        )
        
        button.menu = UIMenu(options: .displayInline, children: [mainNeighborhood, subNeighborhood, setMyNeighborhood])
        button.showsMenuAsPrimaryAction = true
        button.changesSelectionAsPrimaryAction = true
    
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureInitialSetting()
        configureNaviBarLayout()
        configureNaviBarItem()
        configureSubViews()
        configureLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let safeAreaHeight = view.frame.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        productTableView.rowHeight = safeAreaHeight / 4.7
    }
}

// MARK: Implement TableView DataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        cell.productImage.image = productsArray[indexPath.row].productImage
        cell.productTitle.text = productsArray[indexPath.row].productTitle
        cell.productDescription.text = productsArray[indexPath.row].productDescription
        cell.productPrice.text = productsArray[indexPath.row].productPrice
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: Implement TableView Delegate

extension ViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if productTableView.contentOffset.y <= 0 {
            postFloatingButton.configuration = postFloatingButton.configureCapsuleFloatingButton()
            widthConstraint?.isActive = false
            widthConstraint = postFloatingButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25)
            widthConstraint?.isActive = true
            postFloatingButton.layoutIfNeeded()
        } else if productTableView.contentOffset.y > 0  {
            postFloatingButton.configuration = postFloatingButton.configureCircleFloatingButton()
            widthConstraint?.isActive = false
            widthConstraint = postFloatingButton.widthAnchor.constraint(equalTo: postFloatingButton.heightAnchor)
            widthConstraint?.isActive = true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.pushViewController(dummyVC, animated: true)
    }
}

// MARK: Configure Initial Setting

extension ViewController {
    private func configureInitialSetting() {
        productsArray = productDataManager.fetchProductData()
        
        productTableView.dataSource = self
        productTableView.delegate = self
        productTableView.register(ProductCell.self, forCellReuseIdentifier: "ProductCell")
        
        refreshControl.tintColor = .orange
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        productTableView.refreshControl = refreshControl
        
        productTableView.scrollsToTop = true
    }
}

// MARK: Configure Navigation Controller

extension ViewController {
    
    private func configureNaviBarLayout() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func configureNaviBarItem() {
        
        lazy var allServiceButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "text.justify"), for: .normal)
            button.addTarget(self, action: #selector(didTapNaviBarRightItems), for: .touchUpInside)
            return button
        }()
        
        lazy var findButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            button.addTarget(self, action: #selector(didTapNaviBarRightItems), for: .touchUpInside)
            return button
        }()
        lazy var notificationButton: UIButton = {
            let button = UIButton(type: .custom)
            button.setImage(UIImage(systemName: "bell"), for: .normal)
            button.addTarget(self, action: #selector(didTapNaviBarRightItems), for: .touchUpInside)
            return button
        }()

        lazy var rightBarButtonStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [findButton, allServiceButton, notificationButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            stackView.spacing = 15
            return stackView
        }()
        
        allServiceButton.tintColor = .black
        findButton.tintColor = .black
        notificationButton.tintColor = .black

        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 15
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: myNeighborhoodButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButtonStackView)
    }
}

// MARK: Configure AddTarget

extension ViewController {
    @objc private func didTapNaviBarRightItems() {
        navigationController?.pushViewController(dummyVC, animated: true)
    }
    
    @objc private func didTapMyNeighborHoodButton() {
        myNeighborhoodButton.isSelected.toggle()
    }
    
    @objc private func refreshData(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.productTableView.reloadData()
            sender.endRefreshing()
        }
    }
}


// MARK: Configure Layout

extension ViewController {
    
    private func configureSubViews() {
        view.addSubview(productTableView)
        productTableView.translatesAutoresizingMaskIntoConstraints = false
        
        productTableView.addSubview(postFloatingButton)
        postFloatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        productTableView.addSubview(refreshControl)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // MARK: ProductTableView Constraints
            
            productTableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            productTableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            productTableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            productTableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            
            // MARK: postFloatingButton Constraints
            postFloatingButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.06),
            postFloatingButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -15),
            postFloatingButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -15)
        ])
    }
}
