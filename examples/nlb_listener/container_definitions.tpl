[
  {
    "name": "${name}",
    "image": "${image}",
    "cpu": 256,
    "memory": 256,
    "essential": true,
    "command": [],
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "ENV",
        "value": "stg"
      }
    ],
    "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
        "fluentd-async-connect": "true",
        "tag": "${name}"
      }
    }
  }
]