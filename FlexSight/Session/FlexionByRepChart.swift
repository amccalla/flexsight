//
//  FlexionByRepChart.swift
//  FlexSight
//

import Charts
import SwiftUI

/// Peak flexion per rep. Low-confidence reps are shown — marked, not hidden —
/// so the patient sees everything that was scanned.
struct FlexionByRepChart: View {
    let reps: [Rep]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Flexion by rep")
                    .font(.headline)
                    .foregroundStyle(Color.labelPrimary)
                Spacer()
                Text("Peak angle")
                    .font(.caption)
                    .foregroundStyle(Color.labelSecondary)
            }
            Chart(reps) { rep in
                BarMark(
                    x: .value("Rep", "\(rep.number)"),
                    y: .value("Peak flexion", rep.peakFlexion),
                    width: .ratio(0.6)
                )
                .foregroundStyle(rep.isLowConfidence ? Color.orange : Color.accentPrimary)
                .cornerRadius(6)
                .annotation(position: .top) {
                    Text("\(Int(rep.peakFlexion.rounded()))")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(rep.isLowConfidence ? Color.orange : Color.labelSecondary)
                }
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
            .frame(height: 140)
            if lowConfidenceCount > 0 {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                    Text("^[\(lowConfidenceCount) rep](inflect: true) below confidence threshold")
                        .font(.caption)
                        .foregroundStyle(Color.labelSecondary)
                }
            }
        }
        .padding(20)
        .background(Color.backgroundPrimary, in: .rect(cornerRadius: 20))
    }

    private var lowConfidenceCount: Int {
        reps.count(where: \.isLowConfidence)
    }
}

#Preview {
    FlexionByRepChart(reps: [
        Rep(number: 1, workout: .bodyweightSquat, peakFlexion: 88, meanConfidence: 0.92, isLowConfidence: false),
        Rep(number: 2, workout: .bodyweightSquat, peakFlexion: 94, meanConfidence: 0.94, isLowConfidence: false),
        Rep(number: 3, workout: .bodyweightSquat, peakFlexion: 97, meanConfidence: 0.5, isLowConfidence: true),
        Rep(number: 4, workout: .standingKneeRaise, peakFlexion: 104, meanConfidence: 0.91, isLowConfidence: false),
    ])
    .padding(20)
    .background(Color.backgroundSecondary)
}
