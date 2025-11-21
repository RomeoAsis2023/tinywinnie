## Constraints & Facts
- Tiny10 (Windows 10) does not boot in browser-only emulators like v86/JSLinux; those support Windows up to 2000/9x.
- GitHub Pages is static; no backend can be hosted there. Any working Windows 10 session in the browser must be streamed from a real Tiny10 VM over a secure gateway.

## Goal-Aligned Approach
- Provide a Tiny10 session immediately on visiting `index.html` by integrating a client-side remote desktop viewer.
- Keep a minimal local emulator path only for ISO assembly/logging, but do not present other OSes.

## Implementation Plan
### 1) Remote Tiny10 Viewer Integration
- Add a client-only viewer (noVNC) to `index.html` that connects to a Tiny10 VM via `wss://` WebSocket gateway.
- Auto-connect on page load using one of:
  - Query params: `?remote=wss://host:port/path&pass=...`
  - Or a `config.json` in the repo with `{ "remote": "wss://...", "pass": "..." }`.
- Show fullscreen, keyboard/mouse passthrough, status, and progress.

### 2) Fallback & Messaging
- If remote endpoint is missing/unreachable, show a clear message: “Remote Tiny10 not configured. Set ?remote=... or config.json.”
- Keep the v86 ISO assembly logic internally for diagnostics only, do not advertise another OS.

### 3) Hardening & UX
- Remove/guard any undefined resource loads that cause 404 noise.
- Ensure status transitions (Connecting → Connected/Disconnected) and friendly error messages.
- Pre-warm audio on user gesture; avoid autoplay warnings.

### 4) GitHub Pages Deployment
- Use relative paths so `/tinywinnie/...` works.
- Commit and push `index.html` and optional `config.json`.
- Verify on `https://romeoasis2023.github.io/tinywinnie/` that it auto-connects and shows Tiny10.

### 5) Verification
- Local: static server run, confirm viewer renders and controls work with a test endpoint.
- Pages: open the URL, verify auto-connect, fullscreen, and input handling.

## Deliverables
- Updated `index.html` with integrated remote viewer and auto-connect.
- Optional `config.json` format for endpoint configuration.
- Pushed changes and verified on GitHub Pages.

## Needed From You
- Provide a `wss://` gateway to your Tiny10 VM (websockify/noVNC proxy, Guacamole, or vendor gateway) so we can set it as default. If preferred, I will wire the viewer to read `config.json` and make it connect automatically.

## Confirmation
- If you confirm, I will implement these changes, push to GitHub, and verify the live Pages site until Tiny10 is usable right in the browser.