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

.PHONY: all export bundle clean-export clean-bundle



clean-export:
	@set -eu; \
	test -n "$(DEST)" || { printf 'set DEST=/path/to/export\n' >&2; exit 1; }; \
	export_root="$(DEST)"; \
	export_name="$(notdir $(CURDIR))"; \
	rm -rf "$$export_root/README.md" "$$export_root/$(EXPORT_SUBDIR)" "$$export_root/$$export_name.tar" "$$export_root/$$export_name.tar.gz"

clean-bundle: clean-export

export: $(EXPORT_FILES) $(MANUAL_BUILD_RULES)
	@set -eu; \
	test -n "$(DEST)" || { printf 'set DEST=/path/to/export\n' >&2; exit 1; }; \
	export_root="$(DEST)"; \
	export_dir="$$export_root/$(EXPORT_SUBDIR)"; \
	tools_dir="$$export_root/tools"; \
	tools_rel=$$(printf '%s\n' "$(EXPORT_SUBDIR)" | awk -F/ '{for (i = 1; i <= NF; i++) printf "../"; print "tools"}'); \
	export_readme_template="$(top_srcdir)/tools/export-notes.md"; \
	export_reuse_note_args="--drop-reuse-header --reuse-args-only --reuse-arg=--contributor --reuse-arg=SYSeg --reuse-arg=-t --reuse-arg=export"; \
	export_reuse_spdx_args="--reuse-arg=-t --reuse-arg=default --reuse-arg=--no-replace"; \
	rm -rf "$$export_dir"; \
	rm -rf "$$tools_dir"; \
	mkdir -p "$$export_dir" "$$tools_dir"; \
	project_name=$$(basename "$$export_root"); \
	PROJECT_NAME="$$project_name" perl -0pe 's/\{\{PROJECT\}\}/$$ENV{PROJECT_NAME}/g' "$$export_readme_template" > "$$export_root/README.md"; \
	: "Add provenance first; the SPDX pass uses --no-replace so it lands above it."; \
	$(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$export_root/README.md"; \
	$(TOOLS_PATH)/prepfile $$export_reuse_spdx_args --root "$(top_srcdir)" "$$export_root/README.md"; \
	for file in $(MANUAL_BUILD_RULES) $(EXPORT_FILES); do \
	  out="$$export_dir/$$file"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  cp "$$file" "$$out"; \
	  $(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$out"; \
	  $(TOOLS_PATH)/prepfile $$export_reuse_spdx_args --root "$(top_srcdir)" "$$out"; \
	done; \
	for file in $(EXPORT_NEW_FILES); do \
	  out="$$export_dir/$$file"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  $(TOOLS_PATH)/prepfile -n --root "$(top_srcdir)" "$$out"; \
	done; \
	for tool in $(filter-out $(EXPORT_FILES_COPY_ONLY),$(EXPORT_TOOLS)); do \
	  src="$(top_srcdir)/tools/$$tool"; \
	  out="$$tools_dir/$$tool"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  cp "$$src" "$$out"; \
	  $(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$out"; \
	  $(TOOLS_PATH)/prepfile $$export_reuse_spdx_args --root "$(top_srcdir)" "$$out"; \
	done; \
	for tool in $(EXPORT_FILES_COPY_ONLY); do \
	  src="$(top_srcdir)/tools/$$tool"; \
	  out="$$tools_dir/$$tool"; \
	  mkdir -p "$$(dirname "$$out")"; \
	  cp "$$src" "$$out"; \
	done; \
	{ \
	  printf '# Standalone Makefile exported from SYSeg.\n\n'; \
	  printf 'top_srcdir = ..\n'; \
	  printf 'top_builddir = .\n'; \
	  printf 'TOOLS_PATH = %s\n' "$$tools_rel"; \
	  $(foreach var,$(EXPORT_MAKEFILE_VARS),printf '%s = %s\n' '$(var)' '$($(var))';) \
	  printf 'MANUAL_BUILD_RULES = %s\n' "$(MANUAL_BUILD_RULES)"; \
	  printf 'include $$(MANUAL_BUILD_RULES)\n'; \
	  if test -n "$(filter %.mk,$(EXPORT_TOOLS))"; then \
	    printf '\n# Convenience rules exported with this example.\n'; \
	    for tool in $(filter %.mk,$(EXPORT_TOOLS)); do \
	      printf 'include $$(TOOLS_PATH)/%s\n' "$$tool"; \
	    done; \
	  fi; \
	  printf '\nclean-local: manual-clean\n'; \
	} > "$$export_dir/Makefile"; \
	$(TOOLS_PATH)/prepfile $$export_reuse_note_args --root "$(top_srcdir)" "$$export_dir/Makefile"; \
	$(TOOLS_PATH)/prepfile $$export_reuse_spdx_args --root "$(top_srcdir)" "$$export_dir/Makefile"; \
	rm -f "$$export_root/$(notdir $(CURDIR)).tar.gz"; \
	$(AMTAR) -C "$$export_root" -cf "$$export_root/$(notdir $(CURDIR)).tar" README.md tools "$(EXPORT_SUBDIR)"; \
	printf 'Exported archive: %s\n' "$$export_root/$(notdir $(CURDIR)).tar"

bundle: export
