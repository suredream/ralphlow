SHELL := /usr/bin/env bash

DB_FILE  ?= db/tcm_followup.db
MIGRATIONS_DIR := db/migrations

.PHONY: help sync run verify review collect loop check latest db-migrate db-rollback db-reset

help:
	@echo "Available targets:"
	@echo "  make sync        - prepare Ralph input from specs"
	@echo "  make run         - prepare and run Ralph"
	@echo "  make collect     - collect artifacts for latest loop"
	@echo "  make verify      - run verification for latest loop"
	@echo "  make review      - run review for latest loop"
	@echo "  make loop        - run full loop: sync+run+collect+verify+review"
	@echo "  make check       - collect+verify+review without running Ralph"
	@echo "  make latest      - print latest loop id"
	@echo "  make db-migrate  - apply UP migration (creates DB if absent)"
	@echo "  make db-rollback - apply DOWN migration (drops all tables)"
	@echo "  make db-reset    - rollback then migrate (clean slate)"

sync:
	bash scripts/sync_to_ralph.sh

run:
	bash scripts/sync_to_ralph.sh --run

collect:
	bash scripts/collect_artifacts.sh

verify:
	bash scripts/verify.sh

review:
	bash scripts/review.sh

loop:
	bash scripts/sync_to_ralph.sh --run
	bash scripts/collect_artifacts.sh
	bash scripts/verify.sh
	bash scripts/review.sh

check:
	bash scripts/collect_artifacts.sh
	bash scripts/verify.sh
	bash scripts/review.sh

latest:
	@cat artifacts/latest_loop_id

db-migrate:
	@echo ">>> Applying UP migration to $(DB_FILE)"
	sqlite3 $(DB_FILE) < $(MIGRATIONS_DIR)/001_init_schema.sql
	@echo ">>> Migration complete. Tables:"
	sqlite3 $(DB_FILE) ".tables"

db-rollback:
	@echo ">>> Applying DOWN migration to $(DB_FILE)"
	sqlite3 $(DB_FILE) < $(MIGRATIONS_DIR)/001_init_schema_down.sql
	@echo ">>> Rollback complete. Tables:"
	sqlite3 $(DB_FILE) ".tables"

db-reset: db-rollback db-migrate
