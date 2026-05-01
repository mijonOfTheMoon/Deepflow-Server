# Deepflow Server

# Summary

Deepflow is an eBPF-based zero-instrumentation full-stack observability tool.

Zero-instrumentation means this tool can be implemented without touching the application source code at all.

Full-stack means this tool can perform Application Performance Monitoring, Distributed Tracing, Continuous Profiling, and Host Metrics Monitoring simultaneously. In short, Deepflow can monitor both application and server performance.

Deepflow utilizes eBPF technology, which is a technology to run programs in the Linux kernel. Therefore, this tool can record application activities from the kernel level, through network packets, request logs, system calls, function calls, etc.

Deepflow's Host Metrics Monitoring feature is only available in the Enterprise Edition at the time this documentation is written.

Fortunately, Deepflow has a very broad ecosystem. Deepflow can be integrated with other open-source tools, such as OpenTelemetry, Pyroscope, Prometheus, Telegraf, and many more.

For the Host Metrics monitoring use case, Telegraf is the primary choice due to its simplicity.

# Hardware Prerequisites

#### Deepflow Server

Minimum specifications     : 2 vCPU 4GB RAM
Recommended specifications : 4 vCPU 8GB RAM

Small scale storage:
The total minimum storage required by the Deepflow server is approximately **5.08 GB**.

#### Deepflow Agent

Idle Usage                 : 0.15vCPU 400 MB RAM
Default limit              : 1vCPU 768 MB RAM

# Installation Guide

#### Deepflow Server

1. Clone the Deepflow server repository from Gitlab

```bash
git clone https://gitlab.skwn.dev/hasbi-personal/deepflow-server
```

2. Move into the Deepflow server directory

```bash
cd deepflow-server
```

3. Adjust the .env

```bash
nano .env
```

```bash
DEEPFLOW_VERSION=v7.1
NODE_IP_FOR_DEEPFLOW=#Host IP address accessible by Deepflow agent
```

4. (Optional) To use the AI feature, add the API key and API base url in the configuration

```bash
nano common/config/stella-agent/df-llm-agent.yaml
```

```yaml
...

ai:
  enable: False # Change to True
  platforms:
  
		  # If using openai
    - platform: "openai"
      enable: False # Change to True
      model: "openai"
      api_key: '' # Add API Key here
      engine_name:
        - '' # Add AI model name here

			# If using azure
    - platform: 'azure'
      enable: False # Change to True
      model: 'gpt'
      api_type: 'azure'
      api_key: '' # Add API Key here
      api_base: '' # Add API base url here
      api_version: ''
      engine_name:
        - '' # Add AI model name here

			# If using alibaba cloud model studio international (free)
    - platform: 'aliyun'
      enable: False # Change to True
      model: 'dashscope'
      api_key: '' # Add API Key here
      api_base: '' # Add API base url here
      engine_name:
        - 'qwen-max'
        - 'qwen-plus-latest'
  
```

5. Run docker-compose up -d to run all Deepflow server services

```bash
docker compose up -d
```

6. Wait 5 - 10 minutes until the server is ready, then run the setup script to add agent configuration

```bash
chmod +x common/scripts/setup.sh
./common/scripts/setup.sh
```

Done! now you can set up you Deepflow agents.