// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class MachineViewController : UICollectionViewController {
	
	/// The machine being presented.
	var machine = Machine() {
		didSet { collectionView?.reloadData() }
	}
	
	/// The formatter used to format machine words.
	private static let wordFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 10
		formatter.maximumIntegerDigits = 10
		return formatter
	}()
	
	/// The text colour used for zeroes and leading zeroes in words.
	private static let zeroColour = UIColor.lightGray
	
	/// Returns an attributed string formatting given word.
	private static func attributedString(for word: Word) -> NSAttributedString {
		let string = wordFormatter.string(from: word.rawValue as NSNumber)!
		if let indexOfLeadingDigit = string.firstIndex(where: { $0 != "0" }) {
			let attributedString = NSMutableAttributedString(string: string)
			attributedString.addAttributes([.foregroundColor : zeroColour], range: NSRange(string.startIndex..<indexOfLeadingDigit, in: string))
			return attributedString
		} else {
			return NSAttributedString(string: string, attributes: [.foregroundColor : zeroColour])
		}
	}
	
	private enum Section : Int, CaseIterable {
		
		init(for indexPath: IndexPath) {
			self.init(rawValue: indexPath.section)!
		}
		
		case terminal
		case registers
		case memory
		
		var title: String {
			switch self {
				case .terminal:		return "Terminal"
				case .registers:	return "Accumulatoren"
				case .memory:		return "Geheugen"
			}
		}
		
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Section.allCases.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! SectionHeaderView
		cell.titleLabel.text = Section(for: indexPath).title
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch Section(rawValue: section)! {
			case .terminal:		return 0
			case .registers:	return Register.indices.count
			case .memory:		return AddressWord.unsignedUpperBound
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		func cell(for word: Word, prefix: String = "") -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Word Cell", for: indexPath) as! WordCell
			cell.addressLabel.text = prefix + String(indexPath.item)
			cell.wordLabel.attributedText = MachineViewController.attributedString(for: word)
			return cell
		}
		
		switch Section(for: indexPath) {
			case .terminal:		preconditionFailure("Terminal index out of bounds")
			case .registers:	return cell(for: machine[register: Register(rawValue: indexPath.item)!], prefix: "R")
			case .memory:		return cell(for: machine[address: AddressWord(rawValue: indexPath.item)!])
		}
		
	}
	
}

final class WordCell : UICollectionViewCell {
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var wordLabel: UILabel!
}

final class SectionHeaderView : UICollectionReusableView {
	@IBOutlet weak var titleLabel: UILabel!
}
