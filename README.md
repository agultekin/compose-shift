# Docker Compose Worktree Switcher (`compose-shift`)

`compose-shift` is a lightweight Bash script designed for developers using **Git worktrees**, multiple project directories, or parallel branches where Docker container port conflicts and resource overlaps frequently occur.

It automatically inspects all running Docker Compose stacks across your system, stops them gracefully without removing containers or volumes, and starts the Docker Compose environment in your target directory.

---

## Features

- **Port Conflict Prevention:** Stops running Compose stacks before starting a new one to prevent port allocation collisions (e.g., `8080`, `5432`, `6379`).
- **Path-Independent Stack Detection:** Uses Docker labels (`com.docker.compose.project.config_files`) to find running Compose projects, regardless of directory location or branch switches.
- **Fast State Switching:** Uses `docker compose stop` rather than `down`, preserving container state and volumes for instant context switching.
- **Flexible Invocation:** Run it inside your target directory or pass any worktree path as an argument.

---

## Requirements

- **Docker Engine** (with Docker Compose V2 support: `docker compose`)
- **Bash** (v4.0 or higher recommended)

---

## Installation

1. **Clone or Download the Repository:**

   ```bash
   git clone https://github.com/agultekin/compose-shift.git
   cd docker-switch
   chmod a+x docker-switch.sh
