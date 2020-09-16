// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view that presents a machine and its script.
struct MachineView : View {
	
	/// Creates a view for emulating and editing given script.
	init(name: String, script: Binding<Script>) {
		self.name = name
		self._script = script
		self._machine = .init(initialValue: Machine(for: script.wrappedValue))
	}
	
	/// The document's name.
	let name: String
	
	/// The machine.
	@State
	private var machine: Machine
	
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
			.onChange(of: script) { newScript in
				machine = Machine(for: newScript)
			}
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
		MemoryView(machine: machine)
	}
	
}

private extension Machine {
	
	/// Creates a machine loaded with given script.
	///
	/// An empty machine is created if the script can't be compiled.
	init(for script: Script) {
		if case .program(let program) = script.program {
			self = .init(memoryWords: program.words)
		} else {
			self = .init(memoryWords: .init(repeating: .zero, count: MachineWord.unsignedUpperBound))
		}
	}
	
}

#if DEBUG
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

let templateScript = Script(from:
	"""
	HIA.w R0, 20
	OPT R0, R1
	STP
	"""
)

let templateMachine = Machine(for: templateScript)
#endif
