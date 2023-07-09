//
//  ContentView.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI
import CoreData
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}


struct ContentView: View {
    
    @EnvironmentObject var hmpgModel: HomePageModel
    @State var text_id: String = ""
    @State var text_password: String = ""
    @State var status: String = ""
    @State var userData: String = ""
    @State var userObject: [String: Any] = [:]
    @State var mondayComing: Bool = false
    @State var tuesdayComing: Bool = false
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.015, longitude: 28.979), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    
    
    @State var employeeObj: EmployeeObj?
    @State var driverObj: DriverObj?
    
    let MapLocations = [
        MapLocation(name: "St Francis Memorial Hospital", latitude: 41.03290226402944, longitude: 28.967581809821),
        MapLocation(name: "The Ritz-Carlton, San Francisco", latitude: 41.09290226402944, longitude: 28.907581809821),
        MapLocation(name: "Honey Honey Cafe & Crepery", latitude: 41.13290226402944, longitude: 28.667581809821)
    ]
    
    
    
    var body: some View {
        if hmpgModel.is_home == true && hmpgModel.send_panel == false{
            RoleSelectionView()
        }
        else if hmpgModel.is_home == false && hmpgModel.send_panel == false{
            ClientView()
        }
        else if hmpgModel.is_home == false && hmpgModel.send_panel == true{
            if hmpgModel.role == 1 {
                UserPanelView()
            }
            else if hmpgModel.role == 2 {
                DriverPanelView()
            }
            else if hmpgModel.role == 3 {
                AdminPanelView()
            }
        }
    }
    
    func AdminPanelView() -> some View{
        VStack{
            HStack {
                LogOutButtonView()
                Spacer()
                Text("Welcome Admin")
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: AppTheme.bodyTextSize))
                    .padding(UIScreen.screenWidth * 0.01)
                    .padding(.trailing)
            }
            Map(
                coordinateRegion: $mapRegion,
                interactionModes: MapInteractionModes.all,
                showsUserLocation: true,
                annotationItems: MapLocations,
                annotationContent: { location in
                    MapMarker(coordinate: location.coordinate, tint: AppTheme.backgroundColor)
                }
            )
        }
    }
    
    func DriverPanelView() -> some View{
        VStack{
            HStack{
                LogOutButtonView()
                Text("Welcome Driver")
            }
                .foregroundColor(AppTheme.textColor)
                .font(.system(size: AppTheme.bodyTextSize))
                .padding(UIScreen.screenWidth * 0.01)
            
            if hmpgModel.data_ready == true {
                VStack{
                    HStack{
                        Text("Name : ")
                        Text(driverObj?.fullName.S ?? "")
                    }
                    HStack{
                        Text("Plate : ")
                        Text(driverObj?.plate.S ?? "")
                    }
                }
            }
            Spacer()
            Text(userData)
                .padding()
        }.onAppear{
            updateUserData()
        }
    }
    
    func updateUserData(){
        Task {
            guard let url = URL(string: "https://h91gqyffrl.execute-api.eu-central-1.amazonaws.com/sadjourney/sadjourney?id=\(hmpgModel.user_id)&isDriver=\(hmpgModel.role - 1)") else {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            if let data = data {
                                do {
                                    if hmpgModel.role == 1{
                                        let myObject = try JSONDecoder().decode(EmployeeObj.self, from: data)
                                        // Use myObject here
                                        employeeObj = myObject
                                        hmpgModel.data_ready = true
                                        print(myObject)
                                    }
                                    else{
                                        let myObject = try JSONDecoder().decode(DriverObj.self, from: data)
                                        // Use myObject here
                                        driverObj = myObject
                                        hmpgModel.data_ready = true
                                        print(myObject)
                                    }
                                } catch {
                                    print("Error decoding JSON: \(error)")
                                }
                                userData = String(data: data, encoding: .utf8) ?? ""
                                print(userData)
                            }
                        }
                    } else if httpResponse.statusCode == 400 {
                        if let data = data {
                            userData = String(data: data, encoding: .utf8) ?? "Error"
                        }
                    } else {
                        userData = "Undefined Error"
                    }
                }
            }
            task.resume()
        }
    }
    
    func UserPanelView() -> some View{
        VStack{
            HStack{
                LogOutButtonView()
                Spacer()
                Text("Welcome")
                if employeeObj != nil{
                    Text(employeeObj?.fullName.S ?? "Employee")
                        .padding(.trailing)
                }
            }
            .foregroundColor(AppTheme.textColor)
            .font(.system(size: AppTheme.bodyTextSize))
            .padding(UIScreen.screenWidth * 0.01)
            Spacer()
            if hmpgModel.data_ready == true {
                VStack{
                    VStack{
                        Text("Licence Plate")
                            .foregroundColor(AppTheme.textColor)
                            .font(.system(size: AppTheme.bodyTextSize))
                            .bold()
                            .padding(.bottom)
                        Text(employeeObj?.driverPlate ?? "")
                            .foregroundColor(AppTheme.textColor)
                            .font(.system(size: AppTheme.bodyTextSize*0.9))
                    }
                    VStack{
                        Text("Contact to Driver")
                            .foregroundColor(AppTheme.textColor)
                            .font(.system(size: AppTheme.bodyTextSize))
                            .bold()
                            .padding(.vertical)
                        Text(employeeObj?.driverPhone ?? "")
                            .foregroundColor(AppTheme.textColor)
                            .font(.system(size: AppTheme.bodyTextSize*0.9))
                    }
                    Spacer()
                    Text("Weekly Attendance")
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: AppTheme.bodyTextSize))
                        .padding()
                    if employeeObj != nil{
                        VStack{
                            ToggleAttendanceView(daystr: "mon", indx: 0)
                            ToggleAttendanceView(daystr: "tue", indx: 1)
                            ToggleAttendanceView(daystr: "wed", indx: 2)
                            ToggleAttendanceView(daystr: "thu", indx: 3)
                            ToggleAttendanceView(daystr: "fri", indx: 4)
                            ToggleAttendanceView(daystr: "sat", indx: 5)
                            ToggleAttendanceView(daystr: "sun", indx: 6)
                        }
                    }
                    Text("! Changes for next day is forbidden")
                        .padding(.top)
                }.padding(.bottom , UIScreen.screenWidth * 0.1)
            }
        }.onAppear{
            updateUserData()
        }
    }
    
    func ToggleAttendanceView(daystr: String, indx: Int) -> some View{
        VStack{
            Button {
                Task {
                    guard let url = URL(string: "https://zbldso9cgi.execute-api.eu-central-1.amazonaws.com/sadjourney/sadjourney?id=\(hmpgModel.user_id)&day=\(indx)") else {
                        return
                    }
                    
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                DispatchQueue.main.async {
                                    if let data = data {
                                        status = String(data: data, encoding: .utf8) ?? ""
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                            withAnimation{
                                                updateUserData()
                                            }
                                        }
                                    }
                                }
                            } else if httpResponse.statusCode == 400 {
                                if let data = data {
                                    status = String(data: data, encoding: .utf8) ?? "Error"
                                }
                            } else {
                                status = "Undefined Error"
                            }
                        }
                        
                    }
                    
                    task.resume()
                    
                }
            } label: {
                VStack{
                    Text(daystr)
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: AppTheme.bodyTextSize))
                        .padding(UIScreen.screenWidth * 0.01)
                }
                .frame(width: UIScreen.screenWidth*0.3, height: UIScreen.screenHeight*0.04)
                .background(employeeObj?.attendance[indx]==0 ? .gray : AppTheme.backgroundColor)
                .cornerRadius(16)
            }
        }
    }
    
    func LoginButton() -> some View{
        VStack{
            Text(status)
                .padding()
            Button {
                Task {
                    guard let url = URL(string: "https://lqtv67puee.execute-api.eu-central-1.amazonaws.com/sadjourney/sadjourney?id=\(text_id)&password=\(text_password)&isDriver=\(hmpgModel.role - 1)") else {
                        return
                    }
                    
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                DispatchQueue.main.async {
                                    if let data = data {
                                        status = String(data: data, encoding: .utf8) ?? ""
                                        hmpgModel.user_id = text_id
                                        setID(user_id: text_id)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation{
                                                hmpgModel.send_panel.toggle()
                                            }
                                        }
                                    }
                                }
                            } else if httpResponse.statusCode == 400 {
                                if let data = data {
                                    status = String(data: data, encoding: .utf8) ?? "Error"
                                }
                            } else {
                                status = "Undefined Error"
                            }
                        }
                        
                    }
                    
                    task.resume()
                    
                }
            } label: {
                VStack{
                    Text("Login")
                        .foregroundColor(.white)
                        .font(.system(size: AppTheme.bodyTextSize))
                        .padding(UIScreen.screenWidth * 0.01)
                }
                .frame(width: UIScreen.screenWidth*0.5, height: UIScreen.screenHeight*0.044)
                .background(AppTheme.backgroundColor)
                .cornerRadius(16)
            }
        }
    }
    
    func fieldsforLoginView(headtext: String) -> some View {
        VStack{
            Text(headtext)
            TextField("id", text: $text_id).padding()
            TextField("password", text: $text_password).padding()
        }
    }
    
    func DriverView() -> some View {
        VStack{
            fieldsforLoginView(headtext: "Driver Login")
            LoginButton()
        }
    }
    
    func EmployeeView() -> some View {
        VStack{
            fieldsforLoginView(headtext: "Employee Login")
            LoginButton()
        }
    }
    
    func AdminView() -> some View {
        VStack{
            fieldsforLoginView(headtext: "Admin Login")
            LoginButton()
        }
    }
    
    func ClientView() -> some View{
        VStack{
            HStack{
                BackToHomeButtonView()
                Spacer()
            }
            Spacer()
            if hmpgModel.role == 2{
                DriverView()
            }
            else if hmpgModel.role == 1{
                EmployeeView()
            }
            else if hmpgModel.role == 3{
                AdminView()
            }
            Spacer()
        }
    }
    
    func BackToHomeButtonView() -> some View{
        Button(action: {
            withAnimation{
                hmpgModel.is_home.toggle()
                text_id = ""
                text_password = ""
                status = ""
                hmpgModel.data_ready = false
            }
        }){
            VStack{
                Image(systemName: "chevron.backward.circle.fill")
                    .font(.system(size: AppTheme.headerTextSize*1.4))
                    .padding(UIScreen.screenWidth * 0.01)
                    .foregroundColor(AppTheme.backgroundColor)
            }.padding(.horizontal)
        }
    }
    
    func LogOutButtonView() -> some View{
        Button(action: {
            withAnimation{
                hmpgModel.is_home.toggle()
                hmpgModel.send_panel.toggle()
                text_id = ""
                text_password = ""
                status = ""
                hmpgModel.data_ready = false
                
            }
        }){
            VStack{
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: AppTheme.headerTextSize*1.1))
                        .padding(UIScreen.screenWidth * 0.01)
                        .foregroundColor(.red)
            }.padding(.horizontal)
        }
    }
    
    func roleStack(headert: String) -> some View{
        VStack{
            Text(headert)
                .foregroundColor(.white)
                .font(.system(size: AppTheme.bodyTextSize))
                .bold()
        }
        .frame(width: UIScreen.screenWidth * 0.6, height: UIScreen.screenHeight * 0.1)
        .background(AppTheme.backgroundColor)
        .cornerRadius(30)
    }
    
    func RoleSelectionView() -> some View {
        VStack{
            roleStack(headert: "Employee")
                .onTapGesture {
                    updateRole(role: 1)
                    hmpgModel.role = 1
                    withAnimation{
                        hmpgModel.is_home.toggle()
                    }
                }
            
            roleStack(headert: "Driver")
                .onTapGesture {
                    updateRole(role: 2)
                    hmpgModel.role = 2
                    withAnimation{
                        hmpgModel.is_home.toggle()
                    }
                }
            roleStack(headert: "Admin")
                .onTapGesture {
                    updateRole(role: 3)
                    hmpgModel.role = 3
                    withAnimation{
                        hmpgModel.is_home.toggle()
                    }
                }
        }
        
        
        // ----- Map Functions
        
        
        
    }
}

struct Plate: Codable {
    let S: String
}

struct Available: Codable {
    let BOOL: Bool
}

struct DriverObj: Codable {
    let plate: Plate
    let fullName: FullName
    let id: ID
    let phone: Phone
    let is_available: Available
    
    enum CodingKeys: String, CodingKey {
        case plate = "plate"
        case fullName = "fullName"
        case id = "id"
        case phone = "phone"
        case is_available = "isAvailable"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        plate = try container.decode(Plate.self, forKey: .plate)
        fullName = try container.decode(FullName.self, forKey: .fullName)
        id = try container.decode(ID.self, forKey: .id)
        phone = try container.decode(Phone.self, forKey: .phone)
        is_available = try container.decode(Available.self, forKey: .is_available)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plate, forKey: .plate)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(id, forKey: .id)
        try container.encode(phone, forKey: .phone)
        try container.encode(is_available, forKey: .is_available)
        
    }
}



struct Lattitude: Codable {
    let N: String
}

struct FullName: Codable {
    let S: String
}

struct Longitude: Codable {
    let N: String
}

struct ID: Codable {
    let S: String
}

struct Phone: Codable {
    let S: String
}


struct EmployeeObj: Codable {
    let lattitude: Lattitude
    let fullName: FullName
    let longitude: Longitude
    let id: ID
    let phone: Phone
    let driverPhone: String
    let driverPlate: String
    let attendance: [Int] // Changed the type to an array of Integers
    
    enum CodingKeys: String, CodingKey {
        case lattitude = "lattitude"
        case fullName = "fullName"
        case longitude = "longitude"
        case id = "id"
        case phone = "phone"
        case driverPhone = "driverPhone"
        case driverPlate = "plate"
        case attendance = "attendance"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lattitude = try container.decode(Lattitude.self, forKey: .lattitude)
        fullName = try container.decode(FullName.self, forKey: .fullName)
        longitude = try container.decode(Longitude.self, forKey: .longitude)
        id = try container.decode(ID.self, forKey: .id)
        phone = try container.decode(Phone.self, forKey: .phone)
        driverPhone = try container.decode(String.self, forKey: .driverPhone)
        driverPlate = try container.decode(String.self, forKey: .driverPlate)
        let attendanceString = try container.decode(String.self, forKey: .attendance)
        attendance = attendanceString.components(separatedBy: ",").compactMap { Int($0) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lattitude, forKey: .lattitude)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(id, forKey: .id)
        try container.encode(phone, forKey: .phone)
        try container.encode(driverPhone, forKey: .driverPhone)
        try container.encode(driverPlate, forKey: .driverPlate)
        let attendanceString = attendance.map { String($0) }.joined(separator: ",")
        try container.encode(attendanceString, forKey: .attendance)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
