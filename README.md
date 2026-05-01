# DeepFlow Server (Docker Compose)

Zero-instrumentation observability platform using eBPF. Captures network flows, application calls (HTTP, gRPC, SQL, DNS, etc.), and continuous profiling without code changes.

Reference: https://deepflow.io/docs/

## Prerequisites

- Linux VPS with Docker and Docker Compose

## Config

Edit `.env`:
- `NODE_IP_FOR_DEEPFLOW`: host IP reachable by agents

## Run

```bash
docker compose up -d
```

Grafana: `http://<NODE_IP>:3000` (admin:deepflow)

## Agent Group Setup

After server is running, create agent group and push config:

```bash
bash scripts/setup-group.sh
```

This creates a new group with config for Docker environments. The script outputs the `agent-group-id`to use in your agent's config.

## License

[Apache 2.0 License](../../LICENSE).