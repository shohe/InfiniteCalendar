//
//  DetailView.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/21.
//

import SwiftUI

struct DetailView: View {
    @State var item: EventCellView.VM
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top, spacing: 24.0) {
                RoundedRectangle(cornerRadius: 4.0)
                    .frame(width: 16.0, height: 16.0)
                    .foregroundColor(item.color)
                    .padding(.top, 5.0)
                
                VStack(alignment: .leading, spacing: 8.0) {
                    Text(item.text).font(.system(size: 24))
                    Text(schedule(dates: item.startDate...(item.endDate ?? Date()), isAllDay: item.isAllDay)).font(.system(size: 14))
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24.0)
            .padding(.top, 60.0)
            
            Spacer()
        }
    }
    
    private func schedule(dates: ClosedRange<Date>, isAllDay: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "H:mm"
        
        if dates.lowerBound.day == dates.upperBound.day {
            if isAllDay {
                return "\(dateFormatter.string(from: dates.lowerBound))"
            } else {
                return "\(dateFormatter.string(from: dates.lowerBound))・\(timeFormatter.string(from: dates.lowerBound))-\(timeFormatter.string(from: dates.upperBound))"
            }
        } else {
            if isAllDay {
                return "\(dateFormatter.string(from: dates.lowerBound))-\n\(dateFormatter.string(from: dates.upperBound))"
            } else {
                return "\(dateFormatter.string(from: dates.lowerBound)) at \(timeFormatter.string(from: dates.lowerBound))-\n\(dateFormatter.string(from: dates.upperBound)) at \(timeFormatter.string(from: dates.upperBound))"
            }
        }
    }
}
