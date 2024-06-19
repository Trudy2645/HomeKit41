import SwiftUI
import HomeKit

struct RoomView: View {
    let room: HMRoom
    @ObservedObject var homeKitManager: HomeKitManager
    let lightController: LightController
    let colorOptions: [String: UIColor]
    @State private var selectedColor: String = "Red"
    @State private var timerFinished: Bool = false
    
    // 그리드 항목의 크기를 정의합니다.
    private let gridItemLayout = [GridItem(.fixed(112), spacing: 16),
                                  GridItem(.fixed(112), spacing: 16),
                                  GridItem(.fixed(112), spacing: 16)]
    
    var body: some View {
            Form {
                // 액세서리 선택 섹션
                Section(header: Text("")) {
                    Picker("액세서리", selection: $homeKitManager.selectedAccessory) {
                        ForEach(room.accessories, id: \.self) { accessory in
                            Text(accessory.name).tag(accessory as HMAccessory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
                
                Section{
                    HStack{
                        Text("타이머")
                        Button {
                            print("dd")
                        } label: {
                            Text("dd")
                        }

                    }
                }
                Section {
                          Text("Texty")
                          Text("Texty")
                          Text("Texty")
                        }
                
            }
        // 그리드 섹션
        LazyVGrid(columns: gridItemLayout, spacing: 16) {
            // 액세서리 선택 섹션
            Section(header: Text("Select Accessory").font(.headline)) {
                ForEach(room.accessories, id: \.self) { accessory in
                    NavigationLink(destination: AccessoryControlView(
                        accessory: accessory,
                        homeKitManager: homeKitManager,
                        lightController: lightController,
                        colorOptions: colorOptions, timerFinished: $timerFinished)) {
                            VStack {
                                Text(accessory.name)
                                    .frame(width: 112, height: 112)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .padding(4)
                            }
                        }
                }
            }
        }
        .padding(.horizontal)
        .navigationBarTitle("\(room.name) Accessories", displayMode: .inline)
    }
}
