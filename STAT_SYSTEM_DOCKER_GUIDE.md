# Player Stat System - Docker Testing Guide

## Quick Start (Partial Testing with Published Image)

### Prerequisites

- Docker & Docker Compose installed
- The stat system Lua scripts in `data/scripts/talkactions/player/`

### Start the Server

```bash
cd h:\Github\canary
docker-compose -f docker-compose.stats.yml up -d
```

### Verify Services

```bash
# Check all services are running
docker-compose -f docker-compose.stats.yml ps

# View server logs
docker-compose -f docker-compose.stats.yml logs -f server

# Access MariaDB to verify schema
docker exec -it otbr-stats-db-1 mariadb -ucanary -pcanary canary
# Query: SELECT * FROM players LIMIT 1\G
# Should show new columns: stat_strength, stat_dexterity, etc.
```

### Login to Game

- **Address:** 127.0.0.1:7171
- **Test Account:** test / test (created by `01-test_account.sql`)
- **Web Admin:** http://localhost:8080
- **MyAAC:** http://localhost:8088

### Test Stat Commands

Once logged in, use these commands:

- `!stats` - Display player stats
- `/addstat strength 5` - Add 5 points to Strength
- `/addstat intelligence 3` - Add 3 points to Intelligence

### Clean Up

```bash
docker-compose -f docker-compose.stats.yml down -v
```

---

## Full Testing (With C++ Compilation)

The published Docker image doesn't include the stat system C++ code. For complete testing:

### 1. Fix CMake Configuration

First, resolve the CMake/vcpkg issue locally:

```bash
cd h:\Github\canary

# Clear previous builds
rmdir /s /q build

# Apply CMake fix (from session notes)
# File: cmake\modules\BaseConfig.cmake
# - Pre-configure all INTERFACE library targets
# - Skip vcpkg wrapper invocation

# Configure CMake
cmake --preset windows-release

# Build
cmake --build --preset windows-release --target canary
```

### 2. Build Local Docker Image

```bash
# Build from your source with stat system included
docker build -f docker/Dockerfile.x86 -t canary-stats:latest .

# Update docker-compose.stats.yml to use local build:
# Change: image: "${CANARY_IMAGE:-ghcr.io/opentibiabr/canary:latest}"
# To: image: "canary-stats:latest"
# Or: docker-compose -f docker-compose.stats.yml -e CANARY_IMAGE=canary-stats:latest up -d
```

### 3. Run with Local Build

```bash
CANARY_IMAGE=canary-stats:latest docker-compose -f docker-compose.stats.yml up -d
```

### 4. Full Feature Testing

With local build, you can test:

- **Stat Effects:** Damage increases with Strength, Health pool with Constitution, etc.
- **Level-Up Points:** Every 5 levels grants 1 unspent stat point
- **Persistence:** Stats saved to database on logout
- **NPC Prices:** Affected by Charisma modifier
- **All 6 Stats:** Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma

---

## Database Schema

The migration file `docker/data/03-player-stats-migration.sql` adds:

```sql
stat_strength INT(11)         -- Affects physical damage
stat_dexterity INT(11)        -- Affects attack speed
stat_constitution INT(11)     -- Affects health pool (HP/2)
stat_intelligence INT(11)     -- Affects magic level
stat_wisdom INT(11)           -- Affects mana pool (MANA/2)
stat_charisma INT(11)         -- Affects NPC shop prices
unspent_stat_points INT(11)   -- Allocated on level-up (every 5 levels)
```

---

## Troubleshooting

### "Stat system Lua functions not found"

- The published image doesn't have stat C++ bindings
- Workaround: Use local build (see "Full Testing" section)

### Database migration not applied

```bash
# Manually apply migration
docker exec -i otbr-stats-db-1 mariadb -ucanary -pcanary canary < docker/data/03-player-stats-migration.sql
```

### Stats not persisting

- Verify database columns exist: `DESCRIBE players;`
- Check server logs for Lua errors: `docker-compose -f docker-compose.stats.yml logs server`

### Build issues with local Docker

- Ensure CMake is fixed first (see CMake section above)
- Check `docker/Dockerfile.x86` uses correct build tools
- Verify vcpkg baseline matches your environment

---

## Next Steps

1. **For Lua/DB Testing:** Use published image setup
2. **For Full System Testing:** Fix CMake → Build local Docker → Deploy
3. **For Production:** Use fixed CMake to build optimized release image

See [session notes](../../AGENTS.md) for CMake workaround details.
