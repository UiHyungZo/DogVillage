

import UIKit
import FSCalendar
import RxSwift
import RxCocoa



class CalendarController: UIViewController{
        
    //MARK: - Properties
    fileprivate weak var calendar: FSCalendar!
    var events: [Date] = []
    var dateResult: String?{
        didSet{result = dateResult}
    }
    
    var result:String?
    var currentUser: User?
    private var posts = [Post]()
    

    
    //MARK: - LifeyCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCalendarUI()
        fetchDate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        posts.forEach { time in
            print("DEBUG: \(time.timestamp)")
        }
    }
    
    //MARK: - Helpers
    func configureCalendarUI(){
        view.backgroundColor = .white
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.topAnchor.constraint(equalTo: view.topAnchor,constant: 70).isActive = true
        calendar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        calendar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        calendar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: CGFloat(-300)).isActive = true
         
        
        
        
    }
    
    
    //MARK: - API
    func fetchDate(){
        guard let user = currentUser else {return}
        PostService.fetchPosts(forUser: user.uid) { posts in
            self.posts = posts
            
        }
    }
    
    
    
}

//MARK: - FSCalendarDelegate
extension CalendarController: FSCalendarDelegate{
    
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        calendar.appearance.eventDefaultColor = UIColor.green
        calendar.appearance.eventSelectionColor = UIColor.green
        
        
    }
    
    // 날짜 선택 시 콜백 메소드
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // 날짜를 원하는 형식으로 저장하기 위한 방법입니다.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateResult = dateFormatter.string(from: date)
        
//        print("DEBUG : select \(date)")
        
    
    }
    
    // 날짜 선택 해제 콜백 메소드
    public func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
}

//MARK: - FSCalendarDataSource
extension CalendarController: FSCalendarDataSource{
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if self.events.contains(date) {
            return 1
        } else {
            return 0
        }
    }
}
    
