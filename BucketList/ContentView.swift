//
//  ContentView.swift
//  BucketList
//
//  Created by COBE on 09/05/2021.
//

import LocalAuthentication
import MapKit
import SwiftUI


struct unlockedView: View {
    @State var centerCoordinate: CLLocationCoordinate2D
    @State var locations :[CodableMKPointAnnotation]
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var showingEditScreen: Bool
    @Binding var authentificationError: Bool
    @Binding var showAlert: Bool
    var body: some View {
        MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, showAlert: $showAlert, annotations: locations)
            .edgesIgnoringSafeArea(.all)
        Circle()
            .fill(Color.blue)
            .opacity(0.3)
            .frame(width: 32, height: 32)
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    let newLocation = CodableMKPointAnnotation()
                    newLocation.title = "Example location"
                    newLocation.coordinate = self.centerCoordinate
                    self.locations.append(newLocation)
                    self.selectedPlace = newLocation
                    self.showingEditScreen = true
                }){
                    Image(systemName: "plus")
                        .padding()
                        .background(Color.black.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false
    @State private var isUnlocked = false
    @State private var authentificationError = false
    @State private var showAlert = false
    var body: some View {
        ZStack {
            if isUnlocked {
                unlockedView(centerCoordinate: centerCoordinate, locations: locations, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, showingEditScreen: $showingEditScreen, authentificationError: $authentificationError, showAlert: $showAlert)
            }
            else {
                Button("Unlock places"){
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
            }
        }
        .alert(isPresented: $showAlert){
            if showingPlaceDetails {
                return Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place informations"), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                        self.showingEditScreen = true
                })
            }
            else if authentificationError {
                return Alert(title: Text("Authentification error"), message: Text("Unable to authenticate"), dismissButton: .default(Text("OK")))
            }
            else {
                //biometrics error
                return Alert(title: Text("Biometrics error"), message: Text("Do you have biometrics?"), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData){
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
        .onAppear(perform: loadData)
    }
    func getDocumentsDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func loadData(){
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        }
        catch {
            print("Unable to load saved data.")
        }
    }
    func saveData(){
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        }
        catch {
            print("Unable to save data.")
        }
    }
    func authenticate(){
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "Please authenticate yourself to unlock your places"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason){  success, authentificationError in
                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    }
                    else {
                        self.authentificationError = true
                        self.showAlert = true
                    }
                }
            }
        }
        else {
            self.showAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
