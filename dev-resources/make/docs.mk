DOCS_DIR = $(ROOT_DIR)/docs
DOCS_BUILD_DIR = $(DOCS_DIR)/build
DOCS_PROD_DIR = $(DOCS_DIR)/build
CURRENT = $(DOCS_PROD_DIR)
DOCS_GIT_HACK = $(DOCS_DIR)/.git
LOCAL_DOCS_HOST = localhost
LOCAL_DOCS_PORT = 5099

docs: clean-docs local-docs

$(DOCS_GIT_HACK):
	-@ln -s $(ROOT_DIR)/.git $(DOCS_DIR)

clean-docs:
	@rm -rf $(CURRENT)

pre-docs:
	@echo "\nBuilding docs ...\n"

clojure-docs:
	@lein codox

local-docs: pre-docs clojure-docs



devdocs: docs
	@echo "\nRunning docs server on http://$(LOCAL_DOCS_HOST):$(LOCAL_DOCS_PORT)..."
	@lein simpleton $(LOCAL_DOCS_PORT) file :from $(CURRENT)

prod-docs: clean-docs $(DOCS_GIT_HACK) local-docs

setup-temp-repo: $(DOCS_GIT_HACK)
	@echo "\nSetting up temporary git repos for gh-pages ...\n"
	@rm -rf $(DOCS_PROD_DIR)/.git $(DOCS_PROD_DIR)/*/.git
	@cd $(DOCS_PROD_DIR) && git init
	@cd $(DOCS_PROD_DIR) && git add * > /dev/null
	@cd $(DOCS_PROD_DIR) && git commit -a -m "Generated content." > /dev/null

teardown-temp-repo:
	@echo "\nTearing down temporary gh-pages repos ..."
	@rm $(DOCS_DIR)/.git
	@rm -rf $(DOCS_PROD_DIR)/.git $(DOCS_PROD_DIR)/*/.git

publish-docs: prod-docs setup-temp-repo
	@echo "\nPublishing docs ...\n"
	@cd $(DOCS_PROD_DIR) && git push -f $(REPO) master:gh-pages
	@make teardown-temp-repo

.PHONY: docs
