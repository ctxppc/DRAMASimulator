// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
    var script: ScriptDocument?
	
	private var editingViewController: ScriptEditingController {
		return children[0] as! ScriptEditingController
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        script?.open { [unowned self] success in
			self.editingViewController.script = success ? self.script : nil
        }
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true) {
			self.script?.close()
        }
    }
	
}
