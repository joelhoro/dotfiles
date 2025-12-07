#!/bin/bash
#
# Cursor Agent Wrapper Script
# Automatically creates and stores chat ID, then resumes that session
#
# Usage:
#   ./cursor-agent-wrapper.sh [args]          # Run cursor-agent, auto-resume/create chat
#   ./cursor-agent-wrapper.sh --new [args]    # Start fresh session (create new chat ID)
#   ./cursor-agent-wrapper.sh --clear-session # Clear saved chat ID
#
# The chat ID is saved to .cursor-chat-id in the project root.
# When you run the wrapper again in the same directory, it will automatically
# resume the same chat session.
#
# To use as your default cursor-agent command, add to your ~/.bashrc or ~/.zshrc:
#   alias cursor-agent='~/path/to/cursor-agent-wrapper.sh'
#

# Don't exit on errors - we want to handle them ourselves
set +e

CHAT_ID_FILE=".cursor-chat-id"
PROJECT_ROOT="$(pwd)"

# Function to create a new chat and save the ID
create_and_save_chat_id() {
    echo "🆕 Creating new chat session..." >&2
    local chat_id=$(cursor-agent create-chat 2>/dev/null | tr -d '\n' | tr -d ' ')
    
    if [ -z "$chat_id" ] || [ "$chat_id" = "" ]; then
        echo "❌ Error: Failed to create chat. Output:" >&2
        cursor-agent create-chat >&2
        return 1
    fi
    
    # Save the chat ID
    echo "$chat_id" > "$PROJECT_ROOT/$CHAT_ID_FILE"
    echo "💾 Created and saved chat ID: $chat_id" >&2
    echo "$chat_id"
    return 0
}

# Function to get or create chat ID
get_or_create_chat_id() {
    local chat_id=""
    
    # Check if chat ID file exists
    if [ -f "$PROJECT_ROOT/$CHAT_ID_FILE" ]; then
        chat_id=$(cat "$PROJECT_ROOT/$CHAT_ID_FILE" | tr -d '\n' | tr -d ' ')
        
        # Validate it's not empty
        if [ -n "$chat_id" ]; then
            echo "✅ Found existing chat ID: $chat_id" >&2
            echo "$chat_id"
            return 0
        fi
    fi
    
    # No valid chat ID found, create a new one
    echo "ℹ️  No existing chat ID found. Creating new chat session..." >&2
    create_and_save_chat_id
}

# Handle --clear-session flag
if [ "$1" = "--clear-session" ]; then
    if [ -f "$PROJECT_ROOT/$CHAT_ID_FILE" ]; then
        rm "$PROJECT_ROOT/$CHAT_ID_FILE"
        echo "🗑️  Cleared saved chat ID" >&2
    else
        echo "ℹ️  No saved chat ID found" >&2
    fi
    exit 0
fi

# Handle --new flag (force new chat)
if [ "$1" = "--new" ]; then
    shift
    # Remove existing chat ID file and create new one
    rm -f "$PROJECT_ROOT/$CHAT_ID_FILE"
    CHAT_ID=$(create_and_save_chat_id)
    if [ $? -ne 0 ]; then
        exit 1
    fi
else
    # Get existing chat ID or create new one
    CHAT_ID=$(get_or_create_chat_id)
    if [ $? -ne 0 ] || [ -z "$CHAT_ID" ]; then
        echo "❌ Error: Could not get or create chat ID" >&2
        exit 1
    fi
fi

# Now run cursor-agent with --resume and the chat ID, plus any additional arguments
cursor-agent --resume "$CHAT_ID" "$@"
