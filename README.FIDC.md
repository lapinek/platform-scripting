# Scripting in a FIDC Tenant

## Functionality

### Comments

* Groovy is enabled, but it is not officially supported.

    From conversation with Kate Atkinson and Andreas Egloff, the Groovy is not supported due to an executive decision (by PB), and it was easier to keep Groovy as an option for now.

    Groovy environment is severely limited AM in FIDC due to limited access to  Java classes and inability to change it via the white list in AM Admin Console > Configure > Global Services.
    > Only CORS global service can currently be configured: https://bugster.forgerock.org/jira/browse/FRAAS-3360?focusedCommentId=192960&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-192960

    Examples of limited functionality:

    * `try {} catch (e) {}` (unspecified exception type)

        > Access to Java class \"java.lang.SecurityException\" is prohibited.

    * `new JsonSlurper().parseText()`

        > Access to Java class \"org.apache.groovy.json.internal.LazyMap\" is prohibited.

    Eventually both AM and IDM scripts in IDC will be have limited access to Java functionality via employing JVM security manager.

* Custom "errorMessage" is not displayed in Platform UI issue.


## Debug Logging

### References

* https://backstage.forgerock.com/docs/idcloud/latest/paas/paas/logs.html
* https://forgerock.slack.com/archives/C01C11G0YRE/p1601614363129200

### Comments

* Logs are not available immediately, may take a few seconds to retrieve them.
* [ruby script](README_files/tail.rb) and [jq](https://stedolan.github.io/jq/manual/) example:

    * Scripted decision node logger output and any exceptions | message, timestamp, and exception:

        ```ruby
        # README_files/tail.rb

        # . . .

        print r["payload"].to_json # To produce valid JSON for `jq`.

        # . . .
        ```

        ```bash
        $ ruby -- tail.rb | jq '. | select(objects) | select(has("exception") or (.logger | test("scripts.AUTHENTICATION_TREE_DECISION_NODE"))) | {message: .message, timestamp: .timestamp, exception: .exception}'
        ```

