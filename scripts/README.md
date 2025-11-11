# Soleil - Code Signing & Notarization Scripts

This directory contains scripts for building, signing, and notarizing Soleil for macOS distribution.

## 📋 Prerequisites

### Required Software
- **Faust**: `brew install faust`
- **Xcode Command Line Tools**: `xcode-select --install`
- **Apple Developer Account** with Developer ID certificates

### Required Certificates
You need two certificates from your Apple Developer account:

1. **Developer ID Application** certificate (.cer file)
2. **Private key** (.p12 file)

Download these from:
- [Apple Developer Certificates](https://developer.apple.com/account/resources/certificates/list)
- Or export from Xcode Organizer

## 🚀 Quick Start

### Option 1: Automated Build (Recommended)

```bash
# Build, sign, and notarize in one command
./scripts/build-release.sh --notarize
```

### Option 2: Step-by-Step

```bash
# 1. Install certificates (one-time setup)
./scripts/install-certificates.sh

# 2. Build, sign, and notarize
./scripts/build-release.sh --notarize
```

## 📝 Script Reference

### 1. `install-certificates.sh`

Installs Developer ID certificates into your macOS keychain.

```bash
./scripts/install-certificates.sh
```

**What it does:**
- Looks for certificates in `~/Dropbox/_Musique/_Dev/Certificates/` or project root
- Installs `.cer` (certificate) files
- Installs `.p12` (private key) files (will prompt for password)
- Verifies installation

**Required files:**
- `*.cer` - Developer ID Application certificate
- `*.p12` - Private key with certificate

---

### 2. `sign-app.sh`

Signs a Soleil.app bundle with Developer ID.

```bash
# Sign the default app
./scripts/sign-app.sh

# Sign a specific app
./scripts/sign-app.sh --app builds/apps/Soleil_v1.0.app

# Ad-hoc signing for testing (no Developer ID required)
./scripts/sign-app.sh --ad-hoc
```

**Options:**
- `--app PATH` - Path to .app bundle
- `--identity ID` - Code signing identity (default: from Phil project)
- `--ad-hoc` - Use ad-hoc signing for development
- `-h, --help` - Show help

**What it does:**
- Signs the app with Developer ID certificate
- Applies hardened runtime
- Uses Soleil.entitlements for permissions
- Verifies signature validity

**Entitlements included:**
- `com.apple.security.cs.disable-library-validation` - Load audio plugins
- `com.apple.security.cs.allow-jit` - JIT compilation for DSP
- `com.apple.security.cs.allow-unsigned-executable-memory` - Real-time audio processing
- `com.apple.security.device.audio-input` - Microphone access

---

### 3. `notarize.sh`

Submits a signed app to Apple for notarization.

```bash
# Notarize using environment variable
export NOTARIZATION_PASSWORD='your-app-specific-password'
./scripts/notarize.sh

# Notarize using keychain profile (recommended)
./scripts/notarize.sh --profile Soleil-Notarization
```

**Options:**
- `--app PATH` - Path to .app bundle
- `--version VER` - Version string for ZIP filename
- `--profile NAME` - Keychain profile name
- `-h, --help` - Show help

**What it does:**
1. Verifies app is properly signed
2. Creates a ZIP package for submission
3. Submits to Apple notarization service
4. Waits for notarization to complete (2-10 minutes)
5. Staples the notarization ticket to the app

**Setup (one-time):**

**Option 1: Environment Variable** (quick, for testing)
```bash
export NOTARIZATION_PASSWORD='your-app-specific-password'
```

**Option 2: Keychain Profile** (recommended, more secure)
```bash
xcrun notarytool store-credentials Soleil-Notarization \
    --apple-id keegandewitt@gmail.com \
    --team-id G398H44H6X \
    --password <app-specific-password>
```

Get app-specific password: [Apple ID Account](https://appleid.apple.com/account/manage)

---

### 4. `build-release.sh`

Complete automated build pipeline.

```bash
# Build with defaults (sign, no notarize)
./scripts/build-release.sh

# Build, sign, and notarize
./scripts/build-release.sh --notarize

# Build with ad-hoc signing (testing)
./scripts/build-release.sh --ad-hoc

# Build specific version
./scripts/build-release.sh --dsp Soleil_v1.0.dsp --version 1.0

# Build without signing
./scripts/build-release.sh --no-sign
```

**Options:**
- `--dsp FILE` - DSP source file (default: Soleil_v1.1.dsp)
- `--version VER` - Version string (default: 1.1)
- `--builder CMD` - Faust builder command (default: faust2caqt)
- `--no-sign` - Skip code signing
- `--ad-hoc` - Use ad-hoc signing for development
- `--notarize` - Submit to Apple for notarization
- `-h, --help` - Show help

**What it does:**
1. Verifies prerequisites (Faust, certificates)
2. Builds Soleil.app using specified Faust builder
3. Moves app to `builds/apps/`
4. Signs the app (if enabled)
5. Notarizes the app (if enabled)
6. Creates distribution ZIP (if notarizing)

**Available Faust builders:**
- `faust2caqt` - CoreAudio + Qt (default, recommended)
- `faust2jaqt` - JACK + Qt
- `faust2au` - Audio Unit plugin
- `faust2vst` - VST plugin

---

## 🔄 Complete Workflow

### First Time Setup

```bash
# 1. Install certificates
./scripts/install-certificates.sh

# 2. Configure notarization credentials (choose one)

# Option A: Keychain profile (recommended)
xcrun notarytool store-credentials Soleil-Notarization \
    --apple-id keegandewitt@gmail.com \
    --team-id G398H44H6X \
    --password <app-specific-password>

# Option B: Environment variable
echo 'export NOTARIZATION_PASSWORD="your-password"' >> ~/.zshrc
source ~/.zshrc
```

### For Each Release

```bash
# Update version in DSP file if needed
# Then run one command:
./scripts/build-release.sh --notarize --profile Soleil-Notarization

# Or if using environment variable:
./scripts/build-release.sh --notarize
```

### Testing Workflow (No Notarization)

```bash
# Quick build with ad-hoc signing
./scripts/build-release.sh --ad-hoc

# Test the app
open builds/apps/Soleil_v1.1.app
```

---

## 🔍 Troubleshooting

### Certificate Not Found

```bash
# List installed certificates
security find-identity -v -p codesigning

# If empty, install certificates
./scripts/install-certificates.sh
```

### Signing Fails

```bash
# Verify certificate is valid
security find-identity -v -p codesigning | grep "Developer ID"

# Check certificate details
codesign -d -vvv builds/apps/Soleil_v1.1.app
```

### Notarization Fails

```bash
# View recent submissions
xcrun notarytool history --keychain-profile Soleil-Notarization

# Get detailed log for a submission
xcrun notarytool log <SUBMISSION_ID> --keychain-profile Soleil-Notarization
```

### App Shows "Damaged" or "Unidentified Developer"

This usually means:
1. App is not signed → Run `./scripts/sign-app.sh`
2. App is not notarized → Run `./scripts/notarize.sh`
3. Notarization ticket not stapled → Check notarize.sh output

### Verify App Status

```bash
# Check signature
codesign -dvvv builds/apps/Soleil_v1.1.app

# Check notarization staple
xcrun stapler validate builds/apps/Soleil_v1.1.app

# Full verification
spctl -a -vvv builds/apps/Soleil_v1.1.app
```

---

## 📦 Distribution

After successful notarization:

1. **ZIP package** (recommended):
   - Located in `dist/Soleil-v1.1.zip`
   - Ready to distribute to users
   - Users can simply unzip and run

2. **App bundle** (alternative):
   - Located in `builds/apps/Soleil_v1.1.app`
   - Can be distributed directly
   - Users may need to right-click → Open on first launch

---

## 🔐 Security Notes

### Entitlements Explained

The `Soleil.entitlements` file grants specific permissions:

- **disable-library-validation**: Allows loading of unsigned audio plugins/libraries (required for DAW compatibility)
- **allow-jit**: Enables JIT compilation for DSP optimization
- **allow-unsigned-executable-memory**: Required for real-time audio processing
- **audio-input**: Allows microphone/audio interface access

These are **standard for audio applications** and match Phil's configuration.

### Certificate Security

- **Never commit** `.p12` files to git
- **Never share** your private key
- **Use app-specific passwords** for notarization (not your main Apple ID password)
- **Store in keychain profile** rather than environment variables when possible

---

## 📚 References

Based on the Phil project's successful certification setup:
- [Phil Repository](https://github.com/musiquela/Phil)
- [Apple Notarization Guide](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Code Signing Guide](https://developer.apple.com/documentation/xcode/code-signing)

---

## 🎯 Quick Reference

```bash
# Development cycle
./scripts/build-release.sh --ad-hoc

# Beta release (signed, not notarized)
./scripts/build-release.sh

# Production release (signed + notarized)
./scripts/build-release.sh --notarize

# Check signature
codesign -dvvv builds/apps/Soleil_v1.1.app

# Check notarization
xcrun stapler validate builds/apps/Soleil_v1.1.app
```

---

**Last Updated:** 2025-11-10
**License:** BSD
