CONTEST ?= $(shell find contests -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -n 1)
PROBLEM ?=
SRC ?= $(if $(PROBLEM),contests/$(CONTEST)/$(PROBLEM).cpp,Main.cpp)
INPUT ?=
BIN_DIR ?= .cache/bin
OUT ?= $(if $(PROBLEM),$(BIN_DIR)/$(CONTEST)_$(PROBLEM).out,a.out)
SAMPLE_INPUTS = $(sort $(wildcard contests/$(CONTEST)/sample/$(PROBLEM)_*.in))
EFFECTIVE_INPUT = $(if $(INPUT),$(INPUT),$(firstword $(SAMPLE_INPUTS)))
SAMPLE_URL = $(if $(URL),$(URL),$(if $(PROBLEM),https://atcoder.jp/contests/$(CONTEST)/tasks/$(CONTEST)_$(PROBLEM),https://atcoder.jp/contests/$(CONTEST)/tasks))
ENV_NAME ?= atcoder-cpp23
ENV_PREFIX ?= .micromamba/envs/$(ENV_NAME)
ENV_PYTHON = $(ENV_PREFIX)/bin/python3

.PHONY: build run problem-run sample sample-test test setup clean path a b c d e f g ex

path:
	@echo SRC=$(SRC)
	@echo OUT=$(OUT)
	@echo INPUT=$(EFFECTIVE_INPUT)
	@echo SAMPLES=$(SAMPLE_INPUTS)

build:
	@./scripts/compile.sh "$(SRC)" "$(OUT)"

run:
	@./scripts/run.sh "$(SRC)" "$(INPUT)"

sample:
	@if [ ! -x "$(ENV_PYTHON)" ]; then echo "missing $(ENV_PYTHON). Run .\\scripts\\setup-wsl.ps1 first."; exit 1; fi
	@"$(ENV_PYTHON)" scripts/download-atcoder-samples.py "$(SAMPLE_URL)"

problem-run: $(OUT)
	@if [ -n "$(EFFECTIVE_INPUT)" ]; then "./$(OUT)" < "$(EFFECTIVE_INPUT)"; else "./$(OUT)"; fi

sample-test test: $(OUT)
	@set -e; \
	samples="$(SAMPLE_INPUTS)"; \
	if [ -z "$$samples" ]; then echo "no samples: contests/$(CONTEST)/sample/$(PROBLEM)_*.in"; exit 1; fi; \
	mkdir -p .cache; \
	for input in $$samples; do \
		expected="$${input%.in}.out"; \
		actual=".cache/$$(basename "$${input%.in}").actual"; \
		if [ ! -f "$$expected" ]; then echo "missing expected output: $$expected"; exit 1; fi; \
		"./$(OUT)" < "$$input" > "$$actual"; \
		if diff -u "$$expected" "$$actual" >/dev/null; then \
			echo "AC $$input"; \
		else \
			echo "WA $$input"; \
			diff -u "$$expected" "$$actual"; \
			exit 1; \
		fi; \
	done

$(OUT): $(SRC)
	@mkdir -p "$(dir $(OUT))"
	@./scripts/compile.sh "$(SRC)" "$(OUT)"

a b c d e f g ex:
	@$(MAKE) --no-print-directory problem-run PROBLEM=$@ SRC=contests/$(CONTEST)/$@.cpp OUT=$(BIN_DIR)/$(CONTEST)_$@.out

setup:
	@./scripts/setup-linux.sh

clean:
	@rm -rf "$(BIN_DIR)" "$(OUT)"
