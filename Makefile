SHELL := /usr/bin/env bash -euo pipefail -c

ytt: ytt-mgmt ytt-workload

ytt-mgmt: ytt-mgmt-auth-infra ytt-mgmt-auth-config

ytt-workload: ytt-workload-auth-infra ytt-workload-auth-config

install-mgmt-cluster-key:
	kubectl create secret generic \
		-n flux-system age-key \
		--from-file config/mgmt/mgmt.agekey \
		--dry-run=client -oyaml | kubectl apply -f-

ytt-mgmt-auth-infra:
	bash -euo pipefail -c ' \
		cd config/mgmt/ \
		; rm -rf auth-infra/* || true \
		; source .envrc \
		; ytt \
			--data-values-file <(sops --decrypt mgmt.dex.yttvalues.yaml) \
			-f ../../carvel/__ytt_lib/pinniped-supervisor \
			-f ../../carvel/__ytt_lib/pinniped-concierge \
			-f ../../carvel/__ytt_lib/dex \
			-f ../../carvel/overlays/pinniped-supervisor-http \
			-f ../../carvel/overlays/dex \
			--output-files auth-infra/ \
		; find auth-infra/ -type f -exec sops --encrypt --in-place {} \; \
	'

ytt-mgmt-auth-config:
	bash -euo pipefail -c ' \
		cd config/mgmt/ \
		; rm -rf auth-config/* || true \
		; source .envrc \
		; ytt \
			--data-values-file <(sops --decrypt mgmt.pinniped.yttvalues.yaml) \
			-f ../../carvel/overlays/pinniped-supervisor \
			-f ../../carvel/overlays/pinniped-concierge \
			--output-files auth-config/ \
		; find auth-config/ -type f -exec sops --encrypt --in-place {} \; \
	'

ytt-workload-auth-infra:
	bash -euo pipefail -c ' \
		cd config/workload/ \
		; rm -rf auth-infra/* || true \
		; ytt \
			-f ../../carvel/__ytt_lib/pinniped-concierge \
			--output-files auth-infra/ \
	'

ytt-workload-auth-config:
	bash -euo pipefail -c ' \
		cd config/workload/ \
		; rm -rf auth-config/* || true \
		; ytt \
			--data-values-file workload.concierge.yttvalues.yaml \
			-f ../../carvel/overlays/pinniped-concierge \
			--output-files auth-config/ \
	'
