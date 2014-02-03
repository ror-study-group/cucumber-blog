# Outside-In Rails Development

##Intro info to confuse you
Important. NOTE: This overview is specific to rails but you should also know how to test OUTSIDE of rails.

### TDD vs. BDD
***
**TDD** - A developer practice that involves writing tests before writing the code being tested.

**BDD** - Favors *behavior* over structure, and it does so at every level of development. Think more about interactions between people and systems, or between objects, than about the structure of objects.

### Testing options
***
#### Unit Testing
*Granular. Tests the smallest unit of functionality, typically a method/function.*

**TestUnit** - Stock with rails. Specify and test one point of the contract of single method of a class. This should have a very narrow and well defined scope.

**RSpec** - Popular testing suite. Similar to TestUnit but easier and more convenient. Has autotest, highlighting syntax, shortcut commands like `rake spec`.

**Minitest** - Another popular testing suite. A matter of taste. More similar to TestUnit. Overall, it's a bit like Sinatra vs. Rails.

**FactoryGirl** - Generally speaking, FactoryGirl allows you to make objects (such as users, posts or comments) without creating real-deal ActiveRecord objects. It allows you to configure what a standard instance of any ActiveRecord database object should look like in a central place so that your test code is clutter-free.
More info: [Rails Testing — Factory Girl](http://www.hiringthing.com/2012/08/17/rails-testing-factory-girl.html#sthash.t30UMlFy.dpuf)

#### Acceptance Testing
*Checks a particular feature for correctness by comparing the results for a given input against the specification.*

**Capybara** - Tool to write integration tests that interact with a website the way a human would. This example uses RSpec:

	describe "the signup process", :type => :feature do
	  before :each do
	    User.make(:email => 'user@example.com', :password => 'caplin')
	  end	  
	  
	  it "signs me in" do
	    visit '/sessions/new'
	    within("#session") do
	      fill_in 'Login', :with => 'user@example.com'
	      fill_in 'Password', :with => 'password'
	    end
	    click_link 'Sign in'
	    page.should have_content 'Success'
	  end
	  
	end
	
**Webrat** - Used in the *Cucumber Book*. Similar to Capybara, you probably wouldn't use both simultaneously. Capybara has more architectural flexibility. 

**Cucumber** - Tool to write acceptance tests with almost plain-text, **business-readable domain-specific language**. It is useful to pass around to **non-developers** but also requires some code mapped into it to actually work (the step definitions).
	
	Scenario: Signup process
	
	Given a user exists with email "user@example.com" and password "caplin"
	When I try to login with "user@example.com" and "caplin"
	Then I should be logged in successfully
	
**Selenium** - Framework used to test web applications by simulating a user interacting with a web browser. When you run these tests a browser is opened and you can actually watch the tests taking place.



### BDD Cycle
***
Two levels of testing. Two concentric circles.
Red, Green, Refactor


![BDD Cycle Diagram](http://i.stack.imgur.com/mtLAM.png)


	1. Focus on one scenario for a specific behavior (Acceptance Test aka Cucumber)
	2. Write failing step definition (Cucumber)
		3. Write failing example (Unit Test aka Rspec)
			4. Get the example to pass (Rspec)
		5. Commit!
		6. Refector (Rspec)		
	7. Refactor (Cucumber)
	
##Okay, let's fire this shit up
We're going to build a simple blog using RSpec, Capybara, FactoryGirl, *and* Cucumber.

`$ rails new simple_blog`

`$ cd simple_blog`

`$ vi gemfile` or `subl gemfile` but you ought to learn VIM.

####Gemfile

	group :test do
	  gem "cucumber-rails"
	  gem "database_cleaner" #ensure a clean state during tests
	  gem "guard-rspec" #automatically runs specs
	  gem "terminal-notifier-guard" #growl notifications
	  gem "simplecov" #code coverage analysis tool
	end

	group :development do
	  gem "pry"
	  gem "better_errors"
	  gem "binding_of_caller" #grab bindings from higher up the call stack
	end

	group :development, :test do
	  gem "rspec-rails"
	  gem "sqlite3" #remove this from above and put it here
	  gem "factory_girl_rails"
	  gem "capybara"
	  gem "launchy" #launch browser from command line
	end

`$ bundle`

####Installing
`$ rails g rspec:install`

	create  .rspec                                                                      
    create  spec                                                                        
    create  spec/spec_helper.rb

`$ rails g cucumber:install`

	create  config/cucumber.yml
	create  script/cucumber
	 chmod  script/cucumber
	create  features/step_definitions
	create  features/support
	create  features/support/env.rb
	 exist  lib/tasks
	create  lib/tasks/cucumber.rake
	  gsub  config/database.yml
	  gsub  config/database.yml
	 force  config/database.yml


####Rake Everything
`$ rake db:migrate`
`$ rake db:test:prepare`

`$ rake spec`

	No examples found.
	
	
	Finished in 0.0001 seconds
	0 examples, 0 failures

Cool, RSpec works and found no tests. Let's do try Cucumber:
`$ rake cucumber`

	Using the default profile...
	0 scenarios
	0 steps
	0m0.000s

Great! Let's write a scenario!

####Start with Cucumber
***
Remember the BDD Cycle? We have to start with a failing (red) Acceptance Test. In this case, our Acceptance Tests will written with Cucumber.

#####Features
In Cucumber we make a **Feature** first and a Feature includes one or more **Scenarios**.

Although Features are written in almost-plain English, it still helps to have a few rules. Thus, we have *The Connextra Format* aka *user story format*, a key element of any Agile producton team.
	
	Feature: <feature name>
	
		As a <role>		I want <feature>		So that <business value>

A popular alternative:
	
	Feature: <feature name>
	
		In order to <business value> 
		As a <role>
		I want <feature>

After we have the basic idea (the Feature), and it's description (Feature Narrative), we describe an applicable Scenario. Scenarios are written in *Given, When, Then* format.

	Scenario: <scenario name>
	
		Given <state of the world before an event>
		When <the event>
		Then <expected outcome>

 
An example will be less confusing… Let's make our own Feature. Start by creating a file named `create_post.feature` in the features directory with the following content:

*simple_blog/features/create_post.feature*

	Feature: Create Post
	
	  As a guest
	  I want to create a post
	  So that other guests can read it
	
	  Scenario: creating a blog post
	    Given there is a simple blog form
	    When I create a blog post
	    Then I should see "First post" in the post title.
		And I should see "Hello World" in the post body.
			
Non-technical team members can understand this perfectly. And later on, these feature files can be very useful as documentation.

Don't be mistaken: Creating these concise, descriptive user stories is the bulk of the work when it comes to testing. You'll find that, once you start trying to answer your own questions, you'll realize that the story is too complicated, or that the feature is something entirely different.

Good tests take practice!

Anyway, we wrote a Feature. Lets see what happens when we run `$ cucumber`

	Feature: Create Post
	
	  As a guest
	  I want to create a post
	  So that other guests can read it
	
	  Scenario: creating a blog post
	    Given there is a simple blog form
	  	  Undefined step: "there is a simple blog form" (Cucumber::Undefined)
	      features/create_post.feature:8:in `Given there is a simple blog form'
		When I create a blog post
		  Undefined step: "I create a blog post" (Cucumber::Undefined)
	      features/create_post.feature:9:in `When I create a blog post'
	    Then I should see "First post" in the post title.
	      Undefined step: "I should see "First post" in the post title." (Cucumber::Undefined)
	      features/create_post.feature:10:in `Then I should see "First post" in the post title.'
	    And I should see "Hello World" in the post body.
	      Undefined step: "I should see "Hello World" in the post body." (Cucumber::Undefined)
	      features/create_post.feature:11:in `And I should see "Hello World" in the post body.'
	
	1 scenario (1 undefined)
	4 steps (4 undefined)
	0m1.078s
	
	You can implement step definitions for undefined steps with these snippets:
	
	Given(/^there is a simple blog form$/) do
	  pending # express the regexp above with the code you wish you had
	end
	
	When(/^I create a blog post$/) do
	  pending # express the regexp above with the code you wish you had
	end
	
	Then(/^I should see "(.*?)" in the post title\.$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end
	
	Then(/^I should see "(.*?)" in the post body\.$/) do |arg1|
	  pending # express the regexp above with the code you wish you had
	end

Ok, what the WT fuck, right? We see the feature and scenario text from the `create_post.feature` file, a summary of everything that was run, and then some code snippets at the end. 

The code snippets are telling you to ***implement step definitions for undefined steps*** and ***express the regexp above with the code you wish you had***. We do that in our **Step Definitions**. 

##### Step Definitions
A **Step Definition** is a method that creates a step. It is specific to Cucumber. We use the `Given()`, `When()`, and `Then()` methods to write step definitions. 

Add a file named `post_steps.rb` within the `features/step_definitions` directory with the following code: 

*simple_blog/features/step_definitions/post_steps.rb*
	Given /^there is a simple blog form$/ do
	  visit new_post_path
	end
	
	When /^I create a blog post$/ do
	  fill_in 'Title', with: 'First post'
	  fill_in 'Body', with: 'Hello World'
	  click_button 'Create Post'
	end
	
	Then /^I should see "(.*?)" in the post (.*?)\.$/ do |content, field|
	  expect(page).to have_content content
	end
We replaced `pending # express the regexp above with the code you wish you had` with ***[Capybara](https://github.com/jnicklas/capybara)***. Capybara is its own *domain specific language*, it uses RSpec, and will simply take practice/reference to get the syntax right. Capybara, quite literally, runs a web browser and executes an event. It's pretty simple to understand, right? 
Lets run `$ cucumber` and see what happens now.

	Feature: Create Post
	
	  As a guest
	  I want to create a post
	  So that other guests can read it
	
	  Scenario: creating a blog post
	    Given there is a simple blog form
	      undefined local variable or method `new_post_path' for #<Cucumber::Rails::World:0x007fb5a4d166e8> (NameError)
	      ./features/step_definitions/post_steps.rb:2:in `/^there is a simple blog form$/'
	      features/create_post.feature:8:in `Given there is a simple blog form'
	    When I create a blog post
	    Then I should see "First post" in the post title.
	    And I should see "Hello World" in the post body.
	    
	Failing Scenarios:
	cucumber features/create_post.feature:7 # Scenario: creating a blog post
	
	1 scenario (1 failed)
	4 steps (1 failed, 3 skipped)
	0m0.590sGreat! We failed a step! Looks like we're missing our new_post route. Let's take care of that.	