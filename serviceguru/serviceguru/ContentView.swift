//
//  ContentView.swift
//  serviceguru
//
//  Created by Macbook on 8.07.2023.
//

import SwiftUI
import CoreData
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
    
    
    @EnvironmentObject var hmpgModel: HomePageModel
    
    var body: some View {
        if hmpgModel.is_home == true{
            RoleSelectionView()
        }
        else if hmpgModel.is_home == false{
            ClientView()
        }
    }
    
    func DriverView() -> some View {
        Text("Driver Login")
        
    }
    
    func EmployeeView() -> some View {
        Text("Employee Login")
    }
    
    func ClientView() -> some View{
        VStack{
            HStack{
                BackToHomeButtonView()
                Spacer()
            }
            Spacer()
            if hmpgModel.role == 1{
                DriverView()
            }
            else if hmpgModel.role == 2{
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
                    updateRole(role: 2)
                    hmpgModel.role = 2
                    hmpgModel.is_home.toggle()
                }
                
                VStack{
                    Text("Driver")
                }
                .frame(width: UIScreen.screenWidth * 0.4, height: UIScreen.screenHeight * 0.22)
                .background(Color.blue)
                .cornerRadius(30)
                .onTapGesture {
                    updateRole(role: 1)
                    hmpgModel.role = 1
                    hmpgModel.is_home.toggle()
                    
                }
            }
        }
    }
    
    
    // ----- Map Functions
    
    func getCoordinateRegion() -> MKCoordinateRegion {
            let coordinates = locations.map { $0.coordinate }
            let boundingRect = MKPolygon(points: coordinates, count: coordinates.count).boundingMapRect
            let region = MKCoordinateRegion(boundingRect: boundingRect)
            return region
        }

        func calculateRoute() {
            guard locations.count > 1 else { return }
            isRouting = true

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: locations.first!.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: locations.last!.coordinate))
            request.waypoints = locations.dropFirst().dropLast().map {
                MKPlacemark(coordinate: $0.coordinate)
            }
            request.requestsAlternateRoutes = false

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                isRouting = false
                guard let route = response?.routes.first else { return }
                self.route = route
            }
        }

        func formattedDistance(_ meters: CLLocationDistance) -> String {
            let measurement = Measurement(value: meters, unit: UnitLength.meters)
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .naturalScale
            return formatter.string(from: measurement)
        }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
