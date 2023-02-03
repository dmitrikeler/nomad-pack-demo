// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .support-services.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .support-services.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .support-services.region "") -]]
region = [[ .support-services.region | quote]]
[[- end -]]
[[- end -]]
