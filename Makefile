#!/usr/bin/make

SPATCH                  ?= spatch
SPATCH_CMD              ?= $(SPATCH)
BUILD_DIR               ?= ./build/
C_FILE                  ?= output.c
COCCI_FILE              ?= output.cocci
GEN_C_COCCI             ?= ./gen_c.cocci
GEN_COCCI_COCCI         ?= ./gen_cocci.cocci
GEN_C_SP_FLAGS          ?= --in-place
HELPER_SCRIPT           ?= helper.sh
HELPER_CMD              ?= ./$(HELPER_SCRIPT)
ifdef DIR
FILES                   = $(shell find ${DIR} -name "*.c" | tr '\n' ' ')
endif
ifdef NUM
C_FILE                  = ${NUM}.c
COCCI_FILE              = ${NUM}.cocci
endif
ifdef DEBUG
SPATCH_CMD              := ocamldebug $(SPATCH)
GEN_C_SP_FLAGS          := $(GEN_C_SP_FLAGS) --debugger
GEN_COCCI_SP_FLAGS      := $(GEN_COCCI_SP_FLAGS) --debugger
TEST_SP_FLAGS           := $(TEST_SP_FLAGS) --debugger
endif
define C_FILE_TEMPLATE
cocci_test_suite() {
}
endef
export C_FILE_TEMPLATE

all: create_dir c fix_c_bugs cocci

clean:
	rm -rf $(BUILD_DIR)

create_dir:
	mkdir -p $(BUILD_DIR)
	echo "$$C_FILE_TEMPLATE" > $(BUILD_DIR)$(C_FILE) 2>&1

c: create_dir
	$(SPATCH_CMD) --sp-file $(GEN_C_COCCI) $(FILES) \
		$(BUILD_DIR)$(C_FILE) $(GEN_C_SP_FLAGS)

fix_c_bugs:
	$(HELPER_CMD) fix_c_bugs $(BUILD_DIR)$(C_FILE)

cocci:
	$(SPATCH_CMD) --sp-file $(GEN_COCCI_COCCI) $(BUILD_DIR)$(C_FILE) \
		$(GEN_COCCI_SP_FLAGS) > $(BUILD_DIR)$(COCCI_FILE)

test:
	$(SPATCH_CMD) --sp-file $(BUILD_DIR)$(COCCI_FILE) \
		$(BUILD_DIR)$(C_FILE) $(TEST_SP_FLAGS)

.PHONY: all c clean cocci test
