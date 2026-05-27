---
type: active-recall
source: "[[Jane Doe - On Why Most Agent Benchmarks Are Vibe Benchmarks]]"
created: 2026-01-15
next_review: 2026-01-16
ease: 2.5
review_count: 0
---

# Active recall - Jane Doe - Vibe Benchmarks

## Q1 (thesis)

What is Jane Doe's central claim about the current generation of agent benchmarks, and what is the proposed alternative?

<details><summary>Answer</summary>

Current agent benchmarks measure task completion on closed datasets that models have likely seen during pre-training - this rewards memorization disguised as agency. The proposed alternative is **open-world benchmarks** that test the agent's ability to discover the right tool, not execute a tool whose name is in the prompt.

</details>

## Q2 (verified number)

What was the tool-use accuracy delta between closed-world and open-world benchmarks reported in the video?

<details><summary>Answer</summary>

- Closed-world: 87%
- Open-world: 31%
- Delta: 56 percentage points

Source verified at ingest from speaker's published benchmark suite (12.4k GitHub stars).

</details>

## Q3 (failure mode)

The video identifies a specific failure mode in open-world agent tasks. It is NOT "the agent chose the wrong tool." What is it, and why is this distinction important?

<details><summary>Answer</summary>

The failure mode is **"no tool considered"** - the agent does not enter the search space at all.

This is important because it mirrors the **syntactic vs functional success** pattern in distributed systems: the operation returns success because the wrong scope was measured. The agent reports "task complete" while never having explored the tool space.

</details>

## Q4 (tension / synthesis)

The video does not address whether closed-world benchmarks have any legitimate role. Based on your prior notes, what is one defensible role for them?

<details><summary>Answer</summary>

Closed-world benchmarks remain useful for **regression testing**: ensuring a model update does not degrade known capabilities. They are not useful for measuring agency, but they are useful for measuring stability.

The tension between this view and the video's position is an **open tension** in the graph - both can be true at once, but the resolution requires acknowledging the two benchmarks measure different things.

</details>

## Q5 (cross-graph synthesis)

The video introduces a doctrine that connects to a broader pattern in your vault: that **the artifact being evaluated changes faster than the evaluation tool**. Name two other domains where you have notes asserting this same pattern.

<details><summary>Answer</summary>

Two other domains where this pattern appears in the vault:

1. **Long-running agent eval drift** - logs gathered with v1 instrumentation become incomprehensible at v2 of the agent
2. **Pre-training contamination in NLP benchmarks** - benchmarks designed before a model's training data become invalid once the model sees them

The shared structural element is: **a measurement system is valid only relative to a stable target. When the target evolves faster than the measurement, the measurement decays into theater.**

This is the doctrine the video manifests in a new domain.

</details>

---

## Review notes

Use this section to log your recall performance and adjust the schedule manually if needed.

- 2026-01-16 (review 1): _to be filled_
- 2026-01-19 (review 2): _to be filled_
- 2026-01-26 (review 3): _to be filled_

**Scoring**:
- All 5 recalled smoothly -> next_review = today + (current_interval * ease)
- 3-4 recalled -> next_review = today + current_interval (ease unchanged)
- 0-2 recalled -> next_review = today + 1, ease *= 0.85 (penalty)
