# InfiniteCalendar

**GoogleCalendar like infinite scrollable Calendar for SwiftUI.**

[![Twitter](https://img.shields.io/badge/Twitter-%40ShoheOhtani-blue)](https://twitter.com/ShoheOhtani)
![Swift Version](https://img.shields.io/badge/Swift-5.1-orange.svg)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-compatible-yellowgreen.svg?style=flat)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

InfiniteCalendar is infinite scrollable Calendar for iOS written in Swift.  

<img align="right" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/animation-mock-iPhone-12Pro.gif"/>

<p>UI/UX design inspired by <a href="https://apps.apple.com/jp/app/google-calendar-get-organized/id909319292?l=en">GoogleCalendar</a>. Implementation inspired by <a href="https://clutch.co/profile/exyte#review-731233?utm_medium=referral&utm_source=github.com&utm_campaign=phenomenal_to_clutch">JZCalendarWeekView</a>.</p>
</br>

___

### Features

- [x] Infinite scroll
- [x] Multiple scroll type
- [x] Custamazable UI
- [x] Support long tap gesture actions
- [x] Support autoScroll for drag
- [x] Support handling multiple actions
- [x] Support vibrate feedback like GoogleCalendar

## Requirements

- Swift 5.1
- iOS 13.0 or later

## Installation

#### Swift Package Manager

InfiniteCalendar is available through [Swift Package Manager](https://swift.org/package-manager).

Add it to an existing Xcode project as a package dependency:

1. From the **File** menu, select **Add Packages…**
2. Enter "https://github.com/shohe/InfiniteCalendar.git" into the package repository URL text field

## Documentation
 - [1. Initialization](#1-initialization)
 - [2. Handling](#2-handling)
   - [.onCurrentDateChanged](#oncurrentdatechanged)
   - [.onItemSelected](#onitemselected)
   - [.onEventAdded](#oneventadded)
   - [.onEventMoved](#oneventmoved)
   - [.onEventCanceled](#oneventcanceled)
 - [3. Settings](#3-settings)
   - [numOfDays](#numofdays)
   - [initDate](#initdate)
   - [scrollType](#scrolltype)
   - [moveTimeMinInterval](#movetimemininterval)
   - [timeRange](#timerange)
   - [withVibrateFeedback](#withvibratefeedback)
 - [4. Custom UI components](#4-custom-ui-components)
   - [Sample custom component (Timeline)](#sample-custom-component-timeline)


### 1. Initialization

You need to define View, ViewModel and CollectionViewCell for display cell on Calendar:

1. Create View complianted for CellableView protocol:
```swift
struct EventCellView: CellableView {
    typealias VM = ViewModel

    // MARK: ViewModel
    struct ViewModel: ICEventable { ... }


    // MARK: View
    var viewModel: ViewModel
    
    init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ...
    }
}
```

2. Implement ViewModel complianted for ICEventable protocol:
```swift
struct ViewModel: ICEventable { 
    private(set) var id: String = UUID().uuidString
    var text: String

    var startDate: Date
    var endDate: Date?
    var intraStartDate: Date
    var intraEndDate: Date
    var editState: EditState?
    var isAllDay: Bool
    
    
    init(text: String, start: Date, end: Date?, isAllDay: Bool = false, editState: EditState? = nil) {
        ...
    }
    
    // ! Make sure copy current object, otherwise view won't display properly when SwiftUI View is updated.
    func copy() -> EventCellView.ViewModel {
        var copy = ViewModel(text: text, start: startDate, end: endDate, isAllDay: isAllDay, editState: editState)
        ...
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
```

3. Create CollectionViewCell complianted for ViewHostingCell protocol:
```swift
final class EventCell: ViewHostingCell<EventCellView> {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
```

4. Use InfiniteCalendar with CustomViews:
```swift
struct ContentView: View {
    @State var events: [EventCellView.VM] = []
    @State var didTapToday: Bool = false
    @ObservedObject var settings: ICViewSettings = ICViewSettings(
        numOfDays: 3, 
        initDate: Date(), 
        scrollType: .sectionScroll, 
        moveTimeMinInterval: 15, 
        timeRange: (1, 23), 
        withVibration: true
    )

    var body: some View {
        InfiniteCalendar<EventCellView, EventCell, ICViewSettings>(events: $events, settings: settings, didTapToday: $didTapToday)
    }
}
```

----

### 2. Handling
#### .onCurrentDateChanged
This method will be called when changed currrent date displayed on calendar. The date can be get is the leftest date on current display.

ex.) Display 3 column dates, `4/1 | 4/2 | 4/3` -> **`4/1`** can be obtained.

```swift
InfiniteCalendar<EventCellView, EventCell, Settings>(events: $events, settings: settings, didTapToday: $didTapToday)
.onCurrentDateChanged { date in
    currentDate = date
}
```

#### .onItemSelected
This method will be called when item was tapped.
```swift
InfiniteCalendar<EventCellView, EventCell, Settings>(events: $events, settings: settings, didTapToday: $didTapToday)
.onItemSelected { item in
    selectedItem = item
}
```

#### .onEventAdded
This method will be called when item was created by long tap with drag gesture.
```swift
InfiniteCalendar<EventCellView, EventCell, Settings>(events: $events, settings: settings, didTapToday: $didTapToday)
.onEventAdded { item in
    events.append(item)
}
```

#### .onEventMoved
This method will be called when item was created by long tap gesture on exist item.
```swift
InfiniteCalendar<EventCellView, EventCell, Settings>(events: $events, settings: settings, didTapToday: $didTapToday)
.onEventMoved { item in
    if let index = events.firstIndex(where: {$0.id == item.id}) {
        events[index] = item
    }
}
```

#### .onEventCanceled
This method will be called when canceled gesture event by some accident or issues.
```swift
InfiniteCalendar<EventCellView, EventCell, Settings>(events: $events, settings: settings, didTapToday: $didTapToday)
.onEventCanceled { item in
    print("Canceled some event gesture for \(item.id).")
}
```

----

### 3. Settings
If you want to customize Settings, create SubClass of `ICViewSettings`.

#### numOfDays
Number of dispaly dates on a screen

Sample: `numOfDays = 1`, `numOfDays = 3`, `numOfDays = 7`
<img align="center" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/num-of-days.png"/>

#### initDate
The display date for lounch app

#### scrollType
There is two kinds of scroll type, `Section` and `Page`.

SectionType will deside scroll amount by **scroll velocity**. On the other hand PageType is always scroll to next / prev page with scroll gesture.

<img align="center" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/scroll-type-sample.gif"/>

#### moveTimeMinInterval
Interval minutes time for drag gesture.
**Default value is 15**. Which means when item was created/moved time will move every 15 minutes 

#### timeRange
The display time on time header as a label.
**Default value is (1, 23)**. Which means display 1:00 ~ 23:00.

#### withVibrateFeedback
If vibration is needed during dragging gesture.
**Default value is true**. Vibration feedback is almost same as GoogleCalendar.


----

### 4. Custom UI components
You can customize each components on the bellow.

- SupplementaryCell (Use as SupplementaryCell in CollectionView)
  - TimeHeader
  - DateHeader
  - DateHeaderCorner
  - AllDayHeader
  - AllDayHeaderCorner
  - Timeline
- DecorationCell (Use as DecorationCell in CollectionView)
  - TimeHeaderBackground
  - DateHeaderBackground
  - AllDayHeaderBackground

**Default components** 

Component calss is define as typealias to customize.
<img align="center" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/marking-components.png"/>

```swift
public typealias TimeHeader = ICTHeader
public typealias TimeHeaderBackground = ICTHeaderBackground
public typealias DateHeader = ICDHeader
public typealias DateHeaderBackground = ICDHeaderBackground
public typealias DateHeaderCorner = ICDCorner
public typealias AllDayHeader = ICAllDayHeader
public typealias AllDayHeaderBackground = ICAllDayHeaderBackground
public typealias AllDayHeaderCorner = ICAllDayCorner
public typealias Timeline = ICTimeline
```


#### Sample custom component (Timeline)
```swift
// Timeline is SupplementaryCell type. So must SubClass of `ViewHostingSupplementaryCell`
public final class CustomTimeline: ViewHostingSupplementaryCell<CustomTimelineView> {}

public struct CustomTimelineView: ICComponentView {
    // Must use ICTimelineItem
    public typealias Item = ICTimelineItem 

    var item: Item
    
    public init(_ item: Item) {
        self.item = item
    }
    
    public var body: some View {
        Rectangle()
            .frame(height: 1.0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.red)
            .opacity(item.isDisplayed ? 1 : 0)
    }
}
```

Create SubClass of ICViewSettings to set custom component.
```swift
class Settings: ICViewSettings {
    typealias Timeline = CustomTimeline

    init(numOfDays: Int, initDate: Date) {
        super.init()
        self.numOfDays = numOfDays
        self.initDate = initDate
    }

    ...
}
```

----

## License
InfiniteCalendar is available under the MIT license. See the LICENSE file for more info.