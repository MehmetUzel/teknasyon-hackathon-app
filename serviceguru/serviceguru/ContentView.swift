//
//  ContentView.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI
import CoreData


struct ContentView: View {
    
    @EnvironmentObject var hmpgModel: HomePageModel
    @State var text_id: String = ""
    @State var text_password: String = ""
    @State private var responseData: Data?
    @State var status: String = ""
    @State var userData: String = ""
    @State var userObject: [String: Any] = [:]
    @State var mondayComing: Bool = false
    @State var tuesdayComing: Bool = false
    
    
    @State var userapiobject: UserAPIResponse?
    
    
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
        }
    }
    
    func DriverPanelView() -> some View{
        VStack{
            LogOutButtonView()
            Text("Welcome Driver")
                .foregroundColor(AppTheme.textColor)
                .font(.system(size: AppTheme.bodyTextSize))
                .padding(UIScreen.screenWidth * 0.01)
            Text(userData)
                .padding()
            
        }.onAppear{
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
                                    self.responseData = data
                                    userData = String(data: data, encoding: .utf8) ?? ""
                                    //print(userData)
                                    if let jsonObject = convertStringToObject(userData) {
                                        // Use the converted object
                                        print(jsonObject)
                                        hmpgModel.data_ready = true
                                    } else {
                                        print("Failed to convert string to object.")
                                    }
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
    }
    
    func UserPanelView() -> some View{
        VStack{
            LogOutButtonView()
            Text("Welcome Employee")
                .foregroundColor(AppTheme.textColor)
                .font(.system(size: AppTheme.bodyTextSize))
                .padding(UIScreen.screenWidth * 0.01)
            Text(userData)
                .padding()
            if hmpgModel.data_ready == true {
                VStack{
                    Text("Weekly Attendance")
                    if userapiobject != nil{
                        HStack{
                            moToggleAttendanceView(daystr: "mo")
                        }
                    }
                }
            }
        }.onAppear{
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
                                    self.responseData = data
                                    userData = String(data: data, encoding: .utf8) ?? ""
                                    //print(userData)
                                    if let jsonObject = convertStringToObject(userData) {
                                        // Use the converted object
                                        print(jsonObject)
                                        userapiobject = jsonObject
                                        hmpgModel.data_ready = true
                                    } else {
                                        print("Failed to convert string to object.")
                                    }
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
    }
    
    func moToggleAttendanceView(daystr: String) -> some View{
        VStack{
            Button {
                Task {
                    guard let url = URL(string: "https://zbldso9cgi.execute-api.eu-central-1.amazonaws.com/sadjourney/sadjourney?id=\(hmpgModel.user_id)&day=\(getDayOfWeek(from: daystr) ?? 0)&isAttendance=\(userapiobject!.mo)") else {
                        return
                    }
                    
                    let task = URLSession.shared.dataTask(with: url) { data, response, error in
                        
                        if let error = error {
                            print("Error: \(error.localizedDescription)")
                        } else if let httpResponse = response as? HTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                DispatchQueue.main.async {
                                    if let data = data {
                                        self.responseData = data
                                        status = String(data: data, encoding: .utf8) ?? ""
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation{
                                                hmpgModel.send_panel.toggle()
                                                userapiobject!.mo = !userapiobject!.mo
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
                .background(userapiobject!.mo ? .gray : AppTheme.backgroundColor)
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
                                        self.responseData = data
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
                        .foregroundColor(AppTheme.textColor)
                        .font(.system(size: AppTheme.bodyTextSize))
                        .padding(UIScreen.screenWidth * 0.01)
                }
                .frame(width: UIScreen.screenWidth*0.3, height: UIScreen.screenHeight*0.04)
                .background(.gray)
                .cornerRadius(16)
            }
        }
    }
    
    func DriverView() -> some View {
        VStack{
            Text("Driver Login")
            TextField("id", text: $text_id).padding()
            TextField("password", text: $text_password).padding()
            LoginButton()
        }
    }
    
    func EmployeeView() -> some View {
        VStack{
            Text("Employee Login")
            TextField("id", text: $text_id).padding()
            TextField("password", text: $text_password).padding()
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
                Text("Back")
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: AppTheme.bodyTextSize))
                    .padding(UIScreen.screenWidth * 0.01)
            }
            .frame(width: UIScreen.screenWidth*0.3, height: UIScreen.screenHeight*0.04)
            .background(.gray)
            .cornerRadius(16)
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
                Text("Log Out")
                    .foregroundColor(AppTheme.textColor)
                    .font(.system(size: AppTheme.bodyTextSize))
                    .padding(UIScreen.screenWidth * 0.01)
            }
            .frame(width: UIScreen.screenWidth*0.3, height: UIScreen.screenHeight*0.04)
            .background(.red)
            .cornerRadius(16)
        }
    }
    
    func RoleSelectionView() -> some View {
        VStack{
            HStack{
                VStack{
                    Text("Employee")
                }
                .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.22)
                .background(Color.blue)
                .cornerRadius(30)
                .onTapGesture {
                    updateRole(role: 1)
                    hmpgModel.role = 1
                    hmpgModel.is_home.toggle()
                }
                
                VStack{
                    Text("Driver")
                }
                .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.22)
                .background(Color.blue)
                .cornerRadius(30)
                .onTapGesture {
                    updateRole(role: 2)
                    hmpgModel.role = 2
                    hmpgModel.is_home.toggle()
                    
                }
            }
        }
    }
    
    
    // ----- Map Functions
    
    func convertStringToObject(_ jsonString: String) -> UserAPIResponse? {
        if let jsonObject = convertJSONToClass(jsonString: jsonString) {
            return jsonObject
        }
        return nil
    }
    
    
    func getDayOfWeek(from weekday: String) -> Int? {
        let weekdays = ["mo", "tu", "we", "th", "fr", "sa", "su"]
        
        guard let index = weekdays.firstIndex(of: weekday) else {
            return nil
        }
        
        let adjustedIndex = (index + 1) % weekdays.count // Adjust index to start from Monday
        
        return adjustedIndex
    }
    
}

/*
 // Struct representing the API response
 struct UserAPIResponse: Codable {
 let tu: BoolWrapper?
 let mo: BoolWrapper?
 let su: BoolWrapper?
 let lattitude: NumberWrapper?
 let fullName: StringWrapper?
 let fr: BoolWrapper?
 let sa: BoolWrapper?
 let we: BoolWrapper?
 let th: BoolWrapper?
 let longitude: NumberWrapper?
 let id: StringWrapper?
 let phone: StringWrapper?
 }
 
 // Struct representing a wrapper for boolean values
 struct BoolWrapper: Codable {
 let BOOL: Bool?
 }
 
 // Struct representing a wrapper for number values
 struct NumberWrapper: Codable {
 let N: String?
 }
 
 // Struct representing a wrapper for string values
 struct StringWrapper: Codable {
 let S: String?
 }
 */

class UserAPIResponse: ObservableObject {
    @Published var tu = false
    @Published var mo = true
    @Published var su = true
    @Published var lattitude: Double = 0.0
    @Published var fullName = ""
    @Published var fr = true
    @Published var sa = true
    @Published var we = false
    @Published var th = true
    @Published var longitude: Double = 0.0
    @Published var id = ""
    @Published var phone = ""
}

func convertJSONToClass(jsonString: String) -> UserAPIResponse? {
    guard let jsonData = jsonString.data(using: .utf8) else {
        return nil
    }
    
    do {
        let decoder = JSONDecoder()
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        
        guard let jsonDict = jsonObject as? [String: Any] else {
            return nil
        }
        
        let myClass = UserAPIResponse()
        
        // Access each key-value pair in the dictionary and update the corresponding property
        for (key, value) in jsonDict {
            switch key {
            case "tu":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.tu = bool
                }
            case "mo":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.mo = bool
                }
            case "su":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.su = bool
                }
            case "lattitude":
                if let numberValue = value as? [String: String], let stringValue = numberValue["N"], let doubleValue = Double(stringValue) {
                    myClass.lattitude = doubleValue
                }
            case "fullName":
                if let stringValue = value as? [String: String], let fullName = stringValue["S"] {
                    myClass.fullName = fullName
                }
            case "fr":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.fr = bool
                }
            case "sa":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.sa = bool
                }
            case "we":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.we = bool
                }
            case "th":
                if let boolValue = value as? [String: Bool], let bool = boolValue["BOOL"] {
                    myClass.th = bool
                }
            case "longitude":
                if let numberValue = value as? [String: String], let stringValue = numberValue["N"], let doubleValue = Double(stringValue) {
                    myClass.longitude = doubleValue
                }
            case "id":
                if let stringValue = value as? [String: String], let id = stringValue["S"] {
                    myClass.id = id
                }
            case "phone":
                if let stringValue = value as? [String: String], let phone = stringValue["S"] {
                    myClass.phone = phone
                }
            default:
                break
            }
        }
        
        return myClass
    } catch {
        print("Error: \(error)")
        return nil
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
