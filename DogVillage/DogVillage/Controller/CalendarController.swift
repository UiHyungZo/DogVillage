

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
        
        
        calendar.appearance.headerDateFormat = "YYYY??? M???"
        calendar.calendarWeekdayView.weekdayLabels[0].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "???"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "???"
        
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        calendar.appearance.eventDefaultColor = UIColor.green
        calendar.appearance.eventSelectionColor = UIColor.green
        
        
    }
    
    // ?????? ?????? ??? ?????? ?????????
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        // ????????? ????????? ???????????? ???????????? ?????? ???????????????.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy??? MM??? dd???"
        dateResult = dateFormatter.string(from: date)
        
//        print("DEBUG : select \(date)")
        
    
    }
    
    // ?????? ?????? ?????? ?????? ?????????
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
    
