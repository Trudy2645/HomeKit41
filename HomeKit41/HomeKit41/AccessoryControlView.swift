import HomeKit
import SwiftUI

struct AccessoryControlView: View {
    @ObservedObject var homeKitManager: HomeKitManager
    private let lightController: LightController
    private let colorOptions: [String: UIColor]
    @State private var selectedColor: String = "Red"
    @Binding var timerFinished: Bool
    let accessory: HMAccessory
    
    init(accessory: HMAccessory, homeKitManager: HomeKitManager, lightController: LightController, colorOptions: [String: UIColor], timerFinished: Binding<Bool>) {
        self.accessory = accessory
        self.homeKitManager = homeKitManager // <- 변경된 부분
        self.lightController = lightController
        self.colorOptions = colorOptions
        self._timerFinished = timerFinished
    }
    
    var body: some View {
        ScrollView{
                if let selectedAccessory = homeKitManager.selectedAccessory {
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
                    
                    HStack {
                        Button("Start Blinking") {
                            lightController.startBlinkingBulb(for: selectedAccessory)
                        }
                        .padding()
                        
                        Button("Stop Blinking") {
                            lightController.stopBlinkingBulb()
                        }
                        .padding()
                    }
                }
                // 타이머 뷰
                TimerView(timerFinished: $timerFinished)
                    .padding()
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
            .padding()
    }
}
