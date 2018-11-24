// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
	var script: ScriptDocument? {
		willSet { script?.delegate = nil }
		didSet { script?.delegate = self }
	}
	
	/// (Re)loads the script, resetting any presented source text and machine.
	///
	/// The view controller is reset to its empty state if `script` is `nil`.
	private func updatePresentedScript() {
		
		if let script = script {
			title = script.fileURL.deletingPathExtension().lastPathComponent
			editingViewController.script = script
			machineViewController.machine = script.machine
		} else {
			title = "Geen document"
			editingViewController.script = nil
			machineViewController.machine = Machine()
		}
		
		loadProgram()
		
	}
	
	private func loadProgram() {
		
		pauseButton.isEnabled = false
		
		do {
			try script?.loadProgram()
			resumeButton.isEnabled = true
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
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        script?.open { [unowned self] success in
			DispatchQueue.main.async {
				
				if !success {
					self.script = nil
				}
				
				self.updatePresentedScript()
				
			}
        }
    }
	
	@IBAction func resumeMachine(_ sender: Any) {
		guard let script = script else { return }
		if script.machine.state == .waitingForInput {
			promptInput()
		} else {
			script.isRunning = true
			resumeButton.isEnabled = false
			pauseButton.isEnabled = true
		}
	}
	
	@IBAction func pauseMachine(_ sender: Any) {
		script?.isRunning = false
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
		
		alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
			if let integer = Int(alert.textFields![0].text ?? "") {
				self.script!.provideMachineInput(Word(wrapping: integer))
			} else {
				self.promptInput(message: "Geef een geldig getal in.")
			}
		})
		
		alert.addAction(UIAlertAction(title: "Pauzeer", style: .cancel))
		
		present(alert, animated: true)
		
	}
	
	@IBOutlet weak var resumeButton: UIBarButtonItem!
	@IBOutlet weak var pauseButton: UIBarButtonItem!
	@IBOutlet weak var resetButton: UIBarButtonItem!
	
	@IBAction func dismiss() {
        dismiss(animated: true) {
			self.script?.close()
			self.script = nil
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
