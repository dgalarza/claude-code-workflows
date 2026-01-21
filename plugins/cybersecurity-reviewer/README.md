# Cybersecurity Reviewer

Security analysis agent for vulnerability assessment, threat modeling, and security architecture review.

## Install

*Agents require the Claude marketplace to install.*

```bash
/plugin marketplace add dgalarza/claude-code-workflows
/plugin install cybersecurity-reviewer@dgalarza-workflows
```

## What It Does

Provides expert-level security analysis with actionable remediation guidance. The agent thinks like an attacker to identify vulnerabilities before they're exploited.

## Capabilities

### Vulnerability Assessment
- Injection attacks (SQL, XSS, command injection)
- Authentication and authorization flaws
- Sensitive data exposure
- Security misconfigurations
- Broken access control
- Cryptographic failures
- SSRF and insecure deserialization
- Components with known vulnerabilities

### Threat Modeling
- Identify attack surfaces and data flows
- Assess risk levels (likelihood × impact)
- Prioritize security concerns
- Apply CIA triad analysis

### Framework-Specific Knowledge
- Rails security patterns and common pitfalls
- Built-in protections (auto-escaping, CSRF tokens, SQL parameterization)
- ActsAsTenant security for multi-tenant isolation
- Strong Parameters for mass assignment protection

## Output Format

```markdown
# Security Review

## Executive Summary
High-level overview of findings and risk level

## Critical/High Severity Issues

### 1. SQL Injection Vulnerability
- **Type**: Injection (CWE-89)
- **Location**: app/services/search_service.rb:23
- **Risk**: Critical
- **Explanation**: User input passed directly to SQL query...
- **Remediation**: Use parameterized queries
- **Reference**: OWASP A03:2021

## Medium/Low Severity Issues
[...]

## Security Enhancements
Proactive improvements beyond fixing vulnerabilities

## Positive Security Practices
What's done well
```

## Security Principles Applied

- **Principle of Least Privilege** - Minimum necessary permissions
- **Defense in Depth** - Multiple security layers
- **Fail Securely** - Failures don't compromise security
- **Never Trust User Input** - Validate, sanitize, encode

## When to Use

- Security reviews before deployment
- Penetration test preparation
- Architecture review
- Implementing authentication/authorization
- Handling sensitive data
- OAuth2/API security implementation

## Works Well With

- [Parallel Code Review](../parallel-code-review/README.md) - Run alongside architecture review
- [Rails Toolkit](../rails-toolkit/README.md) - Rails-specific security patterns
