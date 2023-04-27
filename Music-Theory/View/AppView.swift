import SwiftUI
import CoreData
import MusicKit

struct AppView : View {
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        //Use this if NavigationBarTitle is with Large Font
        //UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.red]
        //Use this if NavigationBarTitle is with displayMode = .inline
        //UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.red]
        //UINavigationBar.appearance().barStyle
      }

    var body: some View {
        TabView {
            
            IntervalView()
            .tabItem {
                Label("Intervals", image: "intervals")
            }
            
            CadenceView()
            .tabItem {
                Label("Cadences", image: "cadences")
            }
            //TODO set order...
            
            DegreeTriadsView()
            .tabItem {
                Label("Triad", image: "triads")
            }

//
//            MidiTest()
//            .tabItem {
//                Label("Midi Test", image: "")
//            }

        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }

    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}
