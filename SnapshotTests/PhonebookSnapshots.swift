import Foundation
import SnapshottingTests

nonisolated class Snapshots: SnapshotTest {
  override class func snapshotPreviews() -> [String]? {
    guard let raw = ProcessInfo.processInfo.environment["SNAPSHOTS_ONLY_FILTER"], !raw.isEmpty else {
      return nil // record every #Preview
    }
    return raw.components(separatedBy: "\n")
  }
}
