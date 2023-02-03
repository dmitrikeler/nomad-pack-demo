// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .apache.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .apache.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .apache.region "") -]]
region = [[ .apache.region | quote]]
[[- end -]]
[[- end -]]
