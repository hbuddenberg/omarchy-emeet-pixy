.PHONY: all test lint validate ci

all: test lint validate

test:
	python3 test/manifest_test.py

lint:
	qmllint BarWidget.qml

validate:
	@if command -v omarchy-plugin-validate >/dev/null 2>&1; then \
		omarchy-plugin-validate .; \
	elif command -v omarchy >/dev/null 2>&1; then \
		omarchy plugin validate .; \
	else \
		echo "omarchy CLI not found, skipping CLI validation"; \
	fi

ci: test lint
