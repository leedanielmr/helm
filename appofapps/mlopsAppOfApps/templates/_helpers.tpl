apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "tks-contract.fullname" . }}
  namespace: {{ .Values.namespace }}
  labels:
    {{- include "tks-contract.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "tks-contract.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "tks-contract.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "tks-contract.serviceAccountName" . }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: tks-contract
              containerPort: {{ .Values.args.port }}
              protocol: TCP
          command:
            - /app/server
          args: [
            "-port", "{{ .Values.args.port }}",
            "-dbhost", "{{ .Values.args.dbUrl }}",
            "-dbport", "{{ .Values.args.dbPort }}",
            "-dbuser", "{{ .Values.args.dbUser }}",
            "-dbpassword", "{{ .Values.args.dbPassword }}",
            "-info-address", "{{ .Values.args.tksInfoAddress }}",
            "-info-port", "{{ .Values.args.tksInfoPort }}"
          ]
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}