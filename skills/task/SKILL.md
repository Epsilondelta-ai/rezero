---
description: Create structured task definitions for software development projects
---

# Task Definition Generator

This skill helps you create structured task definitions for software development projects. It produces a detailed task document that can later be converted into `task.json` for the Re:ZERO Loop autonomous agent system.

## Process

### Phase 1: Discovery

Before writing anything, ask 3-5 clarifying questions to understand the task scope. Present questions with lettered options where applicable.

Example questions:
- **A)** What is the primary goal of this feature/change?
- **B)** Who are the target users? (e.g., end users, developers, admins)
- **C)** What is the scope? (e.g., backend only, full-stack, UI only)
- **D)** Are there existing patterns or technologies that must be used?
- **E)** What does success look like? How will we know this is done?

Wait for answers before proceeding to Phase 2.

### Phase 2: Documentation

Using the discovery answers, generate a comprehensive task document with the following sections:

#### 1. Introduction
A brief overview of the feature or change and its context within the project.

#### 2. Goals
Bullet list of specific, measurable goals this task aims to achieve.

#### 3. User Stories
Each user story must be:
- **Small**: Completable by an AI agent in a single iteration (one context window)
- **Independent**: Minimal dependencies on other stories (though ordering matters)
- **Verifiable**: Every acceptance criterion must be objectively checkable

Format:
```
### US-XXX: [Title]
**As a** [role], **I want** [capability] **so that** [benefit].

**Acceptance Criteria**:
- [ ] [Specific, verifiable criterion]
- [ ] [Another criterion]
- [ ] Typecheck passes
```

**Right-sizing guidance**:
- GOOD: "Add a `priority` column to the tasks table" — one focused schema change
- GOOD: "Create a PriorityBadge component that displays colored labels" — one UI component
- BAD: "Implement the full priority system with database, API, and UI" — too large, will exhaust context

**UI stories** must include: `- [ ] Verify in browser that [specific visual/interaction requirement]`

#### 4. Functional Requirements
Numbered requirements (FR-1, FR-2, etc.) specifying exact behavior. Be explicit — write as if a junior developer or AI agent will implement this with no additional context.

#### 5. Non-Goals
Explicitly state what is NOT in scope to prevent scope creep.

#### 6. Design Considerations
Visual or architectural guidelines, component structure, layout decisions.

#### 7. Technical Considerations
Stack constraints, performance requirements, compatibility needs, migration strategies.

#### 8. Success Metrics
How to measure whether the implementation is successful (e.g., "All tests pass", "Page loads in under 2s").

#### 9. Open Questions
Unresolved decisions that need input before or during implementation.

## Output

Save the generated document to: `tasks/task-[feature-name].md` (use kebab-case for the filename).
