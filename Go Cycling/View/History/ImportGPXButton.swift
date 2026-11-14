//
//  ImportGPXButton.swift
//  Go Cycling
//
//  Created by Anthony Hopkins on 2026-11-13.
//

import SwiftUI

// Opens the Files picker and imports the selected GPX files. The result message is handed back through
// onImportFinished so the caller can show it: the button itself may be gone by then (e.g. the empty
// History screen is replaced by the ride list as soon as rides are imported)
struct ImportGPXButton<Label: View>: View {
    var onImportStarted: () -> Void = {}
    let onImportFinished: (String) -> Void
    @ViewBuilder let label: (_ isImporting: Bool) -> Label

    @State private var showingFileImporter = false
    @State private var isImporting = false

    var body: some View {
        Button(action: { showingFileImporter = true }) {
            label(isImporting)
        }
        .disabled(isImporting)
        .fileImporter(isPresented: $showingFileImporter, allowedContentTypes: [GPXImporter.gpxContentType], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls):
                importRides(from: urls)
            case .failure(let error):
                print("GPX file selection failed: \(error.localizedDescription)")
                onImportFinished("The selected files could not be opened.")
            }
        }
    }

    private func importRides(from urls: [URL]) {
        // The picker can hand back nothing when iOS fails to download a file (e.g. from iCloud Drive or another file provider)
        guard !urls.isEmpty else {
            onImportFinished("The selected files could not be opened. If they are stored in iCloud Drive or another cloud service, open them in the Files app first so they download, then try again.")
            return
        }
        isImporting = true
        onImportStarted()

        GPXImporter.importFiles(at: urls, container: PersistenceController.shared.container) { summary in
            isImporting = false
            onImportFinished(summary.message)
        }
    }
}
