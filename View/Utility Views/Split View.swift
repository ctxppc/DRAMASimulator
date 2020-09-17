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
	
	/// The split view's namespace.
	@Namespace
	private var namespace
	
	// See protocol.
    var body: some View {
		GeometryReader { geometry in
			if sizeClass == .compact {
				VStack {
					first
						.frame(height: geometry.size.height * ratio)
					SplitViewControl(ratio: $ratio, axis: .vertical, splitViewSize: geometry.size.height, splitViewCoordinateSpace: namespace)
					second
						.frame(minHeight: 0, maxHeight: .infinity, alignment: .center)
				}
			} else {
				HStack {
					first
						.frame(width: geometry.size.width * ratio)
					SplitViewControl(ratio: $ratio, axis: .horizontal, splitViewSize: geometry.size.width, splitViewCoordinateSpace: namespace)
					second
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
				}
			}
		}.coordinateSpace(name: namespace)
    }
	
}

/// A control that resizes a view in a split view.
private struct SplitViewControl : View {
	
	/// Creates a split view control.
	init(ratio: Binding<CGFloat>, axis: Axis, splitViewSize: CGFloat, splitViewCoordinateSpace: Namespace.ID) {
		self._ratio = ratio
		self.axis = axis
		self.splitViewSize = splitViewSize
		self.splitViewCoordinateSpace = splitViewCoordinateSpace
	}
	
	/// The ratio.
	@Binding
	private var ratio: CGFloat
	
	/// The ratio before any dragging, or `nil` if no dragging is occuring.
	@GestureState
	private var originalRatio: CGFloat?
	
	/// The axis in which the control moves.
	let axis: Axis
	
	/// The size of the split view over `axis`.
	let splitViewSize: CGFloat
	
	/// The coordinate space of the split view.
	let splitViewCoordinateSpace: Namespace.ID
	
	// See protocol.
	var body: some View {
		switch axis {
			
			case .vertical:
			HStack {
				Spacer()
				capsule
					.frame(width: 50, height: 8)
				Spacer()
			}.background(Color(.systemBackground))
				
			case .horizontal:
			VStack {
				Spacer()
				capsule
					.frame(width: 8, height: 50)
				Spacer()
			}.background(Color(.systemBackground))
			
		}
	}
	
	/// The capsule.
	private var capsule: some View {
		Capsule()
			.foregroundColor(.init(.separator))
			.gesture(
				DragGesture(coordinateSpace: .named(splitViewCoordinateSpace))
					.updating($originalRatio) { (_, originalRatio, _) in
						originalRatio = originalRatio ?? ratio
					}.onChanged(dragged)
			)
	}
	
	/// Updates the ratio in response to a drag update.
	private func dragged(value: DragGesture.Value) {
		
		guard let originalRatio = originalRatio else { return }	// first drag update can be ignored safely
		
		let translation: CGFloat
		switch axis {
			case .vertical:		translation = value.translation.height
			case .horizontal:	translation = value.translation.width
		}
		
		ratio = (originalRatio + translation / splitViewSize).capped(to: ratioRange)
		
	}
	
	/// The permissible range of the ratio.
	let ratioRange: ClosedRange<CGFloat> = 0.1...0.9
	
}

struct SplitViewPreviews : PreviewProvider {
    static var previews: some View {
		SplitView {
			Text("a")
			Text("b")
		}.previewLayout(.device)
    }
}
