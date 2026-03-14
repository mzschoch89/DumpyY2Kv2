import SwiftUI

struct Y2K {
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.91)
    static let warmBg = Color(red: 0.97, green: 0.95, blue: 0.88)
    static let hotPink = Color(red: 0.95, green: 0.05, blue: 0.55)
    static let bubblegumPink = Color(red: 1.0, green: 0.30, blue: 0.65)
    static let limeGreen = Color(red: 0.55, green: 0.85, blue: 0.15)
    static let brightLime = Color(red: 0.72, green: 0.95, blue: 0.10)
    static let deepGreen = Color(red: 0.15, green: 0.38, blue: 0.18)
    static let turquoise = Color(red: 0.0, green: 0.62, blue: 0.58)
    static let lavender = Color(red: 0.72, green: 0.55, blue: 0.95)
    static let brightLavender = Color(red: 0.80, green: 0.60, blue: 1.0)
    static let softPink = Color(red: 1.0, green: 0.65, blue: 0.80)
    static let mintGreen = Color(red: 0.55, green: 0.95, blue: 0.70)
    static let paleYellow = Color(red: 1.0, green: 0.97, blue: 0.60)
    static let brightYellow = Color(red: 0.98, green: 0.92, blue: 0.30)
    static let darkText = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let teal = Color(red: 0.20, green: 0.70, blue: 0.65)
    static let deepPurple = Color(red: 0.50, green: 0.20, blue: 0.75)
}

struct Y2KCardGradient: View {
    var style: Int = 0

    var body: some View {
        switch style {
        case 0:
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.6, 0.4], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Color(red: 1.0, green: 0.15, blue: 0.55), Color(red: 0.95, green: 0.30, blue: 0.65), Color(red: 0.75, green: 0.50, blue: 0.95),
                    Color(red: 1.0, green: 0.45, blue: 0.65), Color(red: 1.0, green: 0.60, blue: 0.70), Color(red: 0.82, green: 0.62, blue: 0.98),
                    Color(red: 1.0, green: 0.82, blue: 0.30), Color(red: 0.98, green: 0.88, blue: 0.40), Color(red: 1.0, green: 0.78, blue: 0.45)
                ]
            )
        case 1:
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Y2K.mintGreen, Y2K.brightLime, Y2K.paleYellow,
                    Y2K.limeGreen, Y2K.softPink, Y2K.brightLavender,
                    Y2K.brightYellow, Y2K.bubblegumPink, Y2K.lavender
                ]
            )
        default:
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    Y2K.brightLavender, Y2K.softPink, Y2K.bubblegumPink,
                    Y2K.lavender, Y2K.brightLime, Y2K.mintGreen,
                    Y2K.paleYellow, Y2K.hotPink, Y2K.softPink
                ]
            )
        }
    }
}

struct Y2KBackgroundGradient: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Y2K.cream, Color(red: 1.0, green: 0.95, blue: 0.88), Y2K.cream,
                Color(red: 0.98, green: 0.95, blue: 0.90), Color(red: 0.95, green: 0.97, blue: 0.88), Color(red: 1.0, green: 0.94, blue: 0.90),
                Color(red: 0.96, green: 0.98, blue: 0.90), Y2K.cream, Color(red: 0.98, green: 0.95, blue: 0.92)
            ]
        )
        .ignoresSafeArea()
    }
}

struct Y2KDashedBorder: ViewModifier {
    var color: Color = Y2K.hotPink
    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 2
    var dash: [CGFloat] = [8, 5]

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(style: StrokeStyle(lineWidth: lineWidth, dash: dash))
                    .foregroundStyle(color)
            )
    }
}

struct Y2KSolidBorder: ViewModifier {
    var color: Color = Y2K.teal
    var cornerRadius: CGFloat = 20
    var lineWidth: CGFloat = 2.5

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: lineWidth)
            )
    }
}

struct SparkleDecoration: View {
    var size: CGFloat = 32
    var color: Color = .white

    var body: some View {
        Text("✦")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(color)
    }
}

struct SparkleText: View {
    let text: String
    var font: Font = .system(.title2, design: .rounded, weight: .bold)

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(font)
                .foregroundStyle(Y2K.turquoise)
            Text("✨")
                .font(.caption)
        }
    }
}

struct Y2KHeader: View {
    let prefix: String
    let accent: String
    var emoji: String? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(prefix + " ")
                .font(.system(size: 38, weight: .black, design: .rounded))
                .foregroundStyle(Y2K.hotPink)
                .offset(y: 8)
            Text(accent)
                .font(.system(.title, design: .serif, weight: .bold))
                .italic()
                .foregroundStyle(Y2K.turquoise)
                .baselineOffset(-2)
                .rotationEffect(.degrees(-3))
            if let emoji {
                Text(" " + emoji)
                    .font(.system(size: 32))
            }
        }
    }
}

extension View {
    func y2kDashedBorder(color: Color = Y2K.hotPink, cornerRadius: CGFloat = 20, lineWidth: CGFloat = 2) -> some View {
        modifier(Y2KDashedBorder(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    func y2kSolidBorder(color: Color = Y2K.teal, cornerRadius: CGFloat = 20, lineWidth: CGFloat = 2.5) -> some View {
        modifier(Y2KSolidBorder(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    func y2kCard(cornerRadius: CGFloat = 20) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white.opacity(0.85))
                    .shadow(color: Y2K.hotPink.opacity(0.12), radius: 10, y: 5)
            }
    }
}
