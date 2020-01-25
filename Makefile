
tf = terraform

init:
	$(tf) $@

plan:
	$(tf) $@

apply destroy:
	$(tf) $@ --auto-approve


create: apply

delete: destroy
