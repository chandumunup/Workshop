{{- define "patient-service.name" -}}patient-service{{- end -}}
{{- define "patient-service.fullname" -}}{{ include "patient-service.name" . }}{{- end -}}
