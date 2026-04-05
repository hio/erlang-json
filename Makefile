# This file is part of eep0018 released under the MIT license. 
# See the LICENSE file for more information.

top_builddir := `pwd`

PACKAGE_VERNAME=enif_json-0.0.3

ERL=erl
DIALYZER=dialyzer
DIALYZER_FLAGS=
erl_lib_dir := $(shell $(ERL) -noinput -eval 'io:format("~s",[code:lib_dir()]), init:stop()')

INSTALL = install
INSTALL_UIDGID = -o root -g root
#DESTDIR =

.PHONY: doc

%.beam: %.erl
	erlc -o test/ $<

all:
	@mkdir -p ebin
	./rebar compile

check: test/etap.beam test/util.beam
	ERL_FLAGS="-pa ./ebin" JSON_NIF_DIR=$(top_builddir)/priv \
	  ./rebar eunit
	ERL_FLAGS="-pa ./ebin" JSON_NIF_DIR=$(top_builddir)/priv \
	  prove test/*.t
	$(DIALYZER) $(DIALYZER_FLAGS) --build_plt --output_plt enif_json.plt ebin/enif_json.beam >enif_json.log 2>&1 || { e=$$?; cat enif_json.log; exit $$e; }

clean:
	./rebar clean
	rm -f test/*.beam enif_json.plt enif_json.log

doc:
	./rebar doc

install:
	for d in ebin priv doc/html; do \
		$(INSTALL) $(INSTALL_UIDGID) -d $(DESTDIR)$(erl_lib_dir)/$(PACKAGE_VERNAME)/$$d || exit $$?; \
		for f in $$d/*; do \
			$(INSTALL) $(INSTALL_UIDGID) $$f $(DESTDIR)$(erl_lib_dir)/$(PACKAGE_VERNAME)/$$f || exit $$?; \
		done \
	done
	for f in LICENSE; do \
		$(INSTALL) $(INSTALL_UIDGID) $$f $(DESTDIR)$(erl_lib_dir)/$(PACKAGE_VERNAME)/$$f || exit $$?; \
	done
