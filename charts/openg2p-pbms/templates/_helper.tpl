{{/*
Overriding Odoo's templates. All the variable names here match ones in Odoo's
values.yaml, not this chart's values.yaml. The templates here will be available
to Odoo's chart.
*/}}

{{- define "odoo.databaseHost" -}}
{{- tpl .Values.externalDatabase.host . -}}
{{- end -}}

{{- define "odoo.databaseName" -}}
{{- tpl .Values.externalDatabase.database . -}}
{{- end -}}

{{- define "odoo.databaseUser" -}}
{{- tpl .Values.externalDatabase.user . -}}
{{- end -}}

{{- define "odoo.databaseSecretPasswordKey" -}}
{{- tpl .Values.externalDatabase.existingSecretPasswordKey . -}}
{{- end -}}

{{- define "odoo.databaseSecretName" -}}
{{- tpl .Values.externalDatabase.existingSecret . -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "pbms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "pbms.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "pbms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "pbms.labels" -}}
helm.sh/chart: {{ include "pbms.chart" . }}
{{ include "pbms.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "pbms.selectorLabels" -}}
app.kubernetes.io/name: {{ include "pbms.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render Env values section
*/}}
{{- define "pbms.baseEnvVars" -}}
{{- $context := .context -}}
{{- range $k, $v := .envVars }}
{{- if or (kindIs "int64" $v) (kindIs "float64" $v) (kindIs "bool" $v) }}
- name: {{ $k }}
  value: {{ $v | quote }}
{{- else if kindIs "string" $v }}
- name: {{ $k }}
  value: {{ include "common.tplvalues.render" ( dict "value" $v "context" $context ) | squote }}
{{- else }}
{{- $vEnabled := "true" }}
{{- if hasKey $v "enabled" }}
{{- $vEnabled = kindIs "bool" $v.enabled | ternary ($v.enabled | squote) (include "common.tplvalues.render" (dict "value" $v.enabled "context" $context)) }}
{{- $v = omit $v "enabled" }}
{{- end }}
{{- if eq $vEnabled "true" }}
- name: {{ $k }}
  valueFrom: {{- include "common.tplvalues.render" ( dict "value" $v "context" $context ) | nindent 4}}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
