// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view that presents two views stacked horizontally or vertically depending on the view's horizontal size class, and provides a resizing control.
struct SplitView<First : View, Second : View> : View {
	
	/// Creates a split view with given contents.
	init(ratio: CGFloat = 0.5, @ViewBuilder content: () -> TupleView<(First, Second)>) {
		(first, second) = content().value
		_ratio = .init(initialValue: ratio)
	}
	
	/// The first view.
	let first: First
	
	/// The second view.
	let second: Second
	
	/// The view's horizontal size class.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// The ratio of the first view's size to the total size.
	@State
	private var ratio: CGFloat
	
	// See protocol.
    var body: some View {
		if sizeClass == .compact {
			VStack {
				first
				Divider().edgesIgnoringSafeArea(.all)
				second
			}
		} else {
			HStack {
				first
				Divider().edgesIgnoringSafeArea(.all)
				second
			}
		}
    }
	
}

struct SplitViewPreviews : PreviewProvider {
    static var previews: some View {
		SplitView {
			Text("a")
			Text("b")
		}.previewLayout(.device)
    }
}
