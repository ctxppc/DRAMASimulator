// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

@UIApplicationMain class DRAMASimulatorDelegate : UIResponder, UIApplicationDelegate {
	
	// See protocol.
	var window: UIWindow?
	
	// See protocol.
	func application(_ app: UIApplication, open inputURL: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
		
		guard inputURL.isFileURL else { return false }
		guard let documentBrowserViewController = window?.rootViewController as? DocumentBrowserViewController else { return false }
		documentBrowserViewController.revealDocument(at: inputURL, importIfNeeded: true) { revealedDocumentURL, error in
			
		    if let error = error {
		        print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
		        return
		    }
			
		    documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
			
		}
		
		return true
		
	}
	
}

