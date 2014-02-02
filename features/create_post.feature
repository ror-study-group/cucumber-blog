Feature: Create Post

  As a guest
  I want to create a post
  So that other guests can read it

  Scenario: creating a blog post
    Given there is a simple blog form
    When I create a blog post
    Then I should see "First post" in the post title.
		And I should see "Hello World" in the post body.
