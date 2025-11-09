# Thoughtbot RSpec Patterns

## Syntax & Expectations

### Use Modern RSpec Syntax
- Use RSpec's `expect` syntax (not `should`)
- Use RSpec's `allow` syntax for method stubs (not `stub`)
- Prefer `eq` over `==` in RSpec assertions
- Use `not_to` instead of `to_not` in expectations

**Examples:**
```ruby
# Good
expect(user.name).to eq('John')
expect(response).not_to be_nil
allow(service).to receive(:call).and_return(result)

# Bad
user.name.should == 'John'
response.should_not be_nil
service.stub(:call).and_return(result)
```

### Capybara Matchers
Prefer the `have_css` matcher to the `have_selector` matcher in Capybara assertions:

```ruby
# Good
expect(page).to have_css('.success-message')

# Less preferred
expect(page).to have_selector('.success-message')
```

## Test Structure

### Separate Test Phases
Separate setup, exercise, verification, and teardown phases with newlines:

```ruby
it 'creates a new project' do
  # Setup
  user = create(:user)
  attributes = {name: 'Test Project'}

  # Exercise
  project = Project.create(attributes)

  # Verification
  expect(project).to be_persisted
  expect(project.name).to eq('Test Project')
end
```

### Single Level of Abstraction
Use a single level of abstraction within `it` examples:

```ruby
# Good
it 'notifies the user' do
  perform_action
  expect_notification_sent
end

# Bad - mixing abstraction levels
it 'notifies the user' do
  click_button 'Submit'
  expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
end
```

### One Test Per Execution Path
Use an `it` example or test method for each execution path through the method.

## What to Avoid

### Don't Test Private Methods
- Never use the `private` keyword in specs
- Don't test private methods
- Test public interface and let private methods be covered indirectly

### Avoid Let and Let!
Extract helper methods instead:

```ruby
# Good
def create_authenticated_user
  user = create(:user)
  sign_in(user)
  user
end

it 'shows dashboard' do
  user = create_authenticated_user
  visit dashboard_path
  expect(page).to have_content(user.name)
end

# Avoid
let!(:user) { create(:user) }
before { sign_in(user) }

it 'shows dashboard' do
  visit dashboard_path
  expect(page).to have_content(user.name)
end
```

### Avoid Subject
Avoid using `subject` explicitly inside of an RSpec `it` block:

```ruby
# Good
subject { user.name }
it { is_expected.to eq('John') }

# Avoid
it 'has correct name' do
  expect(subject).to eq('John')
end
```

### Avoid Instance Variables
Don't use instance variables in tests:

```ruby
# Good
let(:user) { create(:user) }

# Avoid
before { @user = create(:user) }
```

### Avoid Other Constructs
- Avoid `its`, `specify`, and `before` in RSpec (prefer explicit tests)
- Avoid `any_instance` in rspec-mocks and mocha; prefer dependency injection

### Skip Boolean Equality Checks
Use predicate methods and matchers instead:

```ruby
# Good
expect(user).to be_valid
expect(project).to be_persisted

# Avoid
expect(user.valid?).to eq(true)
expect(project.persisted?).to be_truthy
```

## Mocking & Stubbing

### Use Stubs and Spies, Not Mocks
- Use stubs and spies (not mocks) in isolated tests
- Use assertions about state for incoming messages
- Use stubs and spies to assert you sent outgoing messages

**Example:**
```ruby
# Good - stub
allow(service).to receive(:call).and_return(result)

# Good - spy
service = spy('service')
controller.notify(service)
expect(service).to have_received(:call)
```

### Disable Real HTTP Requests
Use `WebMock.disable_net_connect!` to prevent real HTTP requests to external services.

Use a Fake to stub requests to external services:

```ruby
class FakeGitHubAPI
  def initialize(stubs = {})
    @stubs = stubs
  end

  def get_user(username)
    @stubs.fetch(username) { default_user }
  end

  private

  def default_user
    {name: 'Test User', email: 'test@example.com'}
  end
end
```

## Acceptance/System Tests

### Use Specific Selectors
- Use the most specific selectors available
- Don't locate elements with CSS selectors or `[id]` attributes
- Use accessible names and descriptions to locate elements
- Interact with form controls, buttons, and links by accessible names

**Good:**
```ruby
click_button 'Create Project'
fill_in 'Project Name', with: 'Test Device'
click_link 'Settings'
```

**Avoid:**
```ruby
find('#create-project-btn').click
find('.project-name-input').set('Test Device')
find('a[href="/settings"]').click
```

### Don't Assert on Classes or Data Attributes
- Don't assert an element's state with `[class]` or `[data-*]` attributes
- Use WAI-ARIA States and Properties when asserting an element's state
- Prefer implicit semantics and built-in attributes over WAI-ARIA

**Good:**
```ruby
expect(page).to have_css('button[disabled]')
expect(page).to have_css('[aria-hidden="false"]')
expect(page).to have_content('Success message')
```

**Avoid:**
```ruby
expect(page).to have_css('.opacity-100')
expect(page).to have_css('.bg-red-500')
expect(page).to have_css('[data-visible="true"]')
```

### Avoid Meaningless Descriptions
Avoid `it` block descriptions that add no information:

```ruby
# Avoid
it 'successfully creates project' do

# Good
it 'creates project and redirects to project page' do
```

Avoid repetitive descriptions between `describe` and `it` blocks:

```ruby
# Avoid
describe 'creating a project' do
  it 'creates a project' do

# Good
describe 'project creation' do
  it 'redirects to the new project' do
```

### System Spec Organization
- Use file names like `user_changes_password_spec.rb` (role_action format)
- Store system specs in `spec/system` directory
- Place helper methods in a top-level `System` module
- Use only one `describe` block per system spec file

**Example:**
```ruby
# spec/system/user_creates_project_spec.rb
require 'rails_helper'

RSpec.describe 'User creates project' do
  it 'creates a new project' do
    # test implementation
  end
end
```

## Unit Tests

### Imperative Descriptions
Don't prefix descriptions with "should"; use imperative mood:

```ruby
# Good
it 'validates presence of name' do

# Bad
it 'should validate presence of name' do
```

### Use Subject Blocks
Use `subject` blocks to define objects for use in one-line specs:

```ruby
subject { Project.new(name: 'Test') }

it { is_expected.to be_valid }
```

### Method Documentation Conventions
- Use `.method` to describe class methods
- Use `#method` to describe instance methods

```ruby
describe '.find_by_name' do
  # class method tests
end

describe '#save' do
  # instance method tests
end
```

### Context for Preconditions
Use `context` to describe testing preconditions:

```ruby
context 'when user is admin' do
  # tests for admin users
end

context 'with valid parameters' do
  # tests for valid scenarios
end
```

### Test Organization
- Group tests by method using `describe '#method_name'`
- Maintain single, top-level `describe ClassName` block
- Order tests matching class definition: validations, associations, methods

**Example:**
```ruby
RSpec.describe Project do
  describe 'validations' do
    # validation tests
  end

  describe 'associations' do
    # association tests
  end

  describe '#save' do
    # instance method tests
  end

  describe '.find_active' do
    # class method tests
  end
end
```

## Factories

### Factory Organization
Organize `factories.rb`:
1. Sequences
2. Traits
3. Factory definitions

Order factory attributes:
1. Implicit associations first
2. Explicit attributes
3. Child factories (alphabetical within sections)

Sort factory definitions alphabetically.

**Example:**
```ruby
FactoryBot.define do
  # Sequences
  sequence :email do |n|
    "user-#{n}@example.com"
  end

  # Factories (alphabetically)
  factory :project do
    # Associations (implicit)
    tenant
    created_by factory: %i[user]

    # Attributes (alphabetical)
    device_description { "A medical device..." }
    fda_class { :class_ii_assumed }
    name { "Heart Rate Monitor" }
    software_safety_class { :to_be_determined }

    # Traits (alphabetically)
    trait :class_ii do
      fda_class { :class_ii_confirmed }
    end

    trait :with_github_repo do
      github_repo_owner { "organization" }
      github_repo_name { "awesome-repo" }
    end
  end
end
```

## Integration Testing

### Test the Entire App
Use integration tests to execute the entire app stack, including:
- Database operations
- Background jobs
- External service interactions (stubbed)
- Full request/response cycle

### Background Jobs
Test background jobs with appropriate matchers for your job processor (Sidekiq, DelayedJob, etc.).
