//
//  ViewController.swift
//  hye_eum
//
//  Created by mobicom on 5/9/24.
//

import UIKit

class MainPageController: UIViewController {
    // MARK: - Book Struct
    struct LibraryResponse: Codable {
        let id: Int
        let user_id: Int
        let books: [Book]
        let statistics: [Statistics]
        let book_count: Int
        
        struct Book: Codable {
            let id: Int
            let library_id: Int
            let image: String
            let comment: String
            let detail_story: String
            let emotion: String
            let created_at: String
        }
        
        struct Statistics: Codable {
            let happiness: Int
            let aggro: Int
            let sadness: Int
            let joy: Int
            let gpt_comment: String
            let library_id: Int
        }
    }
    
    // MARK: - UI outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var booksView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    // MARK: - UI Property
    
    var books: [LibraryResponse.Book] = []
    
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
    
    let userTag = UserDefaults.standard.integer(forKey: "user_tag")
    let libraryID = UserDefaults.standard.integer(forKey: "library_id")
    
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
        titleLabel.alpha = 0.0
        optionBtn.alpha = 0.0
        booksView.alpha = 0.0
        
        
        noDataLabelAnimation()
        
        self.myCollectionView.dataSource = self
        self.myCollectionView.delegate = self
        
        self.myCollectionViewInit()
        
        fetchLibrary()
        
        startAnimation()
    }
    
    func noDataLabelAnimation() {
        let fadeDuration = 1.5 // 페이드 인 시간 설정
        let scaleDuration = 1.3 // 크기 조정 시간 설정
        let scaleMultiplier: CGFloat = 1.2 // 크기를 키우는 배수 설정
        
        // 애니메이션 1: 페이드 인 및 크기 조정
        UIView.animate(withDuration: fadeDuration, animations: {
            self.noDataLabel.alpha = 1.0
            self.noDataLabel.transform = CGAffineTransform(scaleX: scaleMultiplier, y: scaleMultiplier)
        }, completion: { _ in
            // 애니메이션 2: 원래 크기로 되돌리기
            UIView.animate(withDuration: scaleDuration, animations: {
                self.noDataLabel.transform = CGAffineTransform.identity
            }, completion: { _ in
                // 애니메이션 반복
                self.noDataLabelAnimation()
            })
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 8 - 40, width: 60, height: 60)
        createButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 80 - 8 - 40, width: 60, height: 60)
        statButton.frame = CGRect(x: view.frame.size.width - 60 - 8 - 20, y: view.frame.size.height - 60 - 160 - 8 - 40, width: 60, height: 60)
    }
    
    // MARK: - UI 설정
    
    private func setUI() {
        view.alpha = 0.0
        view.backgroundColor = .systemBackground
        view.addSubview(floatingButton)
        view.addSubview(createButton)
        view.addSubview(statButton)
        
        
    }
    // MARK: - 애니메이션 메서드
    let fadeDuration: TimeInterval = 1.0
    
    private func startAnimation() {
        
        UIView.animate(withDuration: fadeDuration) {
            self.view.alpha = 1.0
            self.titleLabel.alpha = 1.0
            self.optionBtn.alpha = 1.0
            self.booksView.alpha = 1.0
        }
    }
    
    
    // MARK: - 버튼 액션 메서드
    
    @objc private func floatingBtnTapped() {
        isActive.toggle()
    }
    
    // statButton을 눌렀을 때의 액션 메서드
    @objc private func statButtonTapped() {
        isActive.toggle()
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
        isActive.toggle()
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
    
    // MARK: - Book 객체 가져오기
    func fetchLibrary() {
        print("fetching!")
        let url = URL(string: "https://port-0-hyeeum-backend-9zxht12blqj9n2fu.sel4.cloudtype.app/library?user_tag=\(userTag)")!
        print(userTag)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                return
            }

            do {
                let response = try JSONDecoder().decode([LibraryResponse].self, from: data)
                if let libraryResponse = response.first {
                    
                    // print(libraryResponse.books)
                    self.books = response.flatMap { $0.books }
                    
                    if let lastLibraryResponse = response.last,
                       let lastStatistics = lastLibraryResponse.statistics.last {
                        let lastLibraryID = lastStatistics.library_id
                        print("라스트 library_id : \(lastLibraryID)")
                        
                        // UserDefaults에서 이전 library_id 값 가져오기
                        let previousLibraryID = UserDefaults.standard.integer(forKey: "previous_library_id")
                        
                        if previousLibraryID == 0 {
                            // 현재 library_id 값을 이전 값과 현재 값 모두에 저장
                            UserDefaults.standard.set(lastLibraryID, forKey: "previous_library_id")
                            UserDefaults.standard.set(lastLibraryID, forKey: "current_library_id")
                        } else {
                            // 현재 library_id 값이 이전 값과 다른 경우
                            if lastLibraryID != previousLibraryID {
                                // 이전 library_id 값을 업데이트
                                UserDefaults.standard.set(previousLibraryID, forKey: "previous_library_id")
                                print("라이브러리 값이 바뀜")
                                print("이전 library_id : \(previousLibraryID)")
                                // 현재 library_id 값을 저장
                                UserDefaults.standard.set(lastLibraryID, forKey: "current_library_id")
                                print("현재 library_id : \(lastLibraryID)")
                            } else {
                                // 현재 library_id 값을 저장
                                print("라이브러리 값 변동 X")
                                UserDefaults.standard.set(lastLibraryID, forKey: "current_library_id")
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.myCollectionView.reloadData()
                }
            } catch {
                print("JSON decoding error: \(error)")
            }
        }.resume()
    }
}

extension MainPageController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if books.count == 0 {
            // books 배열이 비어있으면 noDataLabel을 표시합니다.
            noDataLabel.isHidden = false
            collectionView.isHidden = true
            return 0
        } else {
            // books 배열에 데이터가 있으면 컬렉션뷰를 표시합니다.
            noDataLabel.isHidden = true
            collectionView.isHidden = false
            return books.count
        }
        
//        // collectionview 보여주는 테스트 코드
//        if books.count == 0 {
//            // books 배열이 비어있으면 noDataLabel을 표시합니다.
//            noDataLabel.isHidden = true
//            collectionView.isHidden = false
//            return 10
//        } else {
//            // books 배열에 데이터가 있으면 컬렉션뷰를 표시합니다.
//            noDataLabel.isHidden = false
//            collectionView.isHidden = true
//            return books.count
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.myCollectionView.dequeueReusableCell(withReuseIdentifier: "MyCollectionViewCell", for: indexPath) as! MyCollectionViewCell
        let book = books[indexPath.row]
        cell.configure(with: book)
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

extension MainPageController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedBook = books[indexPath.item]
        
        // DetailPage 인스턴스 생성
        guard let detailPageViewController = storyboard?.instantiateViewController(withIdentifier: "DetailPageController") as? DetailPageController else {
            return
        }
        
        // 선택된 책 정보를 DetailPage로 전달
        detailPageViewController.book = selectedBook
        
        // 모달 스타일 설정
        detailPageViewController.modalPresentationStyle = .pageSheet
        
        // 모달 띄우기
        present(detailPageViewController, animated: true, completion: nil)
    }
}
