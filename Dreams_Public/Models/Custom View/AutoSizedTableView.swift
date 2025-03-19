//
//  AutoSizedTableView.swift
//  Communication
//
//  Created by Kasianov on 06.09.2023.
//

import UIKit

class AutoSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height
    
    func reloadData(completion: @escaping () -> Void) {
        beginUpdates()
        performBatchUpdates({
            super.reloadData()
        }, completion: {_ in
            self.invalidateIntrinsicContentSize()
            completion()
        })
        self.endUpdates()
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
    
    func addCell(count: Int, completion: @escaping () -> Void) {
        let indexPath = IndexPath(row: count - 1, section: 0)
        //beginUpdates()
        performBatchUpdates({
            super.insertRows(at: [indexPath], with: .fade)
        }, completion: {_ in
            self.invalidateIntrinsicContentSize()
            completion()
        })
        //endUpdates()
    }
    
    func deleteCell(indexPath: IndexPath, completion: @escaping () -> Void) {
        //beginUpdates()
        performBatchUpdates({
            super.deleteRows(at: [indexPath], with: .left)
        }, completion: {_ in
            self.invalidateIntrinsicContentSize()
            completion()
        })
        //endUpdates()
    }
}
