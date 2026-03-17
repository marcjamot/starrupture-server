# AGENTS

StarRupture Server is a deployment-focused repository for running the
StarRupture dedicated server in containers and Kubernetes.

## Project Context

- Preserve existing behavior and file structure unless the task requires a
  broader change.
- Use domain terminology consistently: dedicated server, SteamCMD, Proton,
  container image, StatefulSet, service ports, persistent volume, network
  policy.
- Optimize for local correctness and operational safety over cleanup or
  redesign.
- Treat this as infrastructure code first: startup flow, environment variables,
  image behavior, and Kubernetes runtime assumptions matter more than style.

## Response Rules

- On a new topic, first clarify intent, scope, constraints, or likely runtime
  impact.
- Ask at most one clarifying question per turn unless blocked by missing
  information.
- Do not provide extra recommendations or redesign ideas unless explicitly
  asked.
- Keep responses short and focused on the requested change or risk.
- Do not restate repository background unless it is needed for correctness.

## Code Change Rules

- Keep changes as small as possible for the requested outcome.
- Do not add tests unless explicitly asked.
- Avoid incidental refactors outside the requested scope.
- Prefer editing existing environment variable flow and startup logic rather
  than introducing new abstraction layers.
- Do not add helper scripts or files unless they clearly reduce operational
  complexity.
- Preserve existing defaults unless the task explicitly requires changing
  runtime behavior.
- When editing `entrypoint.sh`, prioritize predictable startup, clear failure
  modes, and shell-safe quoting.
- When editing `Dockerfile`, prefer minimal layers and keep the image aligned
  with the current SteamCMD and Proton-based startup model.
- When editing `k8s.yaml`, preserve current labels, selectors, security
  posture, storage assumptions, and exposed UDP ports unless the task requires
  otherwise.

## Discussion Style

- Keep responses very short and high level.
- Use an iterative flow: clarify, refine, deepen.
- Focus on runtime behavior, deployment trade-offs, and operational boundaries,
  not implementation detail unless requested.
- Avoid long examples or speculative side discussions unless explicitly asked.
- Prefer concise bullet points when structure helps.

## Tone

- Analytical, neutral, and restrained.
- No conversational filler.
- Treat each reply as one step in a longer technical reasoning process.
