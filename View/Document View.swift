// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view that presents a document.
struct DocumentView : View {
	
	/// Creates a view for emulating and editing given script.
	init(name: String, document: Binding<Document>) {
		self.name = name
		self._document = document
	}
	
	/// The document's name.
	let name: String
	
	/// The document being presented.
	@Binding
	private var document: Document
	
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	// See protocol.
	var body: some View {
		contents
			.navigationTitle(name)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				Button(action: rewind) {
					Label("Step Backward", systemImage: "backward.end")
				}.disabled(!document.timeline.canRewind)
				Button(action: advance) {
					Label("Step Forward", systemImage: "forward.end")
				}.disabled(!document.timeline.canAdvance)
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
		ScriptEditor(script: $document.script)
		MemoryView(machine: document.machine)
	}
	
	private func rewind() {
		withAnimation {
			document.timeline.rewind()
		}
	}
	
	private func advance() {
		withAnimation {
			document.timeline.advance()
		}
	}
	
}

#if DEBUG
struct MachineViewPreviews : PreviewProvider {
	
	static var previews: some View {
		Demo()
	}
	
	private struct Demo : View {
		
		@State var document = Document(script: templateScript)
		
		var body: some View {
			NavigationView {
				DocumentView(name: "Preview", document: $document)
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
#endif
