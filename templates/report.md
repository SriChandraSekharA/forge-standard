# Anvil Review Report

<!-- feat: ranked report template - 5 sections Critical->Nitpick strict order, placeholders critical_findings table + bullet reason/fix/prompt -->
Generated: {{generated_at}}

Summary: {{summary}}

{{findings}}

## Critical

{{critical_findings}}

| file:line | severity | reason | fix | prompt |
|-----------|----------|--------|-----|--------|
| {{file}}:{{line}} | critical | {{reason}} (CWE-89 / OWASP A03) | {{fix}} | {{prompt}} |

- **{{file}}:{{line}} | critical**
  - reason: {{reason}} (CWE-89 / OWASP A03: Injection)
  - fix: {{fix}}
  - prompt: Act as a senior security engineer, fix critical at {{file}}:{{line}} by {{fix}}

## High

{{high_findings}}

- **{{file}}:{{line}} | high**
  - reason: {{reason}} (CWE-20 / Fowler)
  - fix: {{fix}}
  - prompt: Act as a senior reviewer, fix high at {{file}}:{{line}} by {{fix}}

## Medium

{{medium_findings}}

- **{{file}}:{{line}} | medium**
  - reason: {{reason}} (Fowler Code Smell)
  - fix: {{fix}}
  - prompt: Act as a senior reviewer, fix medium at {{file}}:{{line}} by {{fix}}

## Low

{{low_findings}}

- **{{file}}:{{line}} | low**
  - reason: {{reason}} (Fowler Readability)
  - fix: {{fix}}
  - prompt: Act as a senior reviewer, fix low at {{file}}:{{line}} by {{fix}}

## Nitpick

{{nitpick_findings}}

- **{{file}}:{{line}} | nitpick**
  - reason: {{reason}} (Fowler Style)
  - fix: {{fix}}
  - prompt: Act as a senior style reviewer, fix nitpick at {{file}}:{{line}} by {{fix}}

---

When no findings: `No findings` in each section.

Usage: `scripts/report.sh` fills {{findings}} sorted critical=0 high=1 medium=2 low=3 nitpick=4 and writes `.forge-standard/report.md` + `review.json`.
