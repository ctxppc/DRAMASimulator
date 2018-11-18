// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptViewController : UIViewController {
	
	/// The script being presented.
    var script: ScriptDocument?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        script?.open { success in
            // TODO
        }
    }
    
    @IBAction func dismiss() {
        dismiss(animated: true) {
			self.script?.close()
        }
    }
	
}
