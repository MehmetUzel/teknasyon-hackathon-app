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
    
    
    var body: some View {
        if hmpgModel.is_home == true{
            RoleSelectionView()
        }
        else if hmpgModel.is_home == false{
            ClientView()
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
                                    }
                                }
                            } else if httpResponse.statusCode == 400 {
                                if let data = data {
                                    status = String(data: data, encoding: .utf8) ?? "Error"
                                }
                            } else {
                                status = "Undefined Error"
                            }
                        }                    }
                    
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
