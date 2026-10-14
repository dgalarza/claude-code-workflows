---
name: buttondown
description: "Interact with the Buttondown newsletter API to manage tags, automations, subscribers, and emails. Use this skill whenever the user mentions Buttondown, newsletter tags, newsletter automations, email subscribers, or wants to manage any aspect of their Buttondown newsletter -- even if they just say 'my newsletter' without explicitly naming Buttondown."
---

# Buttondown API Skill

This skill enables you to interact with the Buttondown newsletter platform via its REST API. The API follows standard RESTful conventions, so operations are straightforward CRUD calls.

## Authentication

All requests require the user's API key, available from https://buttondown.com/requests.

- Use the `BUTTONDOWN_API_KEY` environment variable
- Send it as: `Authorization: Token $BUTTONDOWN_API_KEY`

Before making any API call, verify the env var is set. If it's missing, tell the user to set it:
```
export BUTTONDOWN_API_KEY="your-api-key-here"
```

## Base URL

```
https://api.buttondown.com/v1
```

All endpoint paths below are relative to this base.

## Making Requests

Use `curl` for all API calls. Standard patterns:

```bash
# GET (list/retrieve)
curl -s -H "Authorization: Token $BUTTONDOWN_API_KEY" \
  "https://api.buttondown.com/v1/{resource}"

# POST (create)
curl -s -X POST \
  -H "Authorization: Token $BUTTONDOWN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"field": "value"}' \
  "https://api.buttondown.com/v1/{resource}"

# PATCH (update)
curl -s -X PATCH \
  -H "Authorization: Token $BUTTONDOWN_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"field": "new_value"}' \
  "https://api.buttondown.com/v1/{resource}/{id}"

# DELETE
curl -s -X DELETE \
  -H "Authorization: Token $BUTTONDOWN_API_KEY" \
  "https://api.buttondown.com/v1/{resource}/{id}"
```

Pipe responses through `jq` for readable output. Use `jq -r` when extracting specific values.

## Pagination

List endpoints return paginated results. The response includes:
- `count`: total number of results
- `next`: URL for next page (null if last page)
- `previous`: URL for previous page (null if first page)
- `results`: array of objects

To fetch all results, follow `next` URLs until null.

---

## Tags

Tags help organize subscribers into groups.

### List tags
```
GET /tags
```
Returns all tags. Each tag has `id`, `name`, `color`, `description`, and `creation_date`.

### Create a tag
```
POST /tags
```
Body: `{"name": "tag-name", "color": "#hex"}` (name and color are required). Optional fields: `description`.

### Retrieve a tag
```
GET /tags/{id}
```

### Update a tag
```
PATCH /tags/{id}
```
Body: any fields to update (e.g., `{"name": "new-name", "color": "#ff0000"}`).

### Delete a tag
```
DELETE /tags/{id}
```

---

## Automations

Automations perform actions automatically based on triggers. Each automation has three parts:

1. **Trigger** -- the event that starts it (e.g., a new subscriber confirms)
2. **Filter** (optional) -- criteria that narrow when it runs
3. **Actions** -- what happens (send email, add tag, send webhook, post to social media, etc.)

Automations can be active or paused. Changes to automation emails affect all future subscribers, including those waiting on a delayed action. Changes to the action list only affect subscribers who trigger the automation after the change.

### List automations
```
GET /automations
```

### Create an automation
```
POST /automations
```
Body includes trigger configuration and actions. Key fields:
- `name`: descriptive name for the automation
- `trigger`: the event that starts it (e.g., `subscriber.tags.changed`, `subscriber.confirmed`, `subscriber.created`, `email.sent`)
- `status`: `"active"` or `"inactive"`
- `filters`: object with `filters` array, `groups` array, and `predicate` (`"and"` or `"or"`)
- `actions`: array of action objects with timing

#### Filter fields
- `tags` -- matches subscribers who have a specific tag
- `special.tags_changed` -- matches when a specific tag was just added (use this for tag-based automations to avoid re-triggering)

#### send_email action structure
Automation emails are defined inline in the action, not as separate email objects:
```json
{
  "type": "send_email",
  "metadata": {
    "subject": "Email subject",
    "body": "<!-- buttondown-editor-mode: fancy -->Email body in markdown",
    "email_id": "",
    "template": ""
  },
  "timing": {
    "time": "immediate",
    "delay": {"value": "0", "unit": "days", "time_of_day": null}
  }
}
```
For delayed emails, set `time` to `"delay"` and adjust the `delay` object (e.g., `{"value": "3", "unit": "days"}`).

### Retrieve an automation
```
GET /automations/{id}
```

### Update an automation
```
PATCH /automations/{id}
```

### Delete an automation
```
DELETE /automations/{id}
```

### Available action types
- **Send email** -- send a specific email to the subscriber
- **Add tag** -- tag the subscriber
- **Send webhook** -- POST to an external URL
- **Post to social media** -- share to Bluesky, LinkedIn, or Twitter (requires connected integrations)
- **Send Discord invitation** -- invite subscriber to a Discord server

Each action can be immediate or delayed (e.g., "send welcome email immediately, then add VIP tag after 7 days").

---

## Subscribers

For reference, though not the primary focus of this skill, the subscriber endpoints are available:

### List subscribers
```
GET /subscribers
```

### Create a subscriber
```
POST /subscribers
```
Required: `email_address`. Optional: `type` ("regular" to skip double opt-in), `tags` (array), `metadata` (object), `ip_address`.

### Update a subscriber
```
PATCH /subscribers/{id_or_email}
```
Accepts either subscriber ID or email address as the identifier. Note: changing type from `premium` to `unsubscribed` will cancel the subscriber's Stripe subscription.

### Delete a subscriber
```
DELETE /subscribers/{id}
```

---

## Emails

For reference, email/newsletter endpoints:

### List emails
```
GET /emails
```

### Create an email
```
POST /emails
```
The API auto-detects content type (plain text, HTML, or Markdown). You can explicitly set the format with a comment at the start of the body:
- `<!-- buttondown-editor-mode: plaintext -->`
- `<!-- buttondown-editor-mode: fancy -->`

Note: the API rejects bodies starting with YAML frontmatter (`---`). To bypass, include the header `X-Buttondown-Live-Dangerously: true`.

### Retrieve an email
```
GET /emails/{id}
```

---

## Tips

- Always show the user what you're about to do before making destructive calls (DELETE, bulk updates). Confirm with them first.
- When listing resources, format the output as a clean table or summary rather than dumping raw JSON.
- If a create/update call fails, check the response body for error details and relay them clearly.
- The API returns UUIDs as IDs. When the user refers to a tag or automation by name, list first to find the matching ID.
