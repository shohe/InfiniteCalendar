# InfiniteCalendar

**Google Calendar-like infinite scrollable calendar for SwiftUI.**

[![Twitter](https://img.shields.io/badge/Twitter-%40ShoheOhtani-blue)](https://twitter.com/ShoheOhtani)
![Swift Version](https://img.shields.io/badge/Swift-5.1-orange.svg)
[![SPM compatible](https://img.shields.io/badge/SwiftPM-compatible-yellowgreen.svg?style=flat)](https://swift.org/package-manager)
[![License](https://img.shields.io/badge/license-MIT-green)](./LICENSE)

InfiniteCalendar is infinite scrollable calendar for iOS written in Swift.  

<img align="right" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/animation-mock-iPhone-12Pro.gif"/>

<p>UI/UX design inspired by <a href="https://apps.apple.com/jp/app/google-calendar-get-organized/id909319292?l=en">GoogleCalendar</a>. Implementation inspired by <a href="https://github.com/zjfjack/JZCalendarWeekView">JZCalendarWeekView</a>.</p>
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
   - [Sample custom component (DateHeader)](#sample-custom-component-dateheader)


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

#### datePosition
The display position of Date **only for One-day layout**.

Sample: `datePosition = .top`, `datePosition = .left`
<img align="center" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/date-position.png"/>


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

**Associatedtypes** 

Component class is define as typealias to customize.
<img align="center" width="100%" height="auto" src="https://github.com/shohe/InfiniteCalendar/raw/media/Assets/marking-components.png"/>

```swift
//* When you customize, set two of classes to custom class you created.
// TimeHeader 
associatedtype TimeHeaderView: ICTimeHeaderView
associatedtype TimeHeader: ICTimeHeader<TimeHeaderView>

// DateHeader
associatedtype DateHeaderView: ICDateHeaderView
associatedtype DateHeader: ICDateHeader<DateHeaderView>

// DateHeaderCorner
associatedtype DateCornerView: ICDateCornerView
associatedtype DateCorner: ICDateCorner<DateCornerView>

// AllDayHeader
associatedtype AllDayHeaderView: ICAllDayHeaderView
associatedtype AllDayHeader: ICAllDayHeader<AllDayHeaderView>

// AllDayHeaderCorner
associatedtype AllDayCornerView: ICAllDayCornerView
associatedtype AllDayCorner: ICAllDayCorner<AllDayCornerView>

// Timeline
associatedtype TimelineView: ICTimelineView
associatedtype Timeline: ICTimeline<TimelineView>

// TimeHeaderBackground
associatedtype TimeHeaderBackgroundView: ICTimeHeaderBackgroundView
associatedtype TimeHeaderBackground: ICTimeHeaderBackground<TimeHeaderBackgroundView>

// DateHeaderBackground
associatedtype DateHeaderBackgroundView: ICDateHeaderBackgroundView
associatedtype DateHeaderBackground: ICDateHeaderBackground<DateHeaderBackgroundView>

// AllDayHeaderBackground
associatedtype AllDayHeaderBackgroundView: ICAllDayHeaderBackgroundView
associatedtype AllDayHeaderBackground: ICAllDayHeaderBackground<AllDayHeaderBackgroundView>
```


#### Sample custom component (DateHeader)

All you need is 4 steps.
1. Create CustomView and Cell for wrap the View
2. Create CustomSetting class
3. Set the typealiases of each classes to View and Cell you created
4. Set the CustomSetting class to InfiniteCalendar

</br>
e.g. Customize DateHeader component.

##### 1. Create CustomView and Cell for wrap the View
```swift
// DateHeader should be inherited `ICDateHeader`.
class CustomDateHeader: ICDateHeader<CustomDateHeaderView> {}

// CustomView should be inherited `ICDateHeaderView`.
struct CustomDateHeaderView: ICDateHeaderView {
    public typealias Item = ICDateHeaderItem

    var item: Item
    
    public init(_ item: Item) {
        self.item = item
    }
    
    public var body: some View {
        ...
    }
}
```

##### 2. Create CustomSetting class
Create SubClass inherited `ICSettings`.
```swift
class CustomSettings: ICSettings {
    @Published public var numOfDays: Int = 1
    @Published public var initDate: Date = Date()
    @Published public var scrollType: ScrollType = .pageScroll
    @Published public var moveTimeMinInterval: Int = 15
    @Published public var timeRange: (startTime: Int, endTime: Int) = (1, 23)
    @Published public var withVibrateFeedback: Bool = true
    
    required public init() {}
    
    ...
}
```

##### 3. Set the typealiases of each classes to View and Cell you created
```swift
class CustomSettings: ICSettings {
    typealias DateHeaderView = CustomDateHeaderView
    typealias DateHeader = CustomDateHeader
    ...
}
```

##### 4. Set the CustomSetting class to InfiniteCalendar
```swift
...

@State var events: [EventCellView.VM] = SampleData().events
@State var didTapToday: Bool = false
@ObservedObject var settings: CustomSettings = CustomSettings()

var body: some View {
    InfiniteCalendar<EventCellView, EventCell, CustomSettings>(events: $events, settings: settings, didTapToday: $didTapToday)
}

...
```
----

## License
InfiniteCalendar is available under the MIT license. See the LICENSE file for more info.