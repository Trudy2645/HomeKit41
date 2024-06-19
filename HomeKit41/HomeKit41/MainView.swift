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
        "Indigo": UIColor.systemIndigo,
        "Purple": UIColor.purple
    ]
    @State private var selectedColor: String = "Red"
    @State private var timerFinished: Bool = false
    @State private var selectedRoom: HMRoom?
    @State private var selectedAccessory: HMAccessory?

    var body: some View {
        NavigationView {
            List {
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
                    Section(header: Text("방으로 가기")) {
                        ForEach(selectedHome.rooms, id: \.self) { room in
                            NavigationLink(destination: RoomView(room: room, homeKitManager: homeKitManager, lightController: lightController, colorOptions: colorOptions)) {
                                Text(room.name)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("HomeKit Controller", displayMode: .inline)
        }
    }
}
