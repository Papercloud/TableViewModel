import Foundation
import UIKit

public class TableSection: NSObject {

    public let tableView: UITableView
    private weak var tableViewModel: TableViewModel?
    public var rowAnimation: UITableViewRowAnimation
    internal var rows: NSMutableArray

    public init(tableViewModel: TableViewModel) {
        rows = NSMutableArray()
        tableView = tableViewModel.tableView
        self.tableViewModel = tableViewModel
        rowAnimation = UITableViewRowAnimation.Fade

        super.init()

        addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.New, context: nil)
    }

    deinit {
        removeObserver(self, forKeyPath: "rows")
    }

    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String:AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let indexSet: NSIndexSet = change?[NSKeyValueChangeIndexesKey] as! NSIndexSet else {
            return
        }

        guard let tableViewModel = self.tableViewModel else {
            NSException(name: "InvalidOperationException", reason: "This table section is not added to a table view model", userInfo: nil).raise()
            return
        }

        guard let kind: NSKeyValueChange = NSKeyValueChange(rawValue: change?[NSKeyValueChangeKindKey] as! UInt) else {
            return
        }

        let sectionIndex = tableViewModel.indexOfSection(self)

        var indexPaths = Array<NSIndexPath>()
        indexSet.enumerateIndexesUsingBlock {
            (idx, _) in

            let indexPath: NSIndexPath = NSIndexPath(forRow: idx, inSection: sectionIndex)
            indexPaths.append(indexPath)
        }

        self.tableView.beginUpdates()
        switch kind {
        case .Insertion:
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: rowAnimation)
        case .Removal:
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: rowAnimation)
        default:
            return
        }
        tableView.endUpdates()
    }

    public func addRow(row: TableRow) {
        observableRows().addObject(row)
    }

    public func removeRow(row: TableRow) {
        observableRows().removeObject(row)
    }

    public func numberOfRows() -> Int {
        return rows.count
    }

    public func rowAtIndex(index: Int) -> TableRow {
        return rows.objectAtIndex(index) as! TableRow
    }

    private func observableRows() -> NSMutableArray {
        return mutableArrayValueForKey("rows")
    }
}