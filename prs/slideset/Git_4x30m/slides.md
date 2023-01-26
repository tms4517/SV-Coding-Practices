---
title:
- Git Tooling at Nordic
author:
- Dave McEwan
date:
- Monday 6th February 2023
theme:
- CambridgeUS
colortheme:
- seahorse
---


# Introduction

## Agenda
- `......1100`  Meet and greet.
- `1100..1115`  Introduction
- `1115..1200`  Background: Revision control, version numbering.
- `1200..1300`  Practical/interactive: [RCS](https://www.gnu.org/software/rcs/)
  and [git](https://git-scm.com/) mechanics.
- `1300..1330`  Lunch.
- `1330..1430`  Nordic's setup:
  [NoRRIS](https://projecttools.nordicsemi.no/confluence/display/QPDA/NoRRIS+Manual)
  , [Dogit](https://projecttools.nordicsemi.no/confluence/display/SIG/dogit+reference+documentation)
  , [BitBucket](https://projecttools.nordicsemi.no/bitbucket/dashboard), etc.
- `1430..1600`  Practical/interactive: Merging.
- `1600..1730`  Activity: [Mini-golf](https://bristol.junglerumble.co.uk/).
- `1730......`  Meal: [Losteria](https://losteria.net/en/restaurants/restaurant/bristol/).

## Assumptions
- You are working at Nordic's Swindon site developing PMICs.
- You are comfortable working with Bash (or Zsh, Tcsh) on Linux.
- You have experience in collaboratively developing code.
- You have experience with some sort of version control before.

## Objectives
- Understand fundamental mechanics of git.
- Be comfortable exploring the internals of git repositories.
- Know how to dig yourself out of common problems with git.
- Understand interactions between components in Nordic's system.
- Networking between Nordic's Bristol and Swindon sites.


# Background

## `diff` and `patch`
- Used as the basis for all version control systems discussed today.
- Specified by POSIX since X/Open Portability Guide Issue 4 (1992).
- `diff` takes file1+file2, reports their differences in a patchfile.
- A patchfile precisely describes differences between two files.
  - Most common modern format is "unified" (vs "ed", "context").
  - Some context is often required.
  - Differences are identified line-by-line.
- `patch` takes a file+patchfile, applies the differences in-place.
- The pair of files must be vaguely similar.
  Garbage in, garbage out.

## RCS Overview
- <https://www.gnu.org/software/rcs/>
- 1st generation, but not obsolete!
- Current version is 5.10.1 (2022-02-02).
- Implemented as a collection of utilities (not a single exe):
  - `ci`, `co`
  - `ident`, `rcs`, `rcsclean`, `rcsdiff`, `rcsfreeze`, `rcsmerge`, `rlog`

## RCS Important Details
- Stored as separate/unmerged reverse deltas.
  - I.e. delta says how to get back to *previous* version.
  - Predecessor SCCS used forward deltas saying how to get to *next* version.
- Lock indicates that somebody *intends* to deposit a newer revision.
- Branches are on version numbers
  - Symbolic name is a prefix shortcut.
- Concept of joining is similar to merging.
- Stamping, like `$Header$`, expands strings on checkin.
- An edit script is a patchfile.

TODO: Got here

## CVS
- <https://cvs.nongnu.org/>
- 2nd generation, mostly obsolete.
- Frontend to RCS bringing client/server model
- Composed of fewer executables (cvs, cvspserver).
- Delta compression distinguishes between text and binary.
- Project is a set of related files.
- Introduced "loginfo" similar to githooks.
- Centralised repository, usually accessed over RSH (predecessor to SSH).

## SVN
- <https://subversion.apache.org/>
- 2nd generation, mostly obsolete.
- Intended to be successor to CVS, and mostly compatible.
- Many implementations of both clients and servers.
- Centralised repository, accessed over SSH, HTTP, or HTTPS
- Atomic commits to multiple files.
- Properties (key/value pairs).
- The SVN tool is version controlled, with incompatibilities.
- Relies heavily on conventions (trunk, branches, tags) so it's easy to make
  a mess.

## Git
- <https://git-scm.com/>
- 3rd/current generation.
- Distributed network of repositories, accessed over SSH or HTTPS.
- Every repository has a full copy of history.
  Locking concept doesn't apply, but can be emulated.
- Concepts of branches and tags are first-class citizens with precise
  definitions.
- Concept of version numbering is intentionally avoided.
- Concept of stamping, like `$Header$`, doesn't exist but note CI/CD.

## SemVer
- <https://semver.org/>
- Specification of version numbering scheme.
- Used for many/most open-source projects.
- Used as basis for Nordic's internal IP/HDN releases.
- ...See the tiny webpage...
