//
//  ContentView.swift
//  CustomCalender
//
//  Created by Net Web Technologies on 01/02/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentDate:Date = Date()
    
    
    var body: some View {
        VStack{
            ScrollView(.vertical,showsIndicators: false){
                VStack{
                    DatePicker(currentDate: $currentDate)
                }
                .padding()
                .frame(maxWidth:.infinity,maxHeight: UIScreen.main.bounds.height * 0.6)
                .background(.white)
                .cornerRadius(15)
                .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 5)
                .padding([.leading,.trailing])
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



struct DatePicker: View {
    @Binding var currentDate: Date
    @State var currentMonth: Int = 0
    
    var body: some View {
        VStack(spacing: 20){
            let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
            
            HStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(extraDate()[1])
                        .font(.title.bold())
                }
                Spacer(minLength: 0)
                
                Button {
                    withAnimation{
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Button {
                    
                    withAnimation{
                        currentMonth += 1
                    }
                    
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            HStack(spacing: 0){
                ForEach(days,id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns,spacing: 15) {
                ForEach(extractDate()) { value in
                    
                    CardView(value: value)
                        .background(
                            Capsule()
                                .fill(.blue)
                                .padding(.horizontal,8)
                                .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                    }
                }
            }
            
            //add another view
        }
        .onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
        }
    }
    
    //MARK: - View that holds date data
    @ViewBuilder
    func CardView(value: DateValue)->some View{
        
        VStack{
            //MARK: - to check if the data has a negative value
            if value.day != -1{
                
                if let task = tasks.first(where: { task in
                    //MARK: - if the date in current value that is getting from for loop with the data date
                    return isSameDay(date1: task.remindDate, date2: value.date)
                    
                }){
                    //MARK: - Make a view and modify it according to use like 1 ,2 ,3 with color or marks
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: task.remindDate, date2: currentDate) ? .white : .green)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()

                }else{
                    //MARK: - View for the dates that are not present in task array
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
        }
        .padding(.vertical,9)
        .frame(alignment: .top)
        
    }
    
    //MARK: - check if two dates are same
    func isSameDay(date1: Date,date2: Date)->Bool{
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    //MARK: - get year and month acc to current date
    func extraDate()->[String]{
        let calendar = Calendar.current
        let month = calendar.component(.month, from: currentDate) - 1
        let year = calendar.component(.year, from: currentDate)
        
        return ["\(year)",calendar.monthSymbols[month]]
    }
    
    //MARK: - get current month in (Date)
    func getCurrentMonth()->Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
        return currentMonth
    }
    
    //MARK: - get dates for the current month
    func extractDate()->[DateValue] {
        let calendar = Calendar.current
        let currentMonth = getCurrentMonth()
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        let firstWeekday = calendar.component(.weekday, from: days.first!.date)
        
        for _ in 0..<firstWeekday - 1{
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

extension Date {
    
    //MARK: - get date array of dates
    func getAllDates()->[Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        return range.compactMap { day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
}


struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

struct Reminder: Identifiable{
    var id = UUID().uuidString
    var booking_id: Int
    var time: Date = Date()
}

struct ReminderData: Identifiable{
    var id = UUID().uuidString
    var remind: [Reminder]
    var remindDate: Date
}

func getSampleDate(offset: Int)->Date{
    let calender = Calendar.current
    
    let date = calender.date(byAdding: .day, value: offset, to: Date())
    
    return date ?? Date()
}

// Sample Reminders...
var tasks: [ReminderData] = [

    ReminderData(remind: [
    
        Reminder(booking_id:123),
        Reminder(booking_id:123),
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: -15)),
   
    ReminderData(remind: [
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 4)),
    
    ReminderData(remind: [
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 6)),
    
    ReminderData(remind: [
        Reminder(booking_id:123),
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 10)),
    
    ReminderData(remind: [
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 26)),
    
    ReminderData(remind: [
        Reminder(booking_id:123),
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 22)),
    
    ReminderData(remind: [
        Reminder(booking_id:123)
    ], remindDate: getSampleDate(offset: 8)),
]
