// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class MachineViewController : UICollectionViewController {
	
	/// The machine being presented.
	var machine = Machine() {
		didSet { collectionView?.reloadData() }
	}
	
	/// The formatter used to format machine words.
	static let wordFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formatWidth = 10
		return formatter
	}()
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return AddressWord.unsignedUpperBound
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Word Cell", for: indexPath) as! WordCell
		let word = machine[address: AddressWord(rawValue: indexPath.item)!]
		cell.addressLabel.text = String(indexPath.item)
		cell.wordLabel.text = word.description
		return cell
	}
	
}

final class WordCell : UICollectionViewCell {
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var wordLabel: UILabel!
}
