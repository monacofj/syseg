# Standalone Makefile for exported SYSeg examples.

clean check:
	@for d in */; do \
	  test -f "$$d/Makefile" || continue; \
	  $(MAKE) -C "$$d" $@ || exit $$?; \
	done
