// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
	var scriptDocument: ScriptDocument? {
		willSet { scriptDocument?.delegate = nil }
		didSet { scriptDocument?.delegate = self }
	}
	
	/// (Re)loads the script, resetting any presented source text and machine.
	///
	/// The view controller is reset to its empty state if `script` is `nil`.
	private func updatePresentedScript() {
		
		if let scriptDocument = scriptDocument {
			title = scriptDocument.fileURL.deletingPathExtension().lastPathComponent
			editingViewController.script = scriptDocument.script
			machineViewController.machine = scriptDocument.machine
		} else {
			title = "Geen document"
			editingViewController.script = .init()
			machineViewController.machine = .init()
		}
		
		loadProgram()
		
	}
	
	/// Loads the program into the machine.
	private func loadProgram() {
		do {
			pauseButton.isEnabled = false
			try scriptDocument?.loadProgram()
			resumeButton.isEnabled = true
		} catch _ as ScriptDocument.PartialScriptError {
			resumeButton.isEnabled = false
		} catch {
			resumeButton.isEnabled = false
			present(error)
		}
	}
	
	/// The child view controller for editing the source text.
	private var editingViewController: ScriptEditingController {
		return children[0] as! ScriptEditingController
	}
	
	/// The child view controller for viewing the machine.
	private var machineViewController: MachineViewController {
		return children[1] as! MachineViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		editingViewController.delegate = self
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scriptDocument?.open { [unowned self] success in
			DispatchQueue.main.async {
				
				if !success {
					self.scriptDocument = nil
				}
				
				self.updatePresentedScript()
				
			}
        }
    }
	
	@IBAction func resumeMachine(_ sender: Any) {
		guard let scriptDocument = scriptDocument else { return }
		if scriptDocument.machine.state == .waitingForInput {
			promptInput()
		} else {
			scriptDocument.isRunning = true
			resumeButton.isEnabled = false
			pauseButton.isEnabled = true
		}
	}
	
	@IBAction func pauseMachine(_ sender: Any) {
		scriptDocument?.isRunning = false
		resumeButton.isEnabled = true
		pauseButton.isEnabled = false
	}
	
	@IBAction func resetMachine(_ sender: Any) {
		loadProgram()
		resumeButton.isEnabled = true
		pauseButton.isEnabled = false
	}
	
	fileprivate func promptInput(message: String? = nil) {
		
		let alert = UIAlertController(title: "Invoer", message: message, preferredStyle: .alert)
		alert.addTextField()
		
		
		let ok = UIAlertAction(title: "OK", style: .default) { action in
			if let integer = Int(alert.textFields![0].text ?? "") {
				self.scriptDocument!.provideMachineInput(Word(wrapping: integer))
			} else {
				self.promptInput(message: "Geef een geldig getal in.")
			}
		}
		
		alert.addAction(UIAlertAction(title: "Pauzeer", style: .cancel))
		alert.addAction(ok)
		alert.preferredAction = ok
		
		present(alert, animated: true)
		
	}
	
	@IBOutlet weak var resumeButton: UIBarButtonItem!
	@IBOutlet weak var pauseButton: UIBarButtonItem!
	@IBOutlet weak var resetButton: UIBarButtonItem!
	
	@IBAction func dismiss() {
        dismiss(animated: true) {
			self.scriptDocument?.close()
			self.scriptDocument = nil
			self.updatePresentedScript()
        }
    }
	
}

extension ScriptViewController : ScriptDocumentDelegate {
	
	func scriptDocumentSourceTextDidChange(_ script: ScriptDocument) {
		loadProgram()
	}
	
	func scriptDocumentMachineDidChange(_ document: ScriptDocument) {
		machineViewController.machine = document.machine
	}
	
	func scriptDocumentWaitsForInput(_ document: ScriptDocument) {
		pauseButton.isEnabled = false
		promptInput()
	}
	
	func scriptDocument(_ document: ScriptDocument, failedExecutionWithError error: Error) {
		pauseButton.isEnabled = false
		present(error)
	}
	
	func scriptDocumentCompletedExecution(_ document: ScriptDocument) {
		pauseButton.isEnabled = false
	}
	
}

extension ScriptViewController : ScriptEditingControllerDelegate {
	func scriptEditingControllerDidChangeSourceText(_ controller: ScriptEditingController) {
		
		guard let scriptDocument = scriptDocument else { return }
		
		let previousScript = scriptDocument.script
		scriptDocument.undoManager.registerUndo(withTarget: scriptDocument) { scriptDocument in
			scriptDocument.script = previousScript
		}
		
		scriptDocument.script = controller.script
		loadProgram()
		
	}
}
