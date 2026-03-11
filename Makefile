# config
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
.SECONDARY:
.NOTPARALLEL:

ONT := trans
OBO := http://purl.obolibrary.org/obo/
EDIT := src/ontology/$(ONT)-edit.owl

# Set the software version(s) to use
ROBOT_VRS = 1.9.5

# ***NEVER run make commands in parallel (do NOT use the -j flag)***

# to make a release, use `make release`
# to run QC tests on *-edit.owl, use `make test`

# Release process:
# 1. Build product(s)
# 2. Validate syntax of OBO-format products with fastobo-validator
# 3. Verify logical structure of products with SPARQL queries
# 4. Generate post-build reports (counts, etc.)

.PHONY: release all
release: test products verify post
	@echo "Release complete!"

all: release

.PHONY: FORCE
FORCE:


##########################################
## SETUP
##########################################

.PHONY: clean
clean:
	rm -rf build

build build/update build/reports build/reports/temp build/translations:
	mkdir -p $@

# ----------------------------------------
# ROBOT
# ----------------------------------------

# ROBOT is automatically updated
ROBOT := java -jar build/robot.jar

.PHONY: check_robot
check_robot:
	@if [[ -f build/robot.jar ]]; then \
		VRS=$$($(ROBOT) --version) ; \
		if [[ "$$VRS" != *"$(ROBOT_VRS)"* ]]; then \
			printf "\e[1;37mUpdating\e[0m from $$VRS to $(ROBOT_VRS)...\n" ; \
			rm -rf build/robot.jar && $(MAKE) build/robot.jar ; \
		fi ; \
	else \
		echo "Downloading ROBOT version $(ROBOT_VRS)..." ; \
		$(MAKE) build/robot.jar ; \
	fi

build/robot.jar: | build
	@curl -L -o $@ https://github.com/ontodev/robot/releases/download/v$(ROBOT_VRS)/robot.jar


##########################################
## CI TESTS & DIFF
##########################################

.PHONY: ci_test report reason verify-edit

# Continuous Integration (CI) testing
ci_test: reason report verify-edit
	@echo ""

test: ci_test diff

# Report for general issues on *-edit
report: build/reports/report-obo.tsv build/reports/report.tsv

.PRECIOUS: build/reports/report-obo.tsv build/reports/report.tsv
build/reports/report-obo.tsv: $(EDIT) | check_robot build/reports
	@echo -e "\n## OBO dashboard QC report\nFull report at $@"
	@$(ROBOT) report \
	 --input $< \
	 --labels true \
	 --output $@

build/reports/report.tsv: $(EDIT) src/sparql/report/report_profile.txt | check_robot build/reports
	@echo -e "\n## ${ONT}-edit QC report\nFull report at $@"
	@$(ROBOT) report \
	 --input $< \
	 --profile $(word 2,$^) \
	 --labels true \
	 --output $@

# Simple reasoning test
reason: build/$(ONT)-edit-reasoned.owl

build/$(ONT)-edit-reasoned.owl: $(EDIT) | check_robot build
	@$(ROBOT) reason \
	 --input $< \
	 --create-new-ontology false \
	 --annotate-inferred-axioms false \
	 --exclude-duplicate-axioms true \
	 --output $@
	@echo -e "\n## Reasoning completed successfully!"

# Verify *-edit.owl
EDIT_V_QUERIES := $(wildcard src/sparql/verify/edit-verify-*.rq src/sparql/verify/verify-*.rq)

.PRECIOUS: build/reports/edit-verify.csv
verify-edit: build/reports/edit-verify.csv
build/reports/edit-verify.csv: $(EDIT) | check_robot build/reports/temp
	@python3 src/util/clean_existing_csv.py $(word 2,$|) edit-verify-*.csv verify-*.csv
	@$(ROBOT) verify \
	 --input $< \
	 --queries $(EDIT_V_QUERIES) \
	 --fail-on-violation false \
	 --output-dir $(word 2,$|)
	@python3 src/util/concat_csv.py TEST $@ $(word 2,$|) edit-verify-*.csv verify-*.csv

# ----------------------------------------
# DIFF
# ----------------------------------------

.PHONY: diff
diff: build/reports/diff.tsv

# Get the last release of $(ONT).owl (only if newer available)
build/$(ONT)-last.version: FORCE | build
	@LATEST=$$(curl -sL "http://purl.obolibrary.org/obo/$(ONT).owl" | \
				sed -n '/owl:versionIRI/p;/owl:versionIRI/q' | \
				sed -E 's/.*"([^"]+)".*/\1/') ; \
	 if [[ -f $@ ]]; then \
		SRC_VERS=$$(sed '1q' $@) ; \
		if [[ $${SRC_VERS} != $${LATEST} ]]; then \
			echo $${LATEST} > $@ ; \
		fi ; \
	 else \
		echo $${LATEST} > $@ ; \
	 fi

build/$(ONT)-last.owl: build/$(ONT)-last.version
	@echo "Downloading latest release to $@..."
	@curl -sL http://purl.obolibrary.org/obo/$(ONT).owl -o $@

build/$(ONT)-new.owl: build/$(ONT)-edit-reasoned.owl \
  src/sparql/build/add_en_tag.ru | check_robot ci_test
	@$(ROBOT) query \
	 --input $< \
	 --update $(word 2,$^) \
	 --output $@

build/reports/diff.tsv: build/$(ONT)-last.owl build/$(ONT)-new.owl | check_robot \
  build/reports/temp
	@$(ROBOT) export \
	 --input $< \
	 --header "ID|owl:deprecated|LABEL|SYNONYMS|IAO:0000115|SubClass Of [ID NAMED]|Equivalent Class|SubClass Of [ANON]|oboInOwl:hasDbXref|skos:exactMatch|skos:closeMatch|skos:broadMatch|skos:narrowMatch|skos:relatedMatch|oboInOwl:hasAlternativeId|oboInOwl:inSubset" \
	 --export build/reports/temp/$(notdir $(basename $<)).tsv
	@$(ROBOT) export \
	 --input $(word 2,$^) \
	 --header "ID|owl:deprecated|LABEL|SYNONYMS|IAO:0000115|SubClass Of [ID NAMED]|Equivalent Class|SubClass Of [ANON]|oboInOwl:hasDbXref|skos:exactMatch|skos:closeMatch|skos:broadMatch|skos:narrowMatch|skos:relatedMatch|oboInOwl:hasAlternativeId|oboInOwl:inSubset" \
	 --export build/reports/temp/$(notdir $(basename $(word 2,$^))).tsv
	@python3 src/util/diff-re.py \
	 -1 build/reports/temp/$(notdir $(basename $<)).tsv \
	 -2 build/reports/temp/$(notdir $(basename $(word 2,$^))).tsv \
	 -o $@
	@echo "Generated diff report at $@"


##########################################
## RELEASE PRODUCTS
##########################################

REL_DIR := src/ontology
PRIMARY = $(REL_DIR)/$(ONT)

.PHONY: products
products: primary

# release vars
TS = $(shell date +'%d:%m:%Y %H:%M')
DATE := $(shell date +'%Y-%m-%d')
RELEASE_PREFIX := $(OBO)$(ONT)/releases/$(DATE)/

# ----------------------------------------
# RELEASE PRODUCTS
# ----------------------------------------

.PHONY: primary
primary: $(PRIMARY).owl

$(PRIMARY).owl: build/$(ONT)-new.owl | check_robot
	@$(ROBOT) annotate \
	 --input $< \
	 --version-iri "$(RELEASE_PREFIX)$(notdir $@)" \
	 --annotation oboInOwl:date "$(TS)" \
	 --annotation owl:versionInfo "$(DATE)" \
	 --output $@
	@echo "Created $@"


##########################################
## VERIFY build products
##########################################

.PHONY: verify
verify: $(PRIMARY).owl
	@echo ""
	@$(ROBOT) reason -i $< && echo -e "## $< check passed!"


##########################################
## POST-BUILD REPORT
##########################################

# Count classes, imports, and logical defs from old and new
.PHONY: post last-reports new-reports
post: build/reports/branch-count.tsv last-reports new-reports

# all report queries
QUERIES := $(wildcard src/sparql/build/*-report.rq)

# target names for previous release reports
LAST_REPORTS := $(foreach Q,$(QUERIES), build/reports/$(basename $(notdir $(Q)))-last.tsv)
last-reports: $(LAST_REPORTS)
build/reports/%-last.tsv: src/sparql/build/%.rq build/$(ONT)-last.owl | check_robot build/reports
	@echo "Counting: $(notdir $(basename $@))"
	@$(ROBOT) query \
	 --input $(word 2,$^) \
	 --query $< $@

# target names for current release reports
NEW_REPORTS := $(foreach Q,$(QUERIES), build/reports/$(basename $(notdir $(Q)))-new.tsv)
new-reports: $(NEW_REPORTS)
build/reports/%-new.tsv: src/sparql/build/%.rq $(PRIMARY).owl | check_robot build/reports
	@echo "Counting: $(notdir $(basename $@))"
	@$(ROBOT) query \
	 --input $(word 2,$^) \
	 --query $< $@

# create a count of asserted and total (asserted + inferred) classes in each branch
branch_reports := build/reports/temp/branch-count-asserted.tsv \
  build/reports/temp/branch-count-total.tsv
.INTERMEDIATE: $(branch_reports)
build/reports/temp/branch-count-asserted.tsv: $(EDIT) src/sparql/build/branch-count.rq | \
  check_robot build/reports/temp
	@echo "Counting all branches in $<..."
	@$(ROBOT) query \
	 --input $< \
	 --query $(word 2,$^) $@

build/reports/temp/branch-count-total.tsv: $(PRIMARY).owl \
  src/sparql/build/branch-count.rq | check_robot build/reports/temp
	@echo "Counting all branches in $<..."
	@$(ROBOT) query \
	 --input $< \
	 --query $(word 2,$^) $@

build/reports/branch-count.tsv: $(branch_reports)
	@join -t $$'\t' -o $$'\t' <(sed '/^?/d' $< | sort -k1) <(sed '/^?/d' $(word 2,$^) | sort -k1) > $@
	@awk 'BEGIN{ FS=OFS="\t" ; print "branch\tasserted\tinferred\ttotal" } \
	 {print $$1, $$2, $$3-$$2, $$3}' $@ > $@.tmp && mv $@.tmp $@
	@echo "Branch counts available at $@"
