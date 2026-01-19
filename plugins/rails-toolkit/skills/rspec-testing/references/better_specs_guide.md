# Better Specs - RSpec Best Practices

## Describe Blocks

Use Ruby documentation conventions when naming describe blocks:
- `.method_name` for class methods
- `#method_name` for instance methods

**Example:**
```ruby
describe '.authenticate' do
  # tests for class method
end

describe '#admin?' do
  # tests for instance method
end
```

## Context Blocks

Organize tests with contexts using descriptive language:
- Start descriptions with "when," "with," or "without"
- Groups related behaviors and improves readability

**Example:**
```ruby
context 'when logged in' do
  it { is_expected.to respond_with 200 }
end

context 'with valid parameters' do
  # tests for valid scenarios
end

context 'without authentication' do
  # tests for unauthorized scenarios
end
```

## It Blocks

Keep test descriptions concise—ideally under 40 characters. Split longer descriptions into contexts instead.

Use third-person present tense without "should":

**Good:**
```ruby
it 'does not change timings' do
it 'creates a new project' do
it 'redirects to the dashboard' do
```

**Bad:**
```ruby
it 'should not change timings' do
it 'should create a new project' do
```

## Single Expectations

Isolated unit tests should contain one expectation per test. This makes tests:
- Easier to understand
- Easier to debug when they fail
- More maintainable

For slower, non-isolated tests (database, external services), multiple expectations are acceptable for performance reasons.

**Good (unit test):**
```ruby
it 'validates presence of name' do
  project = Project.new(name: nil)
  expect(project).not_to be_valid
end

it 'adds error message for missing name' do
  project = Project.new(name: nil)
  project.valid?
  expect(project.errors[:name]).to include("can't be blank")
end
```

**Acceptable (integration/system test):**
```ruby
it 'creates a project and redirects' do
  expect do
    post :create, params: {project: valid_attributes}
  end.to change(Project, :count).by(1)

  expect(response).to redirect_to(Project.last)
  expect(flash[:notice]).to eq('Project created successfully')
end
```

## Test All Cases

Cover valid, edge, and invalid scenarios. Test "all the possible inputs."

**Example:**
```ruby
describe 'validations' do
  it 'validates presence of name'
  it 'validates length of name'
  it 'validates uniqueness of name'
  it 'allows valid names'
end
```

## Expect vs Should Syntax

Always use `expect()` syntax on new projects (not `should`):

**Good:**
```ruby
expect(response).to respond_with_content_type(:json)
expect(user).to be_valid
```

**Bad (deprecated):**
```ruby
response.should respond_with_content_type(:json)
user.should be_valid
```

For one-line expectations, use `is_expected.to`:

**Good:**
```ruby
it { is_expected.to be_valid }
it { is_expected.to respond_with 422 }
```

## Subject Usage

Use `subject {}` to DRY up multiple related tests:

**Good:**
```ruby
subject { assigns('message') }

it { is_expected.to match /pattern/ }
it { is_expected.to be_present }
```

**When not to use subject:**
- Avoid using `subject` explicitly inside `it` blocks
- If you need to name it, use `let` instead

## Let vs Before

Prefer `let` over `before` blocks for variable assignment. Variables defined with `let`:
- Are lazy loaded (only evaluated when referenced)
- Are cached during each test
- Make dependencies explicit

Use `let!` when you need immediate evaluation (before the test runs).

**Good:**
```ruby
let(:resource) { create :device }
let(:user) { create :user }
```

**When to use before:**
- Setting up global test state
- Configuring mocks/stubs
- Database cleanup

**Example:**
```ruby
before do
  # Freeze time for consistent test results
  freeze_time
end
```

## Mocking Strategy

"Do not (over)use mocks and test real behavior when possible."

Test actual application flow rather than stubbed interactions when feasible. Mocks are useful for:
- External services
- Slow operations
- Testing error conditions

But prefer real objects for:
- Simple collaborators
- Fast operations
- Core business logic

## Data Creation

Create only necessary test data. Use `create_list` sparingly.

**Good:**
```ruby
let(:project) { create(:project) }
```

**Avoid:**
```ruby
let(:projects) { create_list(:project, 50) } # Usually unnecessary
```

## Factories Over Fixtures

Use FactoryBot instead of fixtures. Factories:
- Are easier to understand and maintain
- Reduce coupling between tests
- Make test data explicit
- Are easier to modify

**Example:**
```ruby
# spec/factories/projects.rb
FactoryBot.define do
  factory :project do
    name { "Heart Rate Monitor" }
    device_description { "A medical device..." }

    trait :class_ii do
      fda_class { :class_ii_confirmed }
    end
  end
end
```

## Shared Examples

Eliminate test duplication using shared examples, particularly for controller tests:

**Definition:**
```ruby
RSpec.shared_examples 'a listable resource' do
  it 'returns success' do
    expect(response).to have_http_status(:success)
  end

  it 'assigns resources' do
    expect(assigns(:resources)).to be_present
  end
end
```

**Usage:**
```ruby
describe 'GET #index' do
  it_behaves_like 'a listable resource'
  it_behaves_like 'a paginable resource'
end
```

## Integration Testing

Focus on integration and model tests rather than controller tests. "Test what you see" using Capybara and RSpec.

Integration tests:
- Cover all use cases
- Run fast with proper setup
- Test actual user flows
- Catch more real bugs

## HTTP Stubbing

Stub external API calls using WebMock or VCR rather than relying on real services.

**Example:**
```ruby
before do
  stub_request(:get, "https://api.example.com/data")
    .to_return(status: 200, body: '{"status":"ok"}')
end
```
