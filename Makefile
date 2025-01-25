PYTHON_VERSIONS = 3.10 3.11

.PHONY: all install-uv install-deps test coverage show-failed-tests upload-results clean

all: $(addprefix test-pyversion-, $(PYTHON_VERSIONS))

install-uv:
	@echo "Installing the latest version of uv..."
	@python -c "import sys; print(f'Using Python {sys.version.split()[0]}')" # Just to check python version
	# Assuming setup-uv is a script or can be installed via pip, otherwise replace with actual installation command
	# For this example, we'll assume it's not necessary in Makefile context

install-deps:
	@echo "Installing dependencies..."
	npm install -g @mermaid-js/mermaid-cli
	# Assuming 'uvx' and '-p' flag works as described, adjust according to your tool's real usage
	for pyv in $(PYTHON_VERSIONS); do \
		uvx -p $$pyv --with-editable .[test,rag,search-ddg] playwright install --with-deps || exit 1; \
	done

test-pyversion-%:
	@echo "Testing with Python $*..."
	export ALLOW_OPENAI_API_CALL=0 && \
	mkdir -p ~/.metagpt && cp tests/config2.yaml ~/.metagpt/config2.yaml && \
	uvx -p $* --with-editable .[test,rag,search-ddg] pytest | tee unittest.txt.$*

coverage-pyversion-%:
	@echo "Showing coverage report for Python $*..."
	uvx -p $* --with-editable .[test,rag,search-ddg] coverage report -m

show-failed-tests-pyversion-%:
	@echo "Showing failed tests and overall summary for Python $*..."
	grep -E "FAILED tests|ERROR tests|[0-9]+ passed," unittest.txt.$*
	failed_count=$$(grep -E "FAILED tests|ERROR tests" unittest.txt.$* | wc -l | tr -d '[:space:]'); \
	if [ "$$failed_count" -gt 0 ]; then \
		echo "$$failed_count failed lines found! Task failed."; \
		exit 1; \
	fi

upload-results-pyversion-%:
	@echo "Uploading pytest test results for Python $*..."
	# Since uploading artifacts is specific to GitHub Actions, you might want to use another method for local or other CI environments
	# This step is left here for completeness but will need adjustment based on your environment

clean:
	rm -f unittest.txt.*

all: install-deps $(foreach ver,$(PYTHON_VERSIONS),test-pyversion-$(ver) coverage-pyversion-$(ver) show-failed-tests-pyversion-$(ver))