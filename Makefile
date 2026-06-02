# tency — build shortcuts
# Override the simulator with:  make run SIM="iPhone 16 Pro"

SCHEME  := Tency
BUNDLE  := com.divs.tency
SIM     := iPhone 17 Pro
DERIVED := build
APP      = $(DERIVED)/Build/Products/Debug-iphonesimulator/Tency.app

.PHONY: gen build run boot lint fmt clean reset help

help:
	@echo "gen    - regenerate Xcode project from project.yml"
	@echo "build  - build for the simulator"
	@echo "run    - build + install + launch on booted sim"
	@echo "boot   - boot the simulator named in SIM"
	@echo "lint   - swiftlint --strict"
	@echo "fmt    - swift-format in place"
	@echo "clean  - remove local DerivedData"
	@echo "reset  - clean + regenerate project"

gen:
	xcodegen generate

build: gen
	set -o pipefail && xcodebuild \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=$(SIM)' \
		-derivedDataPath $(DERIVED) \
		build | xcbeautify

boot:
	@xcrun simctl boot "$(SIM)" 2>/dev/null || true
	@open -a Simulator

run: build boot
	xcrun simctl install booted "$(APP)"
	xcrun simctl launch booted $(BUNDLE)

lint:
	swiftlint --strict

fmt:
	xcrun swift-format format --in-place --recursive Tency TencyShared Tests

clean:
	rm -rf $(DERIVED)
	rm -rf ~/Library/Developer/Xcode/DerivedData/Tency-*

reset: clean gen
