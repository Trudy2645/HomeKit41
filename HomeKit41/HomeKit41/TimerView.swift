import SwiftUI
import Combine

struct TimerView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @Binding var timerFinished: Bool
    
    var body: some View {
        VStack {
            Text(timerViewModel.timeString)
                .font(.largeTitle)
                .padding()
            
            //            RadialProgressView(progress: timerViewModel.progress)
            //                .frame(width: 100, height: 100)
            //시계
            HStack {
                Picker("Hours", selection: $timerViewModel.selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) h").tag(hour)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(width: 80)
                
                Picker("Minutes", selection: $timerViewModel.selectedMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute) m").tag(minute)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(width: 80)
                
                Picker("Seconds", selection: $timerViewModel.selectedSeconds) {
                    ForEach(0..<60) { second in
                        Text("\(second) s").tag(second)
                    }
                }
                .pickerStyle(InlinePickerStyle())
                .frame(width: 80)
            }
            .padding()
            
            HStack {
                Button(action: timerViewModel.toggleTimer) {
                    Text(timerViewModel.isRunning ? "Stop" : "Start")
                }
                .padding()
                
                Button(action: timerViewModel.reset) {
                    Text("Reset")
                }
                .padding()
            }
            
            Button(action: timerViewModel.saveTime) {
                Text("Save Time")
            }
            .padding()
            
            List(timerViewModel.savedTimes, id: \.self) { savedTime in
                Text(savedTime)
            }
        }
        .onChange(of: timerViewModel.timerFinished, initial: false) { oldValue, newValue in
            timerFinished = newValue
        }
        
    }
}

struct RadialProgressView: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
        }
    }
}

class TimerViewModel: ObservableObject {
    @Published var timeString: String = "00:00:00"
    @Published var progress: Double = 1.0
    @Published var selectedHours: Int = 0
    @Published var selectedMinutes: Int = 0
    @Published var selectedSeconds: Int = 0
    @Published var savedTimes: [String] = []
    @Published var isRunning: Bool = false
    @Published var timerFinished: Bool = false
    
    private var cancellable: AnyCancellable?
    private var totalTime: TimeInterval = 0
    private var remainingTime: TimeInterval = 0
    
    func toggleTimer() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    func start() {
        stop()
        totalTime = TimeInterval(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
        remainingTime = totalTime
        
        isRunning = true
        timerFinished = false
        
        cancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                self.updateTime()
            }
    }
    
    func stop() {
        cancellable?.cancel()
        cancellable = nil
        isRunning = false
    }
    
    func reset() {
        stop()
        remainingTime = totalTime
        progress = 1.0
        timeString = formatTime(time: remainingTime)
        timerFinished = false
    }
    
    func saveTime() {
        let savedTime = String(format: "%02d:%02d:%02d", selectedHours, selectedMinutes, selectedSeconds)
        savedTimes.append(savedTime)
    }
    
    private func updateTime() {
        if remainingTime > 0 {
            remainingTime -= 1
        }
        timeString = formatTime(time: remainingTime)
        progress = totalTime > 0 ? remainingTime / totalTime : 1.0
        if remainingTime == 0 {
            stop()
            timerFinished = true
        }
    }
    private func formatTime(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
