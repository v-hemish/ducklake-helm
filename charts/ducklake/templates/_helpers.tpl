{{- define "ducklake.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ducklake.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "ducklake.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "ducklake.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "ducklake.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ducklake.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "ducklake.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ducklake.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "ducklake.postgresHost" -}}
{{- if .Values.catalog.external.enabled -}}
{{- .Values.catalog.external.host -}}
{{- else -}}
{{- printf "%s-postgresql" (include "ducklake.fullname" .) -}}
{{- end -}}
{{- end }}

{{- define "ducklake.postgresSecretName" -}}
{{- if .Values.catalog.external.enabled -}}
{{- .Values.catalog.external.existingSecret -}}
{{- else -}}
{{- printf "%s-postgresql" (include "ducklake.fullname" .) -}}
{{- end -}}
{{- end }}

{{- define "ducklake.s3Endpoint" -}}
{{- if .Values.rustfs.enabled -}}
{{- printf "%s-rustfs:9000" (include "ducklake.fullname" .) -}}
{{- else -}}
{{- .Values.externalS3.endpoint -}}
{{- end -}}
{{- end }}

{{- define "ducklake.s3UseSSL" -}}
{{- if .Values.rustfs.enabled -}}false{{- else -}}{{ .Values.externalS3.useSSL }}{{- end -}}
{{- end }}

{{- define "ducklake.s3URLStyle" -}}
{{- if .Values.rustfs.enabled -}}path{{- else -}}{{ .Values.externalS3.urlStyle }}{{- end -}}
{{- end }}

{{- define "ducklake.s3SecretName" -}}
{{- if .Values.rustfs.enabled -}}
{{- printf "%s-rustfs" (include "ducklake.fullname" .) -}}
{{- else if .Values.externalS3.existingSecret -}}
{{- .Values.externalS3.existingSecret -}}
{{- else -}}
{{- printf "%s-external-s3" (include "ducklake.fullname" .) -}}
{{- end -}}
{{- end }}

{{- define "ducklake.dataPath" -}}
s3://{{ .Values.storage.bucket }}/{{ trimAll "/" .Values.storage.prefix }}/
{{- end }}

{{- define "ducklake.s3AccessKeyField" -}}
{{- if .Values.rustfs.enabled -}}access-key{{- else if .Values.externalS3.existingSecret -}}{{ .Values.externalS3.accessKeySecretKey }}{{- else -}}access-key{{- end -}}
{{- end }}

{{- define "ducklake.s3SecretKeyField" -}}
{{- if .Values.rustfs.enabled -}}secret-key{{- else if .Values.externalS3.existingSecret -}}{{ .Values.externalS3.secretKeySecretKey }}{{- else -}}secret-key{{- end -}}
{{- end }}
