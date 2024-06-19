import SwiftUI
import HomeKit

struct MainView: View {
    @StateObject private var homeKitManager = HomeKitManager()
    private let lightController = LightController()
    
    private let colorOptions: [String: UIColor] = [
        "Red": UIColor.red,
        "Orange": UIColor.orange,
        "Yellow": UIColor.yellow,
        "Green": UIColor.green,
        "Blue": UIColor.blue,
        "Indigo": UIColor.systemIndigo, // Approximation for indigo
        "Purple": UIColor.purple
    ]
    @State private var selectedColor: String = "Red" // Default selection
    @State private var timerFinished: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                // 홈 선택 섹션
                Section(header: Text("Select Home")) {
                    Picker("Home", selection: $homeKitManager.selectedHome) {
                        ForEach(homeKitManager.homes, id: \.self) { home in
                            Text(home.name).tag(home as HMHome?)
                        }
                    }
                }
                
                // 방 선택 섹션
                if let selectedHome = homeKitManager.selectedHome {
                    Section(header: Text("Select Room")) {
                        Picker("Room", selection: $homeKitManager.selectedRoom) {
                            ForEach(selectedHome.rooms, id: \.self) { room in
                                Text(room.name).tag(room as HMRoom?)
                            }
                        }
                    }
                }
                
                // 액세서리 선택 섹션
                if let selectedRoom = homeKitManager.selectedRoom {
                    Section(header: Text("Select Accessory")) {
                        Picker("Accessory", selection: $homeKitManager.selectedAccessory) {
                            ForEach(selectedRoom.accessories, id: \.self) { accessory in
                                Text(accessory.name).tag(accessory as HMAccessory?)
                            }
                        }
                    }
                }
                
                // 액세서리 선택 후 제어 버튼과 색상 선택
                TempView()
                
                // 타이머 뷰
                TimerView(timerFinished: $timerFinished)
                    .padding()
                
            }.navigationBarTitle("HomeKit Controller", displayMode: .inline)
        }
        .onChange(of: timerFinished) { oldValue, newValue in
            if newValue {
                if let selectedAccessory = homeKitManager.selectedAccessory {
                    lightController.startBlinkingBulb(for: selectedAccessory)
                }
            } else {
                lightController.stopBlinkingBulb()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}


extension MainView {
    @ViewBuilder
    func TempView() -> some View {
        if let selectedAccessory = homeKitManager.selectedAccessory {
            VStack(spacing: 20) {
                Button("Turn On Light") {
                    lightController.toggleLight(on: true, for: selectedAccessory)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Turn Off Light") {
                    lightController.toggleLight(on: false, for: selectedAccessory)
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                HStack {
                    Button("Dim Light by 5%") {
                        lightController.changeBrightness(by: -5, for: selectedAccessory) { newBrightness in
                            homeKitManager.brightness = newBrightness
                        }
                    }
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Brighten Light by 5%") {
                        lightController.changeBrightness(by: 5, for: selectedAccessory) { newBrightness in
                            homeKitManager.brightness = newBrightness
                        }
                    }
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                
                Text("Current Brightness: \(homeKitManager.brightness)%")
                    .padding()
                
                // 색상 선택 섹션
                Section(header: Text("Select Color")) {
                    Picker("Color", selection: $selectedColor) {
                        ForEach(colorOptions.keys.sorted(), id: \.self) { colorName in
                            Text(colorName).tag(colorName)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 색상 변경 버튼
                Button("Change Light Color") {
                    if let selectedColor = colorOptions[selectedColor] {
                        lightController.changeLightColor(to: selectedColor, for: selectedAccessory)
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            HStack{
                Button("깜빡이기"){
                    lightController.startBlinkingBulb(for: selectedAccessory)
                }
                .padding()
                
                Button("멈추기") {
                    lightController.stopBlinkingBulb()
                }
                .padding()
            }
        }
    }
}
