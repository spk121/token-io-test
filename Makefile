# Makefile for iotest
# Copyright (C) 2010 Michael L. Gran
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.


## EDIT ME: choose a target
# target = guile-1.8
target = guile-2.0
# target = mzscheme-4.1
# target = mit-gnu-scheme-9.0

## default parameters
ifeq ($(target), guile-1.8)
cmd = guile -s
utf_8 = 0
test_r6rs = 1
test_unicode = 0
endif

ifeq ($(target), guile-2.0)
cmd = guile -s
utf_8 = 1
test_r6rs = 1
test_unicode = 1
endif

ifeq ($(target), mzscheme-4.1)
cmd = mzscheme -f
utf_8 = 1
test_r6rs = 1
test_unicode = 1
endif

ifeq ($(target), mit-gnu-scheme-9.0)
utf_8 = 0
test_r6rs = 1
test_unicode = 0
endif

iotest.scm: gen-iotest.in
	m4 -P --define=TARGET=$(target) \
	--define=UTF_8=$(utf_8) \
	--define=TEST_R6RS=$(test_r6rs) \
	--define=TEST_UNICODE=$(test_unicode) \
	gen-iotest.in > iotest.scm
