import SwiftUI
import FirebaseCore

struct ReportView: View {
    @StateObject private var viewModel = LibraryViewModel()

    var totalCount: Int { viewModel.links.count }
    var readCount: Int { viewModel.links.filter { $0.isRead }.count }
    var unreadCount: Int { totalCount - readCount }
    var readRate: Double { totalCount > 0 ? Double(readCount) / Double(totalCount) : 0 }

    var categoryStats: [(name: String, count: Int, color: Color)] {
        [
            ("트렌드", viewModel.links.filter { $0.category == "트렌드" }.count, .orange),
            ("개발",   viewModel.links.filter { $0.category == "개발" }.count,   Color.appTeal),
            ("테크",   viewModel.links.filter { $0.category == "테크" }.count,   .purple)
        ].filter { $0.count > 0 }
    }

    var topTags: [(tag: String, count: Int)] {
        var freq: [String: Int] = [:]
        for link in viewModel.links {
            for tag in link.tags { freq[tag, default: 0] += 1 }
        }
        return freq.sorted { $0.value > $1.value }.prefix(6).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView().padding(.top, 60)
                } else if totalCount == 0 {
                    emptyState
                } else {
                    VStack(spacing: 16) {
                        statsRow
                        if !categoryStats.isEmpty { categoryCard }
                        if !topTags.isEmpty { tagCard }
                        readingProgressCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("리포트")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.fetchLinks() }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(value: "\(totalCount)", label: "저장된 링크", icon: "bookmark.fill", color: Color.appTeal)
            statCard(value: "\(readCount)", label: "읽은 링크", icon: "checkmark.circle.fill", color: .indigo)
            statCard(value: "\(Int(readRate * 100))%", label: "읽기율", icon: "chart.pie.fill", color: .orange)
        }
    }

    @ViewBuilder
    private func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Category Card

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("카테고리별 저장")
                .font(.subheadline.bold())

            ForEach(categoryStats, id: \.name) { stat in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(stat.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(stat.count)개")
                            .font(.caption.bold())
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray6))
                                .frame(height: 8)
                            Capsule()
                                .fill(stat.color)
                                .frame(
                                    width: totalCount > 0
                                        ? geo.size.width * (Double(stat.count) / Double(totalCount))
                                        : 0,
                                    height: 8
                                )
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Tag Card

    private var tagCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("인기 태그")
                .font(.subheadline.bold())

            let rows = stride(from: 0, to: topTags.count, by: 3).map {
                Array(topTags[$0..<min($0 + 3, topTags.count)])
            }
            ForEach(rows.indices, id: \.self) { rowIdx in
                HStack(spacing: 8) {
                    ForEach(rows[rowIdx], id: \.tag) { item in
                        Text("#\(item.tag)")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appTeal.opacity(0.1))
                            .foregroundColor(Color.appTeal)
                            .cornerRadius(20)
                        if item.count > 1 {
                            Text("\(item.count)")
                                .font(.caption2.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Reading Progress Card

    private var readingProgressCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("읽기 현황")
                .font(.subheadline.bold())

            HStack(spacing: 0) {
                if totalCount > 0 {
                    Rectangle()
                        .fill(Color.appTeal)
                        .frame(width: nil, height: 12)
                        .frame(maxWidth: .infinity * CGFloat(readRate))
                }
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 12)
            }
            .clipShape(Capsule())

            HStack {
                Circle().fill(Color.appTeal).frame(width: 8, height: 8)
                Text("읽음 \(readCount)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Circle().fill(Color(.systemGray5)).frame(width: 8, height: 8)
                Text("미읽음 \(unreadCount)개")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar")
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.4))
            Text("아직 링크가 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("링크를 저장하면 통계가 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 100)
    }
}
