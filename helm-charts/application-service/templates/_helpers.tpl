{{- define "application-service.name" -}}application-service{{- end -}}
{{- define "application-service.fullname" -}}{{ include "application-service.name" . }}{{- end -}}
