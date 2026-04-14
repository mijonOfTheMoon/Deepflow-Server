# DeepFlow Server (Docker Compose)

Zero-instrumentation observability platform using eBPF. Captures network flows, application calls (HTTP, gRPC, SQL, DNS, etc.), and continuous profiling without code changes.

Reference: https://deepflow.io/docs/

## Prerequisites

- Linux VPS with Docker and Docker Compose
- Ports available: 3000 (Grafana), 30035 (gRPC), 30033 (data plane)

## Config

Edit `.env`:
- `NODE_IP_FOR_DEEPFLOW`: host IP reachable by agents

## Run

```bash
docker compose up -d
```

Grafana: `http://<NODE_IP>:3000` (admin:deepflow)

## License

[Apache 2.0 License](../../LICENSE).