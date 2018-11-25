// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
	var scriptDocument: ScriptDocument?
	
	/// The timeline being presented.
	private var timeline: Timeline? {
		willSet { timeline?.delegate = nil }
		didSet { timeline?.delegate = self }
	}
	
	private func discardTimeline() {
		timeline?.direction = .still
		timeline = nil
	}
	
	/// (Re)loads the script, resetting any presented source text and machine.
	///
	/// The view controller is reset to its empty state if `script` is `nil`.
	private func updatePresentedScript() {
		
		if let scriptDocument = scriptDocument {
			title = scriptDocument.fileURL.deletingPathExtension().lastPathComponent
			editingViewController.script = scriptDocument.script
		} else {
			title = "Geen document"
			editingViewController.script = .init()
		}
		
		loadProgram()
		
	}
	
	/// Loads the program into the machine.
	private func loadProgram() {
		
		discardTimeline()
		
		guard let document = scriptDocument else { return }
		do {
			let machine = Machine(memoryWords: try document.program().machineWords())
			timeline = .init(machine: machine)
			machineViewController.machine = machine
		} catch _ as ScriptDocument.PartialScriptError {
			// Source errors are already handled by the script editing controller.
		} catch {
			present(error)
		}
		
		updateToolbarButtons()
		
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
	
	@IBAction func moveBackward(_ sender: Any) {
		timeline?.moveBackward()
		updateToolbarButtons()
	}
	
	@IBAction func moveForward(_ sender: Any) {
		timeline?.moveForward()
		updateToolbarButtons()
	}
	
	@IBAction func rewindTimeline(_ sender: Any) {
		timeline?.direction = .backward
		updateToolbarButtons()
	}
	
	@IBAction func pauseTimeline(_ sender: Any) {
		timeline?.direction = .still
		updateToolbarButtons()
	}
	
	@IBAction func resumeTimeline(_ sender: Any) {
		timeline?.direction = .forward
		updateToolbarButtons()
	}
	
	@IBAction func resetTimeline(_ sender: Any) {
		loadProgram()
		updateToolbarButtons()
	}
	
	fileprivate func promptInput(message: String? = nil) {
		
		guard let timeline = timeline else { return }
		
		let alert = UIAlertController(title: "Invoer", message: message, preferredStyle: .alert)
		alert.addTextField { textField in
			textField.keyboardType = .decimalPad
		}
		
		let ok = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
			if let integer = Int(alert.textFields![0].text ?? "") {
				timeline.provideMachineInput(Word(wrapping: integer))
				self.updateToolbarButtons()
			} else {
				self.promptInput(message: "Geef een geldig getal in.")
			}
		}
		
		alert.addAction(UIAlertAction(title: "Pauzeer", style: .cancel))
		alert.addAction(ok)
		alert.preferredAction = ok
		
		present(alert, animated: true)
		
	}
	
	private func updateToolbarButtons() {
		(moveBackwardButton.isEnabled, moveForwardButton.isEnabled, rewindButton.isEnabled, pauseButton.isEnabled, resumeButton.isEnabled, resetButton.isEnabled) = {
			guard let timeline = timeline else { return (false, false, false, false, false, false) }
			let canRewind = timeline.canRewind
			let canResume = timeline.currentMachine.state != .halted
			switch timeline.direction {
				case .still:	return (canRewind, canResume, canRewind, false, canResume, true)
				case .forward:	return (false, false, true, true, false, true)
				case .backward:	return (false, false, false, true, true, true)
			}
		}()
	}
	
	@IBOutlet weak var moveBackwardButton: UIBarButtonItem!
	@IBOutlet weak var moveForwardButton: UIBarButtonItem!
	@IBOutlet weak var rewindButton: UIBarButtonItem!
	@IBOutlet weak var pauseButton: UIBarButtonItem!
	@IBOutlet weak var resumeButton: UIBarButtonItem!
	@IBOutlet weak var resetButton: UIBarButtonItem!
	
	@IBAction func dismiss() {
        dismiss(animated: true) {
			self.discardTimeline()
			self.scriptDocument?.close()
			self.scriptDocument = nil
			self.updatePresentedScript()
        }
    }
	
}

extension ScriptViewController : TimelineDelegate {
	
	func currentMachineDidChange(on timeline: Timeline) {
		machineViewController.machine = timeline.currentMachine
	}
	
	func machineWaitsForInput(on timeline: Timeline) {
		updateToolbarButtons()
		promptInput()
	}
	
	func machineExecutionDidFail(withError error: Error, on timeline: Timeline) {
		updateToolbarButtons()
		present(error)
	}
	
	func timelineDidFinishMoving(on timeline: Timeline) {
		updateToolbarButtons()
	}
	
}

extension ScriptViewController : ScriptEditingControllerDelegate {
	func sourceTextDidChange(on controller: ScriptEditingController) {
		
		guard let scriptDocument = scriptDocument else { return }
		
		let previousScript = scriptDocument.script
		scriptDocument.undoManager.registerUndo(withTarget: scriptDocument) { scriptDocument in
			scriptDocument.script = previousScript
		}
		
		scriptDocument.script = controller.script
		loadProgram()
		
	}
}
