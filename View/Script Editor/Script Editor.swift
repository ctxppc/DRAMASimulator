// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

struct ScriptEditor : UIViewControllerRepresentable {
	
	/// Creates an editor for given script.
	init(script: Binding<Script>, programCounter: Binding<AddressWord>) {
		_script = script
		_programCounter = programCounter
	}
	
	/// The script being edited.
	@Binding
	private var script: Script
	
	/// The program counter.
	@Binding
	private var programCounter: AddressWord
	
	// See protocol.
	func makeCoordinator() -> Coordinator {
		Coordinator(script: $script)
	}
	
	// See protocol.
	func makeUIViewController(context: Context) -> ScriptEditingController {
		let controller: ScriptEditingController = UIStoryboard(name: "DRAMASimulator", bundle: .main).instantiateViewController(identifier: "EditorController")
		controller.delegate = context.coordinator
		return controller
	}
	
	// See protocol.
	func updateUIViewController(_ controller: ScriptEditingController, context: Context) {
		controller.script = script
		controller.programCounter = programCounter
	}
	
	// See protocol.
	class Coordinator : NSObject, ScriptEditingControllerDelegate {
		
		/// Creates a coordinator for editing given script.
		init(script: Binding<Script>) {
			self._script = script
		}
		
		/// The script being edited.
		@Binding
		private var script: Script
		
		func sourceTextDidChange(on controller: ScriptEditingController) {
			script = controller.script
		}
		
		func selectedRangeDidChange(on controller: ScriptEditingController) {
			// TODO
		}
		
	}
	
}

#if DEBUG
struct ScriptEditorPreviews: PreviewProvider {
	
	static var previews: some View {
		Demo()
	}
	
	private struct Demo : View {
		
		@State
		var script = templateScript
		
		var body: some View {
			ScriptEditor(script: $script, programCounter: .constant(.zero))
		}
		
	}
	
}
#endif
