Feature: Request Paths
  Scenario: when requesting is a path
    Given the Server is running at "middleman-app"
    When I go to "/directory/subdirectory/foo.json"
    Then I should see:
    """
    <div>Foo</div>
    """
    And I should see:
    """
    "path":"/directory/subdirectory/foo.html"
    """

  Scenario: when request is root
    Given the Server is running at "middleman-app"
    When I go to "/index.json"
    Then I should see:
    """
    <h1>Middleman is Watching</h1>
    """
    And I should see:
    """
    "path":"/"
    """