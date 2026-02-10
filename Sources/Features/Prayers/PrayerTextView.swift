import SwiftUI

struct PrayerTextView: View {
    let prayer: Prayer
    @State private var viewModel: PrayerTextViewModel
    @State private var showTableOfContents = false
    @State private var scrollProxy: ScrollViewProxy?
    
    init(prayer: Prayer) {
        self.prayer = prayer
        self._viewModel = State(initialValue: PrayerTextViewModel(
            prayerService: DependencyContainer.shared.prayerService,
            cacheService: DependencyContainer.shared.prayerCacheService,
            localSettings: DependencyContainer.shared.localSettings,
            locationRepository: DependencyContainer.shared.locationRepository
        ))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.hasError {
                    errorView
                } else if let prayerText = viewModel.prayerText {
                    prayerContentView(prayerText)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle(viewModel.prayerTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        // Navigation handled by NavigationLink
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if viewModel.hasTableOfContents {
                            Button("TOC") {
                                showTableOfContents.toggle()
                            }
                        }
                        
                        Button("Refresh") {
                            Task {
                                await viewModel.refreshPrayer()
                            }
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
            }
            .task {
                await viewModel.loadPrayer(prayer)
            }
            .sheet(isPresented: $showTableOfContents) {
                TableOfContentsView(
                    items: viewModel.tableOfContentsItems,
                    onSelection: { sectionId in
                        viewModel.scrollToSection(sectionId)
                        scrollProxy?.scrollTo(sectionId, anchor: .top)
                    }
                )
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading prayer text...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Unable to load prayer")
                .font(.headline)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Try Again") {
                Task {
                    await viewModel.refreshPrayer()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No prayer text available")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Prayer Content View
    private func prayerContentView(_ prayerText: PrayerText) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .trailing, spacing: 0) {
                    ForEach(viewModel.displayableSections, id: \.id) { section in
                        prayerSectionView(section)
                            .id(section.section.id)
                    }
                }
                .padding()
                .onAppear {
                    scrollProxy = proxy
                }
            }
            .coordinateSpace(name: "scroll")
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Prayer Section View
    private func prayerSectionView(_ section: DisplayablePrayerSection) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Section title (if not a repetition)
            if let title = viewModel.sectionTitle(for: section), !title.isEmpty {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.bottom, 4)
            }
            
            // Section content
            Text(viewModel.sectionContent(for: section))
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
            
            // Repetition indicator
            if viewModel.isRepetitionSection(section) {
                Text("(Repeat)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .padding(.bottom, 8)
    }
}

// MARK: - Table of Contents View
private struct TableOfContentsView: View {
    let items: [TableOfContentsItem]
    let onSelection: (String) -> Void
    
    var body: some View {
        NavigationStack {
            List(items, id: \.id) { item in
                Button(action: {
                    onSelection(item.id)
                }) {
                    HStack {
                        Text(item.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .navigationTitle("Table of Contents")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.layoutDirection, .rightToLeft)
        }
    }
}

// MARK: - Prayer Text Extensions
extension PrayerTextView {
    private var hebrewFont: UIFont {
        // Use a Hebrew font if available, otherwise system font
        if let hebrewFont = UIFont(name: "Arial Hebrew", size: 20) {
            return hebrewFont
        }
        return UIFont.systemFont(ofSize: 20)
    }
}

// MARK: - Accessibility Support
extension PrayerTextView {
    private func makeAccessible(_ text: String) -> String {
        // Add accessibility annotations if needed
        return text
    }
}

// MARK: - Preview
#Preview {
    let prayer = Prayer(type: .shacharit)
    return PrayerTextView(prayer: prayer)
}