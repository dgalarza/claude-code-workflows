# Crafting Video Hooks for Technical Content

## Understanding the Opening Sequence

Your video's first 20 seconds determine whether viewers stay or leave. This breaks down into two critical phases:

**The Hook (0-5 seconds):** Confirms they clicked the right video  
**Click Confirmation (5-20 seconds):** Creates tension that keeps them watching

---

## The Click Confirmation Principle

After viewers click (because of your title/thumbnail), you have 10-20 seconds to confirm they made the right choice and build urgency to keep watching.

### The 20-Second Opening Formula

**Seconds 0-5: The Hook (Confirm the click)**  
Immediately validate their click by restating your promise or contrarian position
- "You don't need a vector database for Rails RAG"
- "I'm going to add streaming AI responses in 10 minutes"

**Seconds 5-12: The Common Belief (Create tension)**  
Establish what "everyone" says or does—this is the conventional wisdom
- "Most tutorials say you need Pinecone or Weaviate..."
- "Every guide starts with complex infrastructure setup..."

**Seconds 12-20: Your Contrarian Take (Build urgency)**  
State why your approach is better/different/faster—the distance between the common belief and your take creates the tension that hooks viewers
- "...but Postgres pgvector does everything you need, and it's already running"
- "...I'm going to show you a zero-dependency approach using just Turbo"

### Why This Works for Technical Content

The distance between **common belief** and **your contrarian take** creates urgency:

**Greater distance = More tension = Longer watch time**

Developers have strong opinions about "the right way." Challenging conventional wisdom creates immediate curiosity about whether you're right.

#### Low Tension Example (weak hook):
- **Common belief:** "Use a database for data"
- **Your take:** "I use Postgres"
- **Distance:** Minimal—this is obvious, no tension

#### High Tension Example (strong hook):
- **Common belief:** "RAG requires vector databases like Pinecone"
- **Your take:** "Postgres does it better and it's already in your stack"
- **Distance:** Significant—this challenges conventional wisdom, creates tension

---

## The 6 Hook Power Words (Building Blocks)

Every effective hook contains a combination of six component "power words." These are the building blocks you can use to construct any hook from first principles. Four are essential; two are optional intensifiers.

### Core Components (Required)

| Component | What It Does | Examples |
|-----------|--------------|----------|
| **Subject** | WHO the hook is about | I, we, you, "this pattern", "Claude" |
| **Action** | WHAT happens (the verb) | grow, cut, deploy, discover, build |
| **Objective** | The RESULT achieved | 100K subs, 80% cost reduction, zero config |
| **Contrast** | Base state vs new state | 0 → 100K, hours → minutes, complex → simple |

### Optional Intensifiers

| Component | What It Does | Examples |
|-----------|--------------|----------|
| **Proof** | WHY to trust you | "again" (implies done before), credentials, specific numbers |
| **Time** | URGENCY/speed constraint | "in 10 minutes", "this week", "before your next deploy" |

### How These Map to the 20-Second Formula

```
[0-5s Hook]     = Subject + Action + Objective + Contrast
[5-12s Common]  = Sets up the base state (what Contrast compares against)
[12-20s Take]   = Reinforces Objective + optional Proof/Time intensifiers
```

### Example Breakdown

**Hook:** "If I had to grow from zero to 100K subs on YouTube again, here's how I'd do it in 5 months."

| Component | Word/Phrase |
|-----------|-------------|
| Subject | I |
| Action | grow |
| Objective | 100K subs on YouTube |
| Contrast | zero → 100K |
| Proof | "again" (implies done it before) |
| Time | "in 5 months" |

**Technical Example:** "I cut my Claude API costs by 80% with this one caching pattern."

| Component | Word/Phrase |
|-----------|-------------|
| Subject | I |
| Action | cut |
| Objective | Claude API costs by 80% |
| Contrast | full price → 80% reduction |
| Proof | Implied by specific number (80%) |
| Time | Not used (could add "this week") |

### Strengthening Weak Hooks

When a hook feels flat, check which components are missing:

**Weak:** "How to use pgvector in Rails"
- Missing: Contrast, Objective (what outcome?), Proof

**Stronger:** "I replaced Pinecone with Postgres pgvector and cut my vector DB costs to $0"
- Subject: I
- Action: replaced
- Objective: cut costs to $0
- Contrast: Pinecone → Postgres, costs → $0
- Proof: Implied by "I" (personal experience)

**Even Stronger (add Time):** "I replaced Pinecone with Postgres pgvector in 30 minutes and cut my vector DB costs to $0"

---

## Complete Opening Examples

### Example 1: Vector Database Alternative

**Title:** "You Don't Need a Vector Database for Rails RAG"

**Opening Script:**
```
[0-5s - Hook]
"You don't need a vector database for semantic search in Rails."

[5-12s - Common Belief]
"Every tutorial tells you to set up Pinecone or Weaviate. 
You'll spend hours on infrastructure, manage another API, 
and add complexity to your deployment."

[12-20s - Your Take]
"But Postgres with pgvector handles millions of embeddings, 
it's already in your stack, and setup takes 5 minutes. 
Let me show you."

[Start demonstration]
```

### Example 2: API Cost Optimization

**Title:** "I Cut My Claude API Costs by 80% With This One Pattern"

**Opening Script:**
```
[0-5s - Hook]
"This one caching pattern dropped my Claude API costs by 80%."

[5-12s - Common Belief]
"Most developers just send every request to the API. 
You pay for the same prompt completions over and over, 
and costs spiral as traffic grows."

[12-20s - Your Take]
"But with semantic similarity caching in Rails, 
you can reuse responses for similar queries 
and only hit the API when truly necessary. 
Here's the exact pattern."

[Start demonstration]
```

### Example 3: Deployment Speed

**Title:** "Deploy Rails AI Features in 10 Minutes (No Docker Required)"

**Opening Script:**
```
[0-5s - Hook]
"I'm going to deploy a Rails AI feature in under 10 minutes 
with zero Docker configuration."

[5-12s - Common Belief]
"Everyone says you need containers, orchestration, 
and complex CI/CD pipelines for production AI apps."

[12-20s - Your Take]
"But with Kamal 2 and a single config file, 
you get zero-downtime deploys to any server. 
Watch how simple this actually is."

[Start demonstration]
```

---

## Hook Templates for AI/Rails Content

Each template includes the full 20-second structure for maximum retention.

### 1. The Contrarian Hook

**Template:**
```
[Hook] "Everyone says to [common approach], but [controversial take]."
[Common Belief] "Most people [describe standard approach and its drawbacks]."
[Your Take] "But [your approach] [specific benefit]. Here's how."
```

**Example:**
"Everyone says you need webhooks for real-time AI. Most apps set up complex webhook handlers, manage retries, and deal with out-of-order events. But Server-Sent Events with Turbo Streams give you real-time updates with 10 lines of code."

**Power Words Used:** Subject (you), Action (need/set up), Objective (real-time updates), Contrast (webhooks → SSE, complex → 10 lines)

**Why It Works:** Challenges conventional wisdom, creates curiosity about your alternative approach.

---

### 2. The Problem/Solution Hook

**Template:**
```
[Hook] "If you're [doing X], you're [negative outcome]."
[Common Belief] "Most developers [describe the problematic approach]."
[Your Take] "Here's the [better way] that [specific improvement]."
```

**Example:**
"If you're using OpenAI's API for embeddings, you're overpaying by 10x. Most developers just reach for the most popular option without comparing costs. Here's how to switch to a local model in Rails without sacrificing quality."

**Why It Works:** Identifies a pain point, then promises a specific, measurable solution.

---

### 3. The Time-Based Challenge Hook

**Template:**
```
[Hook] "I'm going to [impressive outcome] in [short timeframe]."
[Common Belief] "Everyone thinks [task] takes [long time] because [reason]."
[Your Take] "But with [your approach], it's actually [short time]. Watch."
```

**Example:**
"I'm going to add AI chat to a Rails app in under 10 minutes. Everyone thinks you need days of setup—API configuration, streaming logic, frontend complexity. But with Claude's SDK and Hotwire, it's three files. Let me show you."

**Power Words Used:** Subject (I), Action (add), Objective (AI chat to Rails app), Contrast (days → 10 minutes, complex → three files), Time (10 minutes)

**Why It Works:** Sets clear, bold expectations. Creates urgency to see if you can actually do it.

---

### 4. The Discovery Hook

**Template:**
```
[Hook] "I just discovered [surprising insight] and it changed [common task]."
[Common Belief] "Most people still [old approach] because [assumption]."
[Your Take] "[New discovery] means you can [better outcome]. Here's proof."
```

**Example:**
"I just discovered you can stream Claude's responses directly into Turbo Frames. Most developers still use JavaScript and WebSockets because they think that's the only way. But Turbo Streams handle it natively and it makes Rails AI apps feel instant."

**Why It Works:** Positions you as sharing fresh discovery, not recycling known information.

---

### 5. The Mistake Prevention Hook

**Template:**
```
[Hook] "Don't [common action] until you [correct approach]."
[Common Belief] "Everyone [makes mistake] because [they don't know X]."
[Your Take] "But if you [do this instead], you avoid [negative outcome]. Here's how."
```

**Example:**
"Don't deploy your Rails AI feature until you add request timeouts. Everyone forgets this because APIs work fine in development. But when Claude's API is slow, your entire app hangs. Here's the production-ready pattern."

**Why It Works:** Leverages fear of making mistakes. Developers especially want to avoid production issues.

---

### 6. The Comparison Hook

**Template:**
```
[Hook] "I tested [X] vs [Y]. Here's what actually performed better."
[Common Belief] "Most people assume [popular option] is best because [reason]."
[Your Take] "But my tests show [surprising winner] because [data]. Let me show you."
```

**Example:**
"I tested Claude vs GPT-4 for Rails code generation. Most people assume GPT-4 is better because it's been around longer. But Claude actually wrote more idiomatic Rails code and understood Hotwire patterns better. Here are the benchmarks."

**Why It Works:** Developers love data and benchmarks. Creates curiosity about unexpected results.

---

### 7. The Skill Showcase Hook

**Template:**
```
[Hook] "Here's the [technique] that [impressive outcome]."
[Common Belief] "Most people struggle with [problem] because [they do X]."
[Your Take] "This [specific technique] solves it by [mechanism]. Watch it work."
```

**Example:**
"Here's the caching strategy that dropped my Claude API costs by 80%. Most people pay full price for every request because they cache by exact prompt match. This semantic similarity approach caches near-matches too. Let me show you the numbers."

**Power Words Used:** Subject (implied: I/my), Action (dropped), Objective (API costs by 80%), Contrast (full price → 80% reduction, exact match → semantic), Proof (80% = specific number, "the numbers")

**Why It Works:** Promises concrete, measurable improvement with a specific technique.

---

### 8. The "I Wish I Knew" Hook

**Template:**
```
[Hook] "I wish I knew [insight] before [starting task]."
[Common Belief] "Most people [make mistake] when they start because [assumption]."
[Your Take] "Knowing [this] would have saved [time/money]. Here's what to do instead."
```

**Example:**
"I wish I knew about prompt caching before building my RAG system. Most people architect the whole thing without knowing about it. I would've saved 200 hours and $500. Here's how to design for it from day one."

**Why It Works:** Creates relatability through shared struggle, offers the shortcut you wish you'd had.

---

### 9. The "Nobody's Talking About" Hook

**Template:**
```
[Hook] "Why is nobody talking about [overlooked feature]?"
[Common Belief] "Everyone's focused on [popular thing] and missing [this]."
[Your Take] "[Feature] literally [impressive benefit]. Let me show you."
```

**Example:**
"Why is nobody talking about Claude's prompt caching? Everyone's optimizing prompt length and token counts. But prompt caching literally cuts API costs in half for Rails apps. Here's how to implement it."

**Why It Works:** Makes viewers feel like they're getting insider knowledge others are missing.

---

### 10. The Live Demo Hook

**Template:**
```
[Hook] "Watch what happens when I [perform action]."
[Common Belief] "Most people think [task] requires [complex approach]."
[Your Take] "It's actually [simple approach]. Let me prove it live."
```

**Example:**
"Watch what happens when I ask Claude to refactor this entire controller. Most people think AI can't handle Rails-specific patterns like concerns and service objects. But with the right custom instructions, it's better than most developers. Here's the prompt."

**Why It Works:** Immediate action creates curiosity. Viewers want to see if it actually works.

---

## Technical Content Best Practices

### Do:
- **Be specific with technologies:** "Hotwire" not "real-time updates"
- **Use concrete numbers:** "80% faster" not "much faster"  
- **Show, don't just tell:** Start typing code or showing terminal immediately
- **Front-load the value:** Say what they'll learn in the first sentence
- **Match expertise level:** Don't over-explain Rails basics if targeting experienced devs
- **Create contrast:** Make the distance between common belief and your take as large as possible
- **Deliver immediately:** Start demonstrating within 20 seconds

### Don't:
- **Spend time introducing yourself** (save for the description)
- **Ask rhetorical questions** ("Have you ever wondered...?")
- **Use generic openings** ("In this video, I'm going to show you...")
- **Bury the lede:** Don't save the best part for later
- **Over-promise:** Your hook must match what the video delivers
- **Waste the first 20 seconds:** Urgency to solve their pain point is highest right after they click

---

## Testing Your Hook

Ask yourself:

1. **Would I click away?** Be honest. If it's not compelling to you, it won't be to viewers.

2. **Is the value clear in 5 seconds?** Read the hook out loud. Count the seconds.

3. **Does the full 20-second opening create tension?** Is there real distance between the common belief and your take?

4. **Does it match the video content?** Don't promise something you don't deliver.

5. **Is it specific enough?** "Better RAG" is vague. "RAG with 80% lower latency using Postgres" is specific.

6. **Do I deliver on the promise within 30 seconds?** Don't make them wait. Show the code, demo, or result immediately.

7. **Does it have all 4 core power words?** Subject, Action, Objective, Contrast. If any are missing, the hook is probably weak.

8. **Could Proof or Time make it stronger?** These optional intensifiers can significantly boost curiosity.

---

## Hook Analysis Template

Use this template to reverse-engineer any successful hook:

```
HOOK TEXT: "[paste the hook here]"

COMPONENT BREAKDOWN:
- Subject:    [who/what is the hook about?]
- Action:     [what verb drives the hook?]
- Objective:  [what outcome/result?]
- Contrast:   [base state vs new state?]
- Proof:      [credentials or evidence?] (optional)
- Time:       [urgency or speed?] (optional)

WHAT MAKES IT WORK:
[Why does this hook create curiosity? What's the tension?]

HOW TO ADAPT:
[What would this look like for your topic?]
```

### Example Analysis

**Hook:** "I tested Claude vs GPT-4 for Rails code generation. Here are the benchmarks."

```
COMPONENT BREAKDOWN:
- Subject:    I
- Action:     tested
- Objective:  determine which is better for Rails code generation
- Contrast:   Claude vs GPT-4 (comparison = inherent contrast)
- Proof:      "benchmarks" (data = proof)
- Time:       Not used

WHAT MAKES IT WORK:
Developers have strong opinions about AI models. The comparison
format + promise of benchmarks creates curiosity about the winner.

HOW TO ADAPT:
"I tested [Tool A] vs [Tool B] for [specific use case]. Here's what won."
```

---

## Examples from Your Niche

### For Rails + AI tutorials:
- "This one Rails concern made my Claude responses 3x faster. Most developers inline all their AI logic in controllers. But extracting to a concern with prompt caching changes everything."

- "I broke every Rails convention building this AI feature, and it was worth it. The Rails Way says fat models, skinny controllers. But AI features need a completely different architecture. Here's what worked."

- "Here's how Basecamp would build AI chat using their own tools. Everyone reaches for React and WebSockets. But Hotwire handles streaming AI with zero JavaScript."

### For Claude-specific content:
- "Claude's new prompt caching makes Rails background jobs obsolete for AI tasks. Everyone queues AI requests to avoid blocking. But with sub-100ms cached responses, you can do it inline."

- "I spent $200 testing every Claude model for Rails apps. Most people just use Sonnet because it's the default. But Haiku is faster and cheaper for 80% of Rails use cases. Here's the breakdown."

- "This prompt template gets Claude to write better Rails code than most developers. Everyone uses generic 'write code' prompts. But teaching it Rails conventions and your app's patterns changes the output quality completely."

### For workflow/productivity:
- "I automated my entire Rails deployment with Claude Code in 15 minutes. Everyone manually configures Kamal, database.yml, and environment variables. But Claude Code can read your existing setup and handle it all."

- "Watch Claude Code fix a production bug while I explain what it's doing. Most people think AI can't debug Rails apps. But with the right context, it's faster than manual debugging."

---

## The Golden Rule

Your opening should answer one question: **"Why should a busy developer stop scrolling and watch this?"**

Answer it in 5 seconds. Prove it in 20 seconds. Or they'll bounce.

The viewer's urgency to solve their pain point is **highest** right after they click. Don't waste it with intros, explanations, or preamble. Deliver value immediately.
