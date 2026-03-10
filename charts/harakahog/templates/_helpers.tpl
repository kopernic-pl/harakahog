{{/* NAMES */}}

{{/*
Chart full name.
*/}}
{{- define "harakahog.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end }}

{{/*
Haraka full name.
*/}}
{{- define "harakahog.haraka.fullname" -}}
{{- printf "%s-haraka" (include "harakahog.fullname" .) -}}
{{- end }}

{{/*
MailHog full name.
*/}}
{{- define "harakahog.mailhog.fullname" -}}
{{- printf "%s-mailhog" (include "harakahog.fullname" .) -}}
{{- end }}

{{/* LABELS */}}

{{/*
Chart common labels.
*/}}
{{- define "harakahog.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Haraka common labels.
*/}}
{{- define "harakahog.haraka.labels" -}}
app.kubernetes.io/name: {{ include "harakahog.haraka.fullname" . }}
{{- end }}

{{/*
MailHog common labels.
*/}}
{{- define "harakahog.mailhog.labels" -}}
app.kubernetes.io/name: {{ include "harakahog.mailhog.fullname" . }}
{{- end }}

{{/* CONFIGS */}}

{{/*
Relay destination route for the "any" domain.
*/}}
{{- define "harakahog.haraka.relayAnyRoute" -}}
{{- $smtpName := include "harakahog.mailhog.fullname" . -}}
{{- $smtpPort := .Values.mailhog.service.smtpPort -}}
{{- $route := dict "action" "continue" "nexthop" (printf "%s:%v" $smtpName $smtpPort) -}}
{{- $route | toJson -}}
{{- end }}

{{/*
Relay ACL allow list.
*/}}
{{- define "harakahog.haraka.relayAclAllow" -}}
{{- range .Values.haraka.config.auth.relayAcl }}
{{ . }}
{{- end }}
{{- end }}

{{/*
Auth flat file users section.
*/}}
{{- define "harakahog.haraka.authUsers" -}}
{{- range $user, $pass := .Values.haraka.config.auth.users }}
{{ $user }}={{ $pass }}
{{- end }}
{{- end }}
