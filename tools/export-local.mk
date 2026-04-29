# Standalone Makefile exported from SYSeg.

top_srcdir = ..
top_builddir = .
TOOLS_PATH = {{TOOLS_REL}}
{{EXPORT_MAKEFILE_VAR_ASSIGNMENTS}}
MANUAL_BUILD_RULES = {{MANUAL_BUILD_RULES}}
include $(MANUAL_BUILD_RULES)

.PHONY: clean check check-reuse
{{EXPORT_TOOL_INCLUDES}}

clean: clean-local

clean-local: manual-clean

check: check-reuse
	printf 'All tests passed.\n'

check-reuse:
	@cd $(top_srcdir) && { \
	  output=$$(reuse lint 2>&1) && printf 'REUSE compliance ok\n' || \
	  { printf '%s\n' "$$output"; exit 1; }; \
	}
