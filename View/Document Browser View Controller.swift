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
		do {
			
			let temporaryFileURL = try FileManager.default.url(
				for:			.itemReplacementDirectory,
				in:				.userDomainMask,
				appropriateFor:	FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
				create:			true
			).appendingPathComponent("Nieuw.dra")
			
			try Data().write(to: temporaryFileURL)
			importHandler(temporaryFileURL, .move)
			
		} catch {
			importHandler(nil, .none)
		}
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
		if let error = error {
			present(error)
		} else {
			let alert = UIAlertController(title: "Fout bij het laden", message: nil, preferredStyle: .alert)
			alert.addAction(.init(title: "OK", style: .default))
			present(alert, animated: true)
		}
    }
	
	/// Presents the document at a given URL.
    func presentDocument(at url: URL) {
		let navigationController = storyboard!.instantiateViewController(withIdentifier: "Root Navigation Controller") as! UINavigationController
		let scriptViewController = navigationController.viewControllers.first as! ScriptViewController
		scriptViewController.scriptDocument = ScriptDocument(fileURL: url)
        present(navigationController, animated: true)
    }
	
}
