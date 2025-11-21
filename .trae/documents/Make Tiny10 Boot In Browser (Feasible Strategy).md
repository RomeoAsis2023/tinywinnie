## Reality Check
- v86 runs many x86 OSes fully in-browser (Windows 1/3.x/95/98/NT/2000) but does not support modern Windows versions. Windows 10/Tiny10 expects ACPI/devices/driver stacks that v86 doesn’t implement.
- JSLinux and similar WASM emulators have the same limitation; they’re designed for DOS/Linux and very early Windows, not Windows 10.

## Research Findings
- v86 officially lists Windows 95/98/NT/2000 as supported; Windows 2000 boots in the public demo.
- Booting Tiny10 (Windows 10 x86) inside a browser-only emulator is not supported by current, production-grade WASM emulators.

## Goal-Aligned Strategy
- Keep Tiny10 as the OS the user interacts with.
- Achieve a working Windows session in the browser reliably.

## Plan A: Maximize In‑Browser v86 Path (no server)
1. Harden v86 startup and remove any implicit optional loads that generate `GET /undefined`.
2. Improve asset checks and boot progress logs, confirm ISO assembly, and pass Tiny10 ISO via `cdrom`.
3. Verify in Github Pages that all assets under `/tinywinnie/build/*` and `/tinywinnie/iso/*` load (200) and that v86 emits readiness/boot events.
4. Outcome: Page auto-starts emulator with Tiny10 ISO. If Tiny10 cannot complete boot (expected), display a precise diagnostic message indicating emulator limitation.

## Plan B: Make Tiny10 Usable In Browser (remote stream, still on index.html)
1. Integrate a client-only viewer that connects to a Windows 10 host via secure WebRTC/WebSocket from the page.
2. Controls: start/stop/fullscreen; pass-through keyboard/mouse; optional clipboard.
3. Endpoint configuration: environment variable or query parameter for `wss://` remote gateway (e.g., websockify/Guacamole/RDP bridge). No backend hosted in GitHub Pages; you provide an endpoint.
4. Outcome: Users visit `https://romeoasis2023.github.io/tinywinnie/` and immediately use Tiny10 in the browser, with rendering/inputs streamed from a real Tiny10 VM.

## Implementation Details
- Code: Keep current auto-assembly and v86 boot path; add a simple remote viewer path as the primary experience when an endpoint is configured, fall back to v86 auto-boot otherwise.
- UX: Single page, Tiny10 branding; auto-start; progress bar; fullscreen.
- Security: `wss://` required; no mixed content; no secrets in repo.

## GitHub Pages Integration
1. Publish all assets (`build/*`, `iso/**/*`, `index.html`) on `main`.
2. Use relative paths so `/tinywinnie/...` resolves correctly.
3. Confirm deployment propagation; verify assets fetch successfully.

## Verification
- Local: run static server, assert assets fetched, emulator events, and remote viewer connectivity.
- Pages: open `/tinywinnie/`, ensure immediate usability via remote viewer when configured; confirm v86 path shows diagnostic if Tiny10 cannot boot.

## Deliverables
- Updated `index.html` with hardening and remote viewer integration.
- Pushed changes to GitHub; verified Pages works.
- Documentation in code comments for configuring remote endpoint.

## Request for Confirmation
- Confirm whether to proceed with Plan B (remote viewer for real Tiny10) while retaining the in‑browser v86 path for completeness. This is the only strategy that guarantees Tiny10 working in the browser today.