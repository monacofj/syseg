# SPDX-FileCopyrightText: 2026 Monaco F. J. <https://github.com/monacofj>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This file is part of SYSeg (https://github.com/monacofj/syseg)

## Boilerplate for Makefile.am files in directories that contain code examples
## meant to be built manually rather than through Automake's usual build rules.
## Include this file from Makefile.am to provide the common manual-build setup
## and then keep example-specific rules in the local build.mk file.


all:
	@printf "Examples in this directory must be built manually and individually\n"

# Build rules specifics to the example in this directory.
# This file is included by generated Makefiles at make time, so it must use
# make variables already defined there instead of raw configure substitutions.
include $(MANUAL_BUILD_RULES)


##
## Export rules.
##


DEST ?=
EXPORT_SUBDIR ?= $(notdir $(CURDIR))
EXPORT_FILES ?=
EXPORT_NEW_FILES ?=

## Common export groups used by example directories.

BINTOOLS ?= bintools.mk mbr-fat32.S mbr-fat32.ld vbr-fat32.ld csmwrapia32.efi csmwrapx64.efi

PREPFILES ?= prepfile prepfile-templates/config

EXPORT_TOOLS = $(PREPFILES)
EXPORT_FILES_COPY_ONLY ?= csmwrapia32.efi csmwrapx64.efi

## Explicit list of files from $(top_srcdir)/tools to export with this example.
EXPORT_MAKEFILE_VARS ?= CC MAKE AS LD AR OBJCOPY OBJDUMP CFLAGS CPPFLAGS LDFLAGS

.PHONY: all export export-tools bundle clean-export clean-bundle



clean-export:
	@set -eu; \
	test -n "$(DEST)" || { printf 'set DEST=/path/to/export\n' >&2; exit 1; }; \
	export_root="$(DEST)"; \
	export_name="$(notdir $(CURDIR))"; \
	rm -rf "$$export_root/$(EXPORT_SUBDIR)" "$$export_root/$$export_name.tar" "$$export_root/$$export_name.tar.gz"

clean-bundle: clean-export

export-tools:
	@set -eu; \
	test -n "$(DEST)" || { printf 'set DEST=/path/to/export\n' >&2; exit 1; }; \
	tools_dir="$(DEST)/tools"; \
	export_reuse_note_args="--drop-reuse-header --reuse-args-only --reuse-arg=--contributor --reuse-arg=SYSeg --reuse-arg=-t --reuse-arg=export"; \
	export_reuse_spdx_args="--reuse-arg=--no-replace"; \
	annotate() { \
	  year_args=$$(sed -n 's/.*SPDX-FileCopyrightText:[[:space:]]*\([0-9][0-9][0-9][0-9][0-9,-]*\).*/--copyright-year=\1/p' "$$1"); \
	  $(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$1" >/dev/null && \
	  if test -n "$$year_args"; then \
	    $(TOOLS_PATH)/prepfile $$year_args $$export_reuse_spdx_args --root "$(top_srcdir)" "$$1" >/dev/null; \
	  else \
	    $(TOOLS_PATH)/prepfile --first-year $$export_reuse_spdx_args --root "$(top_srcdir)" "$$1" >/dev/null; \
	  fi; \
	}; \
	mkdir -p "$$tools_dir"; \
	for tool in $(filter-out $(EXPORT_FILES_COPY_ONLY),$(EXPORT_TOOLS)); do \
	  src="$(top_srcdir)/tools/$$tool"; \
	  out="$$tools_dir/$$tool"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  if test ! -e "$$out" || test "$$src" -nt "$$out"; then \
	    printf 'exporting %s\n' "$$out"; \
	    cp "$$src" "$$out"; \
	    annotate "$$out"; \
	  fi; \
	done; \
	for tool in $(EXPORT_FILES_COPY_ONLY); do \
	  src="$(top_srcdir)/tools/$$tool"; \
	  out="$$tools_dir/$$tool"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  if test ! -e "$$out" || test "$$src" -nt "$$out"; then \
	    printf 'exporting %s\n' "$$out"; \
	    cp "$$src" "$$out"; \
	  fi; \
	done

export: $(EXPORT_FILES) $(MANUAL_BUILD_RULES) export-tools
	@set -eu; \
	test -n "$(DEST)" || { printf 'set DEST=/path/to/export\n' >&2; exit 1; }; \
	export_root="$(DEST)"; \
	export_dir="$$export_root/$(EXPORT_SUBDIR)"; \
	tools_rel=$$(printf '%s\n' "$(EXPORT_SUBDIR)" | awk -F/ '{for (i = 1; i <= NF; i++) printf "../"; print "tools"}'); \
	export_readme_template="$(top_srcdir)/tools/export-notes.md"; \
	export_root_makefile_template="$(top_srcdir)/tools/export-root.mk"; \
	export_local_makefile_template="$(top_srcdir)/tools/export-local.mk"; \
	export_reuse_template="$(top_srcdir)/tools/export-reuse.toml"; \
	export_reuse_note_args="--drop-reuse-header --reuse-args-only --reuse-arg=--contributor --reuse-arg=SYSeg --reuse-arg=-t --reuse-arg=export"; \
	export_reuse_spdx_args="--reuse-arg=--no-replace"; \
	annotate() { \
	  year_args=$$(sed -n 's/.*SPDX-FileCopyrightText:[[:space:]]*\([0-9][0-9][0-9][0-9][0-9,-]*\).*/--copyright-year=\1/p' "$$1"); \
	  $(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$1" >/dev/null && \
	  if test -n "$$year_args"; then \
	    $(TOOLS_PATH)/prepfile $$year_args $$export_reuse_spdx_args --root "$(top_srcdir)" "$$1" >/dev/null; \
	  else \
	    $(TOOLS_PATH)/prepfile --first-year $$export_reuse_spdx_args --root "$(top_srcdir)" "$$1" >/dev/null; \
	  fi; \
	}; \
	rm -f "$$export_root/$(notdir $(CURDIR)).tar" "$$export_root/$(notdir $(CURDIR)).tar.gz"; \
	rm -rf "$$export_dir"; \
	mkdir -p "$$export_dir"; \
	if test ! -e "$$export_root/README.md"; then \
	  printf 'exporting %s\n' "$$export_root/README.md"; \
	  project_name=$$(basename "$$export_root"); \
	  PROJECT_NAME="$$project_name" perl -0pe 's/\{\{PROJECT\}\}/$$ENV{PROJECT_NAME}/g' "$$export_readme_template" > "$$export_root/README.md"; \
	  annotate "$$export_root/README.md"; \
	fi; \
	if test ! -e "$$export_root/Makefile"; then \
	  printf 'exporting %s\n' "$$export_root/Makefile"; \
	  cp "$$export_root_makefile_template" "$$export_root/Makefile"; \
	  annotate "$$export_root/Makefile"; \
	fi; \
	if test ! -e "$$export_root/REUSE.toml"; then \
	  printf 'exporting %s\n' "$$export_root/REUSE.toml"; \
	  copy_only_paths=$$(for file in $(EXPORT_FILES_COPY_ONLY); do printf '  "tools/%s",\n' "$$file"; done); \
	  EXPORT_COPY_ONLY_PATHS="$$copy_only_paths" perl -0pe 's/\{\{EXPORT_COPY_ONLY_PATHS\}\}/$$ENV{EXPORT_COPY_ONLY_PATHS}/g' "$$export_reuse_template" > "$$export_root/REUSE.toml"; \
	fi; \
	: "Add provenance first; the SPDX pass uses --no-replace so it lands above it."; \
	for file in $(MANUAL_BUILD_RULES) $(EXPORT_FILES); do \
	  out="$$export_dir/$$file"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  printf 'exporting %s\n' "$$out"; \
	  cp "$$file" "$$out"; \
	  annotate "$$out"; \
	done; \
	for file in $(EXPORT_NEW_FILES); do \
	  out="$$export_dir/$$file"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  printf 'exporting %s\n' "$$out"; \
	  $(TOOLS_PATH)/prepfile -n --root "$(top_srcdir)" "$$out" >/dev/null; \
	done; \
	var_assignments=$$($(foreach var,$(EXPORT_MAKEFILE_VARS),printf '%s = %s\n' '$(var)' '$($(var))';)); \
	tool_includes=$$(if test -n "$(filter %.mk,$(EXPORT_TOOLS))"; then printf '\n# Convenience rules exported with this example.\n'; for tool in $(filter %.mk,$(EXPORT_TOOLS)); do printf 'include $$(TOOLS_PATH)/%s\n' "$$tool"; done; printf '\n'; fi); \
	TOOLS_REL="$$tools_rel" \
	EXPORT_MAKEFILE_VAR_ASSIGNMENTS="$$var_assignments" \
	MANUAL_BUILD_RULES_VALUE="$(MANUAL_BUILD_RULES)" \
	EXPORT_TOOL_INCLUDES="$$tool_includes" \
	  perl -0pe 's/\{\{TOOLS_REL\}\}/$$ENV{TOOLS_REL}/g; s/\{\{EXPORT_MAKEFILE_VAR_ASSIGNMENTS\}\}/$$ENV{EXPORT_MAKEFILE_VAR_ASSIGNMENTS}/g; s/\{\{MANUAL_BUILD_RULES\}\}/$$ENV{MANUAL_BUILD_RULES_VALUE}/g; s/\{\{EXPORT_TOOL_INCLUDES\}\}/$$ENV{EXPORT_TOOL_INCLUDES}/g' "$$export_local_makefile_template" > "$$export_dir/Makefile"; \
	printf 'exporting %s\n' "$$export_dir/Makefile"; \
	annotate "$$export_dir/Makefile"; \
	(cd "$$export_root" && reuse download --all); \
	printf 'Exported directory: %s\n' "$$export_dir"

bundle: export
