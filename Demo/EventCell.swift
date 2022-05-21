//
//  EventCell.swift
//  Demo
//
//  Created by Shohe Ohtani on 2022/05/21.
//

import SwiftUI
import UIKit
import InfiniteCalendar


final class EventCell: ViewHostingCell<EventCellView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

struct EventCellView: CellableView {
    typealias VM = ViewModel
    
    // MARK: ViewModel
    struct ViewModel: ICEventable {
        private(set) var id: String = UUID().uuidString
        
        var text: String
        var startDate: Date
        var endDate: Date?
        var intraStartDate: Date
        var intraEndDate: Date
        var editState: EditState?
        var isAllDay: Bool
        var color: Color?
        
        
        init(text: String, start: Date, end: Date?, isAllDay: Bool = false, editState: EditState? = nil, color: Color? = Color(red: 6.0/255.0, green: 170.0/255.0, blue: 299.0/255.0)) {
            self.text = text
            self.startDate = start
            self.endDate = end
            self.intraStartDate = start
            self.intraEndDate = end ?? start.endOfDay
            self.isAllDay = isAllDay
            self.editState = editState
            self.color = color
        }
        
        func copy() -> EventCellView.ViewModel {
            var copy = ViewModel(text: text, start: startDate, end: endDate, isAllDay: isAllDay, editState: editState, color: color)
            copy.id = id
            copy.intraStartDate = intraStartDate
            copy.intraEndDate = intraEndDate
            return copy
        }
        
        static func create(from eventable: EventCellView.ViewModel?, state: EditState?) -> EventCellView.ViewModel {
            if var model = eventable?.copy() {
                model.editState = state
                return model
            }
            return ViewModel(text: "New", start: Date(), end: nil, editState: state)
        }
    }
    
    
    // MARK: View
    var viewModel: ViewModel
    
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 3.0)
                .foregroundColor(viewModel.editState == .resizing ? Color.white.opacity(0.3) : viewModel.color)
                .overlay(border)
                .overlay(streachGuide)
                .shadow(color: viewModel.editState == .moving ? Color.black.opacity(0.4) : .clear, radius: 1.0, x: 0.0, y: 1.0)
            Text(viewModel.text)
                .font(.system(size: 12))
                .bold()
                .lineSpacing(0)
                .foregroundColor(viewModel.editState == .resizing ? .clear : .white)
                .padding(EdgeInsets(top: 6.0, leading: 4.0, bottom: 0, trailing: 0))
        }
    }
    
    private var border: some View {
        let borderWidth: CGFloat = 2.0
        return RoundedRectangle(cornerRadius: 3.0)
            .stroke(viewModel.editState == .resizing ? viewModel.color ?? .black : .clear,
                    lineWidth: viewModel.editState == .resizing ? borderWidth : 0.0)
            .shadow(color: viewModel.editState == .resizing ? Color.black.opacity(0.4) : .clear, radius: 1.0, x: 0.0, y: 1.0)
            .padding(borderWidth/2)
    }
    
    private var streachGuide: some View {
        let size: CGFloat = 14.0
        return VStack {
            HStack {
                createGuideDot(size: size).offset(x: -size/4, y: -size/2)
                Spacer()
            }
            Spacer(minLength: 0)
            HStack {
                Spacer()
                createGuideDot(size: size).offset(x: size/4, y: size/2)
            }
        }.opacity(viewModel.editState == .resizing ? 1 : 0)
    }
    
    private func createGuideDot(size: CGFloat) -> some View {
        Circle()
            .frame(width: size, height: size)
            .foregroundColor(viewModel.color)
            .overlay(
                RoundedRectangle(cornerRadius: size/2)
                    .stroke(Color(red: 244.0/255.0, green: 243.0/255.0, blue: 251.0/255.0), lineWidth: size/4)
            )
    }
}
