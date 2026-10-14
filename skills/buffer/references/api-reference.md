# Buffer GraphQL API Reference

Complete type definitions for the Buffer GraphQL API at `https://api.buffer.com`.

## Input Types

### CreatePostInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `channelId` | String | Yes | ID of the channel to post to |
| `text` | String | Yes | Post content/body text |
| `schedulingType` | SchedulingType | No | How the post should be scheduled |
| `mode` | PostMode | No | When/how to publish the post |
| `dueAt` | String | No | ISO 8601 datetime for custom scheduling. Required when mode is `customSchedule` |
| `assets` | PostAssetsInput | No | Media attachments (images) |

### PostAssetsInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `images` | [PostImageInput] | No | Array of image attachments |

### PostImageInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `url` | String | Yes | Publicly accessible URL of the image |

### PostsInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `organizationId` | String | Yes | Organization ID to query posts for |
| `filter` | PostFilter | No | Filter criteria for posts |
| `sort` | PostSort | No | Sort order for results |
| `first` | Int | No | Number of results to return (pagination) |
| `after` | String | No | Cursor for next page (Relay pagination) |

### PostFilter

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `status` | PostStatus | No | Filter by post status |
| `channelIds` | [String] | No | Filter by specific channel IDs |
| `startDate` | String | No | ISO 8601 start date for date range |
| `endDate` | String | No | ISO 8601 end date for date range |

### PostSort

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `field` | String | Yes | Field to sort by (e.g., `dueAt`, `createdAt`) |
| `direction` | String | Yes | Sort direction: `asc` or `desc` (lowercase) |

### ChannelsInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `organizationId` | String | Yes | Organization ID to list channels for |

### CreateIdeaInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `organizationId` | String | Yes | Organization ID to create idea in |
| `content` | IdeaContentInput | Yes | Idea content object |

### IdeaContentInput

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | String | No | Short title for the idea |
| `text` | String | No | Full idea content or draft text |
| `tags` | [TagInput] | No | Existing tag objects (with `id` and `color` fields) — fetch tags first |
| `services` | [String] | No | Target social media services |

## Enums

### ShareMode

The GraphQL enum type is named `ShareMode` (the `mode` field's type), not `PostMode`. Confirmed via introspection — only these four values exist:

| Value | Description |
|-------|-------------|
| `addToQueue` | Add post to the end of the scheduling queue |
| `shareNow` | Publish the post immediately |
| `shareNext` | Add post to the front of the queue (next to be published) |
| `customScheduled` | Schedule for a specific date/time (requires `dueAt` field) — note the trailing `d` |

### SchedulingType

| Value | Description |
|-------|-------------|
| `automatic` | Buffer handles publishing automatically |
| `notification` | Send a push notification reminder instead of auto-publishing |

### PostStatus

| Value | Description |
|-------|-------------|
| `scheduled` | Post is queued and waiting to be published |
| `sent` | Post has been successfully published |
| `draft` | Post is saved as a draft |
| `error` | Post failed to publish |
| `needs_approval` | Post requires approval before publishing |
| `sending` | Post is currently being published |

### Service

| Value | Description |
|-------|-------------|
| `twitter` | Twitter / X |
| `instagram` | Instagram |
| `linkedin` | LinkedIn |
| `facebook` | Facebook |
| `pinterest` | Pinterest |
| `tiktok` | TikTok |
| `mastodon` | Mastodon |
| `youtube` | YouTube |
| `threads` | Threads |
| `bluesky` | Bluesky |

## Output Types

### Account

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Account ID |
| `name` | String | Account holder name |
| `email` | String | Account email address |
| `timezone` | String | Account timezone |
| `organizations` | [Organization] | Associated organizations |

### Organization

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Organization ID |
| `name` | String | Organization name |
| `ownerEmail` | String | Email of the organization owner |

### Channel

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Channel ID |
| `name` | String | Channel username/handle |
| `displayName` | String | Display name for the channel |
| `service` | Service | Social media platform |
| `avatar` | String | URL to channel avatar image |
| `isQueuePaused` | Boolean | Whether the posting queue is paused |

### Post

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Post ID |
| `text` | String | Post content |
| `status` | PostStatus | Current post status |
| `dueAt` | String | Scheduled publish time (ISO 8601) |
| `sentAt` | String | Actual publish time (ISO 8601) |
| `createdAt` | String | Creation time (ISO 8601) |
| `channelService` | String | Service name of the target channel |
| `externalLink` | String | URL to the published post on the platform |

### PostActionSuccess

Union member returned on successful post creation/update.

| Field | Type | Description |
|-------|------|-------------|
| `post` | Post | The created or updated post |

### MutationError

Union member returned when a mutation fails validation.

| Field | Type | Description |
|-------|------|-------------|
| `message` | String | Human-readable error description |

### Idea

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Idea ID |
| `content` | [IdeaContent] | Array of idea content items |

### IdeaContent

| Field | Type | Description |
|-------|------|-------------|
| `title` | String | Idea title |
| `text` | String | Idea body text |
| `tags` | [String] | Associated tags |
| `services` | [String] | Target social media services |

### CreateIdeaSuccess

Union member returned on successful idea creation.

| Field | Type | Description |
|-------|------|-------------|
| `idea` | Idea | The created idea |

## Pagination (Relay)

Posts use Relay-style cursor pagination:

```graphql
{
  posts(input: { organizationId: "...", first: 20, after: "cursor..." }) {
    edges {
      node { id text status dueAt }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
    totalCount
  }
}
```

- `first`: Number of items per page
- `after`: Pass `pageInfo.endCursor` from the previous response to get the next page
- `hasNextPage`: Boolean indicating if more results exist
- `totalCount`: Total number of matching posts
