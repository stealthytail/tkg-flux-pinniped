SHELL := /usr/bin/env bash -euo pipefail -c

ytt: ytt-mgmt ytt-workload

bootstrap: terraform install-mgmt-cluster-key
	kubectl delete namespace cert-manager || true
	flux bootstrap github \
		--token-auth \
		--owner stealthytail \
		--repository tce-flux-pinniped \
		--path clusters/mgmt/

terraform:
	cd ./tf-kiam && terraform apply

install-mgmt-cluster-key:
	kubectl create namespace flux-system \
		--dry-run=client -oyaml | kubectl apply -f-
	kubectl create secret generic \
		-n flux-system age-key \
		--from-file config/mgmt/mgmt.agekey \
		--dry-run=client -oyaml | kubectl apply -f-

ytt-mgmt:
	bash -euo pipefail -c ' \
		cd config/mgmt/ \
		; rm -rf build/ || true \
		; source .envrc \
		; ytt \
			--data-values-file <(sops --decrypt yttvalues.yaml) \
			-f ../../carvel/_upstream \
			-f ../../carvel/patches \
			--output-files build/ \
		; find build/ -type f -exec sops --encrypt --in-place {} \; \
	'

ytt-workload:
	bash -euo pipefail -c ' \
		cd config/workload/ \
		; rm -rf build/ || true \
		; ytt \
			--data-values-file yttvalues.yaml \
			-f ../../carvel/_upstream \
			-f ../../carvel/patches \
			--file-mark 'auth-infra/pinniped-concierge/**/*:exclusive-for-output=true' \
			--file-mark 'auth-config/pinniped-concierge/**/*:exclusive-for-output=true' \
			--output-files build/ \
	'
