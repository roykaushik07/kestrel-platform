{{- define "kestrel-service.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kestrel-service.labels" -}}
app.kubernetes.io/name: {{ include "kestrel-service.name" . }}
app.kubernetes.io/version: {{ .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kestrel-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kestrel-service.name" . }}
{{- end -}}
