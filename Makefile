PLATFORM_IOS = iOS Simulator,name=iPhone 11 Pro Max
PLATFORM_MACOS = macOS
PLATFORM_TVOS = tvOS Simulator,name=Apple TV 4K (at 1080p) (2nd generation)

default: test-all

test-all: test-ios test-macos test-tvos

test-ios:
	xcodebuild test \
		-scheme PostgREST \
		-destination platform="$(PLATFORM_IOS)"

test-macos:
	xcodebuild test \
		-scheme PostgREST \
		-destination platform="$(PLATFORM_MACOS)"

test-tvos:
	xcodebuild test \
		-scheme PostgREST \
		-destination platform="$(PLATFORM_TVOS)"

format:
	swiftformat .

supabase-up: supabase-down
	supabase start && supabase db reset

supabase-down:
	supabase stop

.PHONY: format test-all test-ios test-macos test-tvos
