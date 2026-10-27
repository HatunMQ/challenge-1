import SwiftUI

enum AppScreen {
    case home
    case time
    case breath
    case drawing
}

struct RootView: View {

    @State private var screen: AppScreen = .home
    @State private var duration = 300
    @State private var showLayers = false

    var body: some View {
        ZStack {
            switch screen {
            case .home:
                HomePlaceholder(onStart: {
                    screen = .time
                })
                .transition(.opacity)

            case .time:
                BreakCardView(
                    onSkip: {
                        screen = .drawing
                    },
                    onTakeBreak: { minutes in
                        duration = minutes * 60
                        screen = .breath
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Image(.back)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }
                .transition(.opacity)

            case .breath:
                Deep_Breath(duration: duration, onSkip: {
                    screen = .drawing
                })
                .transition(.opacity)

            case .drawing:
                DrawingView(
                    onClose: {
                        screen = .home
                    },
                    onLayers: {
                        showLayers = true
                    },
                    onAddImage: {
                    }
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: screen)
        .sheet(isPresented: $showLayers) {
            LayersPlaceholder()
        }
    }
}

struct HomePlaceholder: View {

    var onStart: () -> Void = {}

    var body: some View {
        ZStack {
            Color(red: 0.965, green: 0.937, blue: 0.910).ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Home")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.black)

                Button("Start") {
                    onStart()
                }
                .font(.system(size: 22))
                .foregroundColor(.black)
            }
        }
    }
}

struct LayersPlaceholder: View {
    var body: some View {
        Text("Layers")
            .font(.system(size: 32, weight: .bold))
    }
}

#Preview {
    RootView()
}
