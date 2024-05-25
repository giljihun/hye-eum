//
//  ViewController.swift
//  hye_eum
//
//  Created by mobicom on 5/9/24.
//

import UIKit

class MainPageController: UIViewController {
    
    // MARK: - UI Property
    
    private lazy var floatingButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.addTarget(self, action: #selector(floatingBtnTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "pencil")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside) // createButton을 눌렀을 때의 액션 추가
        return button
    }()
    
    private let statButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemPink
        config.cornerStyle = .capsule
        config.image = UIImage(systemName: "camera.filters")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .medium))
        button.configuration = config
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        button.alpha = 0.0
        button.addTarget(self, action: #selector(statButtonTapped), for: .touchUpInside) // createButton을 눌렀을 때의 액션 추가
        return button
    }()
    
    private var isActive: Bool = false {
        didSet {
            showActionButtons()
        }
    }
    
    private var animation: UIViewPropertyAnimator?
    
    // MARK: - UI CollectionView
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    // MARK: - MyCollectionView
    
    // cell의 너비와 cell의 좌/우 spacing 조정
    private enum Const {
        static let itemSize = CGSize(width: 280, height: 450)
        static let itemSpacing = 24.0
        
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - Self.itemSize.width) / 2.0
        }
        
        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: Self.insetX, bottom: 0, right: Self.insetX)
        }
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Const.itemSize // <-
        layout.minimumLineSpacing = Const.itemSpacing // <-
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    private func myCollectionViewInit() {
        self.myCollectionView.collectionViewLayout = self.collectionViewFlowLayout
        self.myCollectionView.isScrollEnabled = true
        self.myCollectionView.showsHorizontalScrollIndicator = false
        self.myCollectionView.showsVerticalScrollIndicator = true
        self.myCollectionView.backgroundColor = .clear
        self.myCollectionView.clipsToBounds = true
        self.myCollectionView.register(UINib(nibName: "MyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MyCollectionViewCell")
        self.myCollectionView.isPagingEnabled = false // <- 한 페이지의 넓이를 조절 할 수 없기 때문에 scrollViewWillEndDragging을 사용하여 구현
        self.myCollectionView.contentInsetAdjustmentBehavior = .never // <- 내부적으로 safe area에 의해 가려지는 것을 방지하기 위해서 자동으로 inset조정해 주는 것을 비활성화
        self.myCollectionView.contentInset = Const.collectionViewContentInset // <-
        self.myCollectionView.decelerationRate = .fast // <- 스크롤이 빠르게 되도록 (페이징 애니메이션같이 보이게하기 위함)
        self.myCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        self.myCollectionView.dataSource = self
        self.myCollectionView.delegate = self
        
        self.myCollectionViewInit()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 8 - 40, width: 60, height: 60)
        createButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 80 - 8 - 40, width: 60, height: 60)
        statButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 160 - 8 - 40, width: 60, height: 60)
    }
    
    // MARK: - UI 설정
    
    private func setUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(floatingButton)
        view.addSubview(createButton)
        view.addSubview(statButton)
    }

    
    // MARK: - 버튼 액션 메서드
    
    @objc private func floatingBtnTapped() {
        isActive.toggle()
    }
    
    // statButton을 눌렀을 때의 액션 메서드
    @objc private func statButtonTapped() {
        // StatPage로 이동
        if let statPageVC = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "StatsPageController") as? StatsPageController {
            navigationController?.pushViewController(statPageVC, animated: true)
        }
        // 네비게이션 바 안보이게
        // self.navigationController?.navigationBar.isHidden = true
        // 제스처로 뒤로가는 기능 삭제
        // self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    // createButton을 눌렀을 때의 액션 메서드
    @objc private func createButtonTapped() {
        // StatPage로 이동
        if let createPageVC = UIStoryboard(name: "MainPage", bundle: nil).instantiateViewController(withIdentifier: "CreateDiaryPageController") as? CreateDiaryPageController {
            navigationController?.pushViewController(createPageVC, animated: true)
        }
        // 네비게이션 바 안보이게
        // self.navigationController?.navigationBar.isHidden = true
        // 제스처로 뒤로가는 기능 삭제
        // self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    // MARK: - 애니메이션 메서드
    
    private func showActionButtons() {
        popButtons()
        rotateFloatingButton()
    }
    
    private func popButtons() {
        if isActive {
            createButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.createButton.layer.transform = CATransform3DIdentity
                self.createButton.alpha = 1.0
            })
            
            statButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 1)
            UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.3, options: [.curveEaseInOut], animations: { [weak self] in
                guard let self = self else { return }
                self.statButton.layer.transform = CATransform3DIdentity
                self.statButton.alpha = 1.0
            })
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.2, options: []) { [weak self] in
                guard let self = self else { return }
                self.createButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.createButton.alpha = 0.0
                self.statButton.layer.transform = CATransform3DMakeScale(0.4, 0.4, 0.1)
                self.statButton.alpha = 0.0
            }
        }
    }
    
    private func rotateFloatingButton() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let fromValue = isActive ? 0 : CGFloat.pi / 4
        let toValue = isActive ? CGFloat.pi / 4 : 0
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = 0.3
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        floatingButton.layer.add(animation, forKey: nil)
    }
}

extension MainPageController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.myCollectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        return cell
    }
    
    
}

extension MainPageController: UICollectionViewDelegateFlowLayout {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
    }
}
