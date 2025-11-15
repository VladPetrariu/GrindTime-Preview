import SwiftUI
import AVFoundation
import QuartzCore   // CACurrentMediaTime()

private enum CapturePhase: String {
    case startWorkspace = "Workspace Start"
    case startSelfie    = "Selfie Start"
    case endWorkspace   = "Workspace End"
    case endSelfie      = "Selfie End"
}

struct ContentView: View {
    // ---- Timer model (accumulation-based) ----
    @State private var isRunning = false
    @State private var startTick: CFTimeInterval = 0
    @State private var accumulated: TimeInterval = 0
    @State private var frozenElapsed: TimeInterval = 0
    @State private var preStopElapsed: TimeInterval = 0
    @State private var isPaused = false

    // ---- Camera ----
    @StateObject private var camera = CameraController()
    @State private var showCamera = false
    @State private var phase: CapturePhase?

    // Start-timer deferral to avoid sheet-dismiss hitch
    @State private var shouldStartTimerAfterDismiss = false

    // Debounce photo callbacks
    @State private var lastHandledCaptureAt = Date.distantPast

    // Captured images (in-memory only for preview)
    @State private var wsStart: Data?
    @State private var sfStart: Data?
    @State private var wsEnd: Data?
    @State private var sfEnd: Data?

    // Recent sessions UI (local only)
    @State private var lastSessions: [String] = []

    // ---- UI sizing (lock widths/heights) ----
    private let mainButtonWidth: CGFloat = 170
    private let mainButtonHeight: CGFloat = 56
    private let splitButtonWidth: CGFloat = 170
    private let splitButtonHeight: CGFloat = 56
    private let splitButtonCorner: CGFloat = 16
    private let rowSpacing: CGFloat = 14
    private let restartHeight: CGFloat = 34

    private var actionAreaHeight: CGFloat {
        splitButtonHeight + 8 + restartHeight
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Text(isRunning ? "Locked in" : (isPaused ? "Paused" : "Lock in"))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.top, 20)
                        .padding(.leading, 20)
                    Spacer()
                    VStack(alignment: .trailing) {
                        ForEach(lastSessions.prefix(3), id: \.self) { s in
                            Text(s)
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }

                Spacer(minLength: 0)

                // Smooth live timer
                TimelineView(.animation) { _ in
                    let now = CACurrentMediaTime()
                    let inEndFlow = (phase == .endWorkspace || phase == .endSelfie)
                    let elapsed = isRunning
                        ? accumulated + (now - startTick)
                        : (inEndFlow ? frozenElapsed : accumulated)

                    Text(formatTime(elapsed))
                        .font(.system(size: 50, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.bottom, 6)
                }

                // ======= ACTION AREA (fixed height, top-aligned per state) =======
                ZStack(alignment: .top) {
                    // Running state
                    VStack(spacing: 8) {
                        HStack(spacing: rowSpacing) {
                            Button(action: pauseTapped) {
                                Text("Pause")
                                    .font(.title3.weight(.semibold))
                                    .frame(width: splitButtonWidth, height: splitButtonHeight)
                            }
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: splitButtonCorner, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: splitButtonCorner, style: .continuous))

                            Button(action: stopTapped) {
                                Text("Stop")
                                    .font(.title3.weight(.semibold))
                                    .frame(width: splitButtonWidth, height: splitButtonHeight)
                            }
                            .background(Color.white)
                            .foregroundStyle(.black)
                            .clipShape(RoundedRectangle(cornerRadius: splitButtonCorner, style: .continuous))
                            .contentShape(RoundedRectangle(cornerRadius: splitButtonCorner, style: .continuous))
                        }

                        Button(action: restartSession) {
                            Text("Restart Session")
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(height: restartHeight)
                        }
                        .background(Color.white.opacity(0.15))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                    }
                    .opacity(isRunning ? 1 : 0)
                    .allowsHitTesting(isRunning)
                    .frame(maxWidth: .infinity, alignment: .top)

                    // Paused state
                    VStack(spacing: 8) {
                        Button(action: startOrResumeTapped) {
                            Text("Resume")
                                .font(.title2)
                                .frame(width: mainButtonWidth, height: mainButtonHeight)
                        }
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .cornerRadius(20)
                        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Button(action: restartSession) {
                            Text("Restart Session")
                                .font(.callout.weight(.semibold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(height: restartHeight)
                        }
                        .background(Color.white.opacity(0.15))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                    }
                    .opacity(isPaused && !isRunning ? 1 : 0)
                    .allowsHitTesting(isPaused && !isRunning)
                    .frame(maxWidth: .infinity, alignment: .top)

                    // Idle state
                    VStack(spacing: 8) {
                        Button(action: startOrResumeTapped) {
                            Text("Start")
                                .font(.title2)
                                .frame(width: mainButtonWidth, height: mainButtonHeight)
                        }
                        .background(Color.white)
                        .foregroundStyle(.black)
                        .cornerRadius(20)
                        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                        Color.clear
                            .frame(height: restartHeight)
                            .allowsHitTesting(false)
                    }
                    .opacity((!isRunning && !isPaused) ? 1 : 0)
                    .allowsHitTesting((!isRunning && !isPaused))
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(height: actionAreaHeight)
                .padding(.horizontal, 20)
                // ================================================================

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .onAppear {
            camera.onPhotoCaptured = { image in handlePhoto(image) }
        }
        .task(id: showCamera) {
            if !showCamera && shouldStartTimerAfterDismiss {
                shouldStartTimerAfterDismiss = false
                try? await Task.sleep(nanoseconds: 350_000_000)
                actuallyStartTimer()
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(
                controller: camera,
                title: phase?.rawValue ?? "Camera",
                onCancel: { cancelCamera() },
                onCapture: { camera.capturePhoto() }
            )
        }
    }

    // MARK: - Start / Resume / Pause / Stop / Restart

    private func startOrResumeTapped() {
        if accumulated > 0 && isPaused {
            // RESUME
            isPaused = false
            startTick = CACurrentMediaTime()
            isRunning = true
        } else if accumulated == 0 {
            // New session → capture start photos first
            wsStart = nil; sfStart = nil; wsEnd = nil; sfEnd = nil
            frozenElapsed = 0
            phase = .startWorkspace
            ensureBack()
            showCamera = true
        } else {
            // Edge: just resume
            startTick = CACurrentMediaTime()
            isRunning = true
        }
    }

    private func pauseTapped() {
        guard isRunning else { return }
        let now = CACurrentMediaTime()
        accumulated += (now - startTick)
        isRunning = false
        isPaused = true
    }

    private func stopTapped() {
        if isRunning {
            let now = CACurrentMediaTime()
            preStopElapsed = accumulated + (now - startTick)
            frozenElapsed = preStopElapsed
            isRunning = false
            isPaused = false
        }
        phase = .endWorkspace
        ensureBack()
        showCamera = true
    }

    private func restartSession() {
        showCamera = false
        phase = nil
        wsStart = nil; sfStart = nil; wsEnd = nil; sfEnd = nil
        isRunning = false
        isPaused = false
        accumulated = 0
        frozenElapsed = 0
        preStopElapsed = 0
        camera.resetBackDefaults()
    }

    private func actuallyStartTimer() {
        accumulated = 0
        startTick = CACurrentMediaTime()
        isRunning = true
        isPaused = false
    }

    // MARK: - Image downscale helper

    // [2025-11-14] Simple UIKit downscale helper for preview.
    private func downscale(_ image: UIImage, maxDimension: CGFloat = 900) -> UIImage {
        let size = image.size
        let maxSide = max(size.width, size.height)

        guard maxSide > maxDimension else { return image }

        let scale = maxDimension / maxSide
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    // MARK: - Photo handling (debounced, local only)

    private func handlePhoto(_ image: UIImage) {
        let now = Date()
        guard now.timeIntervalSince(lastHandledCaptureAt) > 0.25 else { return }
        lastHandledCaptureAt = now

        guard let p = phase else { return }

        let downsized = downscale(image, maxDimension: 900)
        guard let data = downsized.jpegData(compressionQuality: 0.5) else { return }

        switch p {
        case .startWorkspace:
            wsStart = data
            phase = .startSelfie
            ensureFront()

        case .startSelfie:
            sfStart = data
            shouldStartTimerAfterDismiss = true
            showCamera = false
            phase = nil

        case .endWorkspace:
            wsEnd = data
            phase = .endSelfie
            ensureFront()

        case .endSelfie:
            sfEnd = data
            showCamera = false
            phase = nil
            saveSession()
        }
    }

    // MARK: - Camera helpers and Cancel behavior

    private func ensureBack()  { if camera.isUsingFrontCamera { camera.switchCamera() } }
    private func ensureFront() { if !camera.isUsingFrontCamera { camera.switchCamera() } }

    private func cancelCamera() {
        if phase == .endWorkspace || phase == .endSelfie {
            // Resume the same session
            showCamera = false
            phase = nil
            accumulated = preStopElapsed
            startTick = CACurrentMediaTime()
            isRunning = true
            isPaused = false
            wsEnd = nil; sfEnd = nil
        } else {
            // Cancel during start flow -> remain idle
            showCamera = false
            phase = nil
            camera.resetBackDefaults()
        }
    }

    // MARK: - Save (preview-only, no persistence)

    private func saveSession() {
        let duration = frozenElapsed

        // UI-only: prepend last session string
        let sessionString = formatTime(duration)
        withAnimation(.easeOut(duration: 0.3)) {
            lastSessions.insert(sessionString, at: 0)
            if lastSessions.count > 3 {
                lastSessions = Array(lastSessions.prefix(3))
            }
        }

        // NOTE:
        // In the full app, this is where Core Data + backend sync happen.
        // For the public preview, all persistence has been removed.

        // Clear images and timer state for next run
        wsStart = nil; sfStart = nil; wsEnd = nil; sfEnd = nil
        isRunning = false
        isPaused = false
        accumulated = 0
        frozenElapsed = 0
        preStopElapsed = 0
        camera.resetBackDefaults()
    }

    // MARK: - Utils

    private func formatTime(_ t: TimeInterval) -> String {
        let m  = Int(t) / 60
        let s  = Int(t) % 60
        let cs = Int((t.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", m, s, cs)
    }
}
