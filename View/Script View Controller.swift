// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
	var script: ScriptDocument? {
		willSet { script?.delegate = nil }
		didSet { script?.delegate = self }
	}
	
	private var editingViewController: ScriptEditingController {
		return children[0] as! ScriptEditingController
	}
	
	private var machineViewController: MachineViewController {
		return children[1] as! MachineViewController
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        script?.open { [unowned self] success in
			DispatchQueue.main.async {
				do {
					if let script = self.script, success {
						self.title = script.fileURL.deletingPathExtension().lastPathComponent
						self.editingViewController.script = script
						self.machineViewController.machine = try script.initialMachine()
					} else {
						self.title = "No document"
						self.editingViewController.script = nil
						self.machineViewController.machine = Machine()
					}
				} catch {
					let alert = UIAlertController(title: "Could not load machine", message: error.localizedDescription, preferredStyle: .alert)
					alert.addAction(.init(title: "OK", style: .default))
					self.present(alert, animated: true)
				}
			}
        }
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true) {
			self.script?.close()
        }
    }
	
}

extension ScriptViewController : ScriptDocumentDelegate {
	func scriptDocumentSourceTextDidChange(_ document: ScriptDocument) {
		do {
			machineViewController.machine = try script?.initialMachine() ?? .init()
		} catch {
			let alert = UIAlertController(title: "Could not load machine", message: error.localizedDescription, preferredStyle: .alert)
			alert.addAction(.init(title: "OK", style: .default))
			present(alert, animated: true)
		}
	}
}
