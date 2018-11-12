// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class DocumentBrowserViewController : UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
    }
	
	// See protocol.
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, ImportMode) -> ()) {
		
		let documentURL: URL? = nil
		
		// TODO: Determine URL.
		
		importHandler(documentURL, documentURL != nil ? .move : .none)
		
    }
	
	// See protocol.
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        presentDocument(at: sourceURL)
    }
	
	// See protocol.
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        presentDocument(at: destinationURL)
    }
	
	// See protocol.
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
       // TODO: Present error.
    }
	
	/// Presents the document at a given URL.
    func presentDocument(at url: URL) {
		let navigationController = storyboard!.instantiateViewController(withIdentifier: "Root Navigation Controller") as! UINavigationController
		let scriptViewController = navigationController.viewControllers.first as! ScriptViewController
		scriptViewController.script = Script(fileURL: url)
        present(navigationController, animated: true, completion: nil)
    }
	
}

