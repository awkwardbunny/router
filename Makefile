.PHONY: default

TIME=$(shell /bin/date +"%Y%m%d_%H%M%s")

default:
	@echo "Choose one of the following:"
	@echo "  init"
	@echo "  list_rules"
	@echo "  add_rule"
	@echo "  delete_rule"
	@echo "  clear_logs"

init:
	@echo "Writing log to file logs/init.log.$(TIME)"
	@./scripts/init.sh 2>&1 | tee logs/init.log.$(TIME)

clear_logs:
	@rm -rf logs/*
