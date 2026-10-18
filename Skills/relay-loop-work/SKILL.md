---
name: relay-loop-work
description: Work PC side of the Discord relay loop with the home PC - read instructions, act, post the result, check every 30 minutes. Use only when the user starts it.
argument-hint: "[channel] [check minutes, default 30]"
disable-model-invocation: true
---

# Work PC relay loop

The user has asked for this loop:

> Work PC loop: (1) Please get instructions from Discord. (2) Act on the instructions appropriately. (3) When done
> post a response back. (4) Check every 30 minutes for further instructions to continue the loop. Do not stop to
> involve me unless there is a critical need. If there is a critical need please stop and inform the other side as
> well. They will have similar instructions. End every message you post with who should act next (e.g. "Your turn"
> or "My turn: working on it"), and if the other side seems to be waiting on you, re-read recent messages rather
> than relying on only the newest ones.

The home PC runs the sister loop (`relay-loop-home`: it posts instructions and checks every 15 minutes).

## Arguments

- $0: the Discord channel (the one the home PC posts to for this project).
- $1: minutes between checks (default 30).

## The loop

1. **Get instructions.** Read the channel's new messages. If the home side seems to be waiting on you (its last
   message ends "Your turn", or a question went unanswered), read the recent history, not only the newest
   message, and find what is owed.
2. **Act.** Do what the instructions ask: run the named version, with the stop rules they give. While a long run is
   going, post the progress updates they ask for at the times they ask.
3. **Post back.** When done, or when a stop rule fires, post the result: the exact keys and numbers asked for,
   plus anything unexpected. Only send aggregate numbers and keys, never source, file contents, paths or logs. If
   something they asked for can't be sent that way, say so instead.
4. **Check again** every 30 minutes (a background timer, not a busy loop) for further instructions, then go back
   to 1.

## Every post

- End it with who acts next: "Your turn: <what>" or "My turn: <what I'm doing>", or both when both sides work in
  parallel.
- Keep it self-contained: what ran (version), what happened, the numbers.

## Stopping

Stop only for a critical need, such as something only the user can decide, a run that can't continue, or the user
saying to stop. Before you stop, post to the channel why you are stopping and what state things are in, ending with
who acts next. Then tell the user.
