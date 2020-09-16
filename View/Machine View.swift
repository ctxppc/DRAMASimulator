// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view that presents a machine and its script.
struct MachineView : View {
	
	/// Creates a view for emulating and editing given script.
	init(name: String, script: Binding<Script>) {
		self.name = name
		self._script = script
	}
	
	/// The document's name.
	let name: String
	
	/// The script.
	@Binding
	private var script: Script
	
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	// See protocol.
	var body: some View {
		contents
			.navigationTitle(name)
			.navigationBarTitleDisplayMode(.inline)
	}
	
	@ViewBuilder
	private var contents: some View {
		switch sizeClass {
			case .regular:	HStack { panels }
			default:		VStack { panels }
		}
	}
	
	@ViewBuilder
	private var panels: some View {
		ScriptEditor(script: $script)
	}
	
}

struct MachineViewPreviews : PreviewProvider {
	
	static var previews: some View {
		Demo()
	}
	
	private struct Demo : View {
		
		@State var script = templateScript
		
		var body: some View {
			NavigationView {
				MachineView(name: "Preview", script: $script)
			}
		}
		
	}
	
}
