#!/usr/bin/make

SPATCH                  = spatch
BUILD_DIR               ?= ./build/
C_FILE                  ?= output.c
COCCI_FILE              ?= output.cocci
C_FILE_TEMPLATE         ?= "cocci_test_suite() {}"
GEN_C_COCCI             ?= ./gen_c.cocci
GEN_COCCI_COCCI         ?= ./gen_cocci.cocci
GEN_C_SP_FLAGS          ?= --in-place
GEN_COCCI_SP_FLAGS      ?=
TEST_SP_FLAGS           ?=
CODEBASE_DIR            ?=
ADD_COMMENTS            ?=
ifdef DIR
FILES                   = $(shell find ${DIR} -name "*.c" | tr '\n' ' ')
endif

all: create_dir c cocci

clean:
	rm -rf $(BUILD_DIR)

create_dir:
	mkdir $(BUILD_DIR)
	echo $(C_FILE_TEMPLATE) > $(BUILD_DIR)$(C_FILE) 2>&1

c: create_dir
	$(SPATCH) --sp-file $(GEN_C_COCCI) $(FILES) \
		$(BUILD_DIR)$(C_FILE) $(GEN_C_SP_FLAGS)

cocci:
	$(SPATCH) --sp-file $(GEN_COCCI_COCCI) $(BUILD_DIR)$(C_FILE) \
		> $(BUILD_DIR)$(COCCI_FILE) $(GEN_COCCI_SP_FLAGS)

test:
	$(SPATCH) --sp-file $(BUILD_DIR)$(COCCI_FILE) \
		$(BUILD_DIR)$(C_FILE) $(TEST_SP_FLAGS)

.PHONY: all c clean cocci test
