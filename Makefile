CURRENT_CONTEST_FILE ?= .atcoder-current
DEBUG_FILE ?= .atcoder-debug
DEFAULT_CONTEST = $(shell if [ -s "$(CURRENT_CONTEST_FILE)" ]; then tr -d '[:space:]' < "$(CURRENT_CONTEST_FILE)"; else find contests -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -n 1; fi)
CONTEST ?= $(DEFAULT_CONTEST)
PROBLEM ?=
SRC ?= $(if $(PROBLEM),contests/$(CONTEST)/$(PROBLEM).cpp,Main.cpp)
INPUT ?=
BIN_DIR ?= .cache/bin
DEBUG_SUFFIX = $(if $(wildcard $(DEBUG_FILE)),_debug,)
OUT ?= $(if $(PROBLEM),$(BIN_DIR)/$(CONTEST)_$(PROBLEM)$(DEBUG_SUFFIX).out,a.out)
SAMPLE_INPUTS = $(sort $(wildcard contests/$(CONTEST)/sample/$(PROBLEM)_*.in))
EFFECTIVE_INPUT = $(if $(INPUT),$(INPUT),$(firstword $(SAMPLE_INPUTS)))
SAMPLE_URL = $(if $(URL),$(URL),$(if $(PROBLEM),https://atcoder.jp/contests/$(CONTEST)/tasks/$(CONTEST)_$(PROBLEM),https://atcoder.jp/contests/$(CONTEST)/tasks))
ENV_NAME ?= atcoder-cpp23
ENV_PREFIX ?= .micromamba/envs/$(ENV_NAME)
ENV_PYTHON = $(ENV_PREFIX)/bin/python3
PROBLEMS ?= a b c d e f g
COOKIE_FILE ?= .atcoder-cookie
DEBUG_FLAGS = $(if $(wildcard $(DEBUG_FILE)),-DLOCAL,)
DEBUG_STATUS = $(if $(wildcard $(DEBUG_FILE)),on,off)

.PHONY: build run problem-run sample sample-test test create init use current debug debug-on debug-off debug-toggle setup clean path a b c d e f g ex

path:
	@echo CONTEST=$(CONTEST)
	@echo DEBUG=$(DEBUG_STATUS)
	@echo SRC=$(SRC)
	@echo OUT=$(OUT)
	@echo INPUT=$(EFFECTIVE_INPUT)
	@echo SAMPLES=$(SAMPLE_INPUTS)

build:
	@ATCODER_EXTRA_FLAGS="$(DEBUG_FLAGS) $(ATCODER_EXTRA_FLAGS)" ./scripts/compile.sh "$(SRC)" "$(OUT)"

run:
	@ATCODER_EXTRA_FLAGS="$(DEBUG_FLAGS) $(ATCODER_EXTRA_FLAGS)" ./scripts/run.sh "$(SRC)" "$(INPUT)"

sample:
	@if [ ! -x "$(ENV_PYTHON)" ]; then echo "missing $(ENV_PYTHON). Run .\\scripts\\setup-wsl.ps1 first."; exit 1; fi
	@"$(ENV_PYTHON)" scripts/download-atcoder-samples.py --cookie-file "$(COOKIE_FILE)" "$(SAMPLE_URL)"

create init:
	@mkdir -p "contests/$(CONTEST)" "contests/$(CONTEST)/sample"
	@for problem in $(PROBLEMS); do \
		path="contests/$(CONTEST)/$$problem.cpp"; \
		if [ -e "$$path" ]; then \
			echo "exists $$path"; \
		else \
			printf 'import std;\n\n#ifdef LOCAL\n#define debug(x) std::cerr << #x << " = " << (x) << '"'"'\\n'"'"'\n#else\n#define debug(x)\n#endif\n\nint main() {\n}\n' > "$$path"; \
			echo "created $$path"; \
		fi; \
	done
	@printf '%s\n' "$(CONTEST)" > "$(CURRENT_CONTEST_FILE)"
	@echo "current contest: $(CONTEST)"

use:
	@if [ -z "$(CONTEST)" ]; then echo "missing CONTEST"; exit 1; fi
	@if [ ! -d "contests/$(CONTEST)" ]; then echo "missing contest: contests/$(CONTEST). Run .\\m create $(CONTEST) first."; exit 1; fi
	@printf '%s\n' "$(CONTEST)" > "$(CURRENT_CONTEST_FILE)"
	@echo "current contest: $(CONTEST)"

current:
	@echo "$(CONTEST)"

debug:
	@echo "debug: $(DEBUG_STATUS)"

debug-on:
	@printf 'on\n' > "$(DEBUG_FILE)"
	@echo "debug: on (-DLOCAL)"

debug-off:
	@rm -f "$(DEBUG_FILE)"
	@echo "debug: off"

debug-toggle:
	@if [ -f "$(DEBUG_FILE)" ]; then \
		rm -f "$(DEBUG_FILE)"; \
		echo "debug: off"; \
	else \
		printf 'on\n' > "$(DEBUG_FILE)"; \
		echo "debug: on (-DLOCAL)"; \
	fi

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
	@ATCODER_EXTRA_FLAGS="$(DEBUG_FLAGS) $(ATCODER_EXTRA_FLAGS)" ./scripts/compile.sh "$(SRC)" "$(OUT)"

a b c d e f g ex:
	@$(MAKE) --no-print-directory problem-run PROBLEM=$@ SRC=contests/$(CONTEST)/$@.cpp OUT=$(BIN_DIR)/$(CONTEST)_$@$(DEBUG_SUFFIX).out

setup:
	@./scripts/setup-linux.sh

clean:
	@rm -rf "$(BIN_DIR)" "$(OUT)"
