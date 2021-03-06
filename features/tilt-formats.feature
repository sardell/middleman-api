Feature: Tilt Formats
  Scenario: markdown
    Given the Server is running at "middleman-app"
    When I go to "/tilt/markdown.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<p><strong>Lorem Ipsum</strong></p>"

  Scenario: textile
    Given the Server is running at "middleman-app"
    When I go to "/tilt/textile.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<p><strong>Lorem Ipsum</strong></p>"

  Scenario: slim
    Given the Server is running at "middleman-app"
    When I go to "/tilt/slim.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<p><strong>Lorem Ipsum</strong></p>"

  Scenario: liquid
    Given the Server is running at "middleman-app"
    When I go to "/tilt/liquid.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<p><strong>Lorem Ipsum</strong></p>"

  Scenario: rdoc
    Given the Server is running at "middleman-app"
    When I go to "/tilt/rdoc.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<p><strong>Lorem Ipsum</strong></p>"

  Scenario: haml
    Given the Server is running at "middleman-app"
    When I go to "/tilt/haml.json"
    Then I should see:
    """
    {"metadata":{"foo":"bar","baz":"boo"}
    """
    And I should see "<em>Haml</em>"
