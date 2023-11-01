SLIDE_FILES=$(patsubst %/README.md, %/slides.html, $(shell find . -name "README.md" -not -path "./README.md" -not -path "./bin/README.md"))
DIAGRAM_FILES=$(addsuffix .lock, $(shell find . -name diagrams))
UML_FILES=$(patsubst %.plantuml, %.svg, $(shell find . -name "*.plantuml"))

SLIDES=bin/slides.sh
DIAGRAMS=bin/diagrams.sh
BROWSERREFRESH=bin/browserrefresh
PLANTUML?=plantuml

all: $(SLIDE_FILES) $(DIAGRAM_FILES) $(UML_FILES) reload.lock

reload.lock: $(SLIDE_FILES) $(DIAGRAM_FILES) $(UML_FILES)
	$(BROWSERREFRESH)
	touch $@

$(SLIDE_FILES): %/slides.html : %/README.md $(SLIDES)
	$(SLIDES) $< $@

$(DIAGRAM_FILES): %.lock : % $(DIAGRAMS)
	$(DIAGRAMS) $<
	touch $@

$(UML_FILES): %.svg : %.plantuml
	$(PLANTUML) -tsvg $^

clean:
	rm $(DIAGRAM_FILES)
