# Skills Worth Installing

Skills are instruction sets that teach Claude Code how to use specific tools and frameworks correctly. They bridge the gap between Claude's general knowledge and domain-specific best practices, reducing errors and improving output quality.

## Recommended Skills

1. **[Frontend Design](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design)** - Generates distinctive, production-grade frontend interfaces that avoid generic AI aesthetics. Makes bold design choices with thoughtful typography, cohesive color palettes, and polished animations. Just describe what you want ("Create a dashboard for a music streaming app") and Claude delivers production-ready code. See the [Frontend Aesthetics Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/coding/prompting_for_frontend_aesthetics.ipynb) for prompting tips.
2. **[Remotion](https://www.remotion.dev/docs/ai/skills)** - Programmatic video creation powered by React. Describe a video in natural language and Claude generates complete Remotion components that render to MP4. Works best for data visualizations, product demos, educational content, and batch video generation. Install with `npx skills add remotion-dev/skills` inside a Remotion project. See the [prompt gallery](https://www.remotion.dev/prompts/) for inspiration.

## Setup

Install skills via npx:

```bash
npx skills add <owner>/<repo> --skill "<skill-name>"
```
