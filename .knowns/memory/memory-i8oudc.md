---
id: i8oudc
title: 'False positive "Cannot find module" in IDE for Backend'
layer: project
category: failure
tags:
  - debug
  - python
  - fastapi
createdAt: '2026-05-07T06:54:09.670Z'
updatedAt: '2026-05-07T06:54:09.670Z'
---

Root cause: IDE reported "Cannot find module" for FastAPI/Pydantic despite being installed. Fix: Added __init__.py files to define directories as packages and verified the interpreter path. Static analysis often fails when project structure is deep without explicit package markers.
