# OpenCode Configuration

This directory contains the OpenCode configuration with secure API key management.

## Setup

1. **Environment Variables**: API keys are stored in `.env` file (not committed to git)
2. **Configuration**: `opencode.json` references environment variables using `{env:VARIABLE_NAME}` syntax

## Usage

### Option 1: Source environment variables manually
```bash
source ai/.config/opencode/.env
opencode
```

### Option 2: Use the wrapper script
```bash
./ai/.config/opencode/load-env.sh
```

### Option 3: Add alias to your shell config
Add to your `.bashrc` or `.zshrc`:
```bash
alias opencode='source ~/dots/ai/.config/opencode/.env && command opencode'
```

## Security

- `.env` file contains sensitive API keys and is excluded from git
- `opencode.json` is safe to commit as it only contains environment variable references
- Never commit the `.env` file to version control

## API Keys

The following API keys are configured:
- `REF_API_KEY`: Ref Tools MCP API key
- `EXA_API_KEY`: Exa AI API key

To add new API keys:
1. Add them to `.env` file
2. Reference them in `opencode.json` using `{env:KEY_NAME}` syntax