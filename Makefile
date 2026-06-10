CONTEST ?= $(shell find contests -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort | tail -n 1)
PROBLEM ?=
SRC ?= $(if $(PROBLEM),contests/$(CONTEST)/$(PROBLEM).cpp,Main.cpp)
INPUT ?=
OUT ?= a.out
BIN_DIR ?= .cache/bin
EFFECTIVE_INPUT = $(if $(INPUT),$(INPUT),$(wildcard contests/$(CONTEST)/sample/$(PROBLEM).txt))

.PHONY: build run problem-run setup clean path a b c d e f g ex

path:
	@echo SRC=$(SRC)
	@echo INPUT=$(EFFECTIVE_INPUT)

build:
	@./scripts/compile.sh "$(SRC)" "$(OUT)"

run:
	@./scripts/run.sh "$(SRC)" "$(INPUT)"

problem-run: $(OUT)
	@if [ -n "$(EFFECTIVE_INPUT)" ]; then "./$(OUT)" < "$(EFFECTIVE_INPUT)"; else "./$(OUT)"; fi

$(OUT): $(SRC)
	@mkdir -p "$(dir $(OUT))"
	@./scripts/compile.sh "$(SRC)" "$(OUT)"

a b c d e f g ex:
	@$(MAKE) --no-print-directory problem-run PROBLEM=$@ SRC=contests/$(CONTEST)/$@.cpp OUT=$(BIN_DIR)/$(CONTEST)_$@.out

setup:
	@./scripts/setup-linux.sh

clean:
	@rm -rf "$(BIN_DIR)" "$(OUT)"
