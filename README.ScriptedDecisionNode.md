# Scripted Decision Node for Authentication Trees

## Bindings

### References

* https://bugster.forgerock.org/jira/browse/OPENAM-16611
* https://ea.forgerock.com/docs/am/scripting-guide/index.html
* https://ea.forgerock.com/docs/am/authentication-guide/scripting-api-node.html#scripting-api-node-sharedState
* https://ea.forgerock.com/docs/am/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision
* https://ea.forgerock.com/docs/am/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision
* https://ea.forgerock.com/docs/am/auth-nodes/core-action.html
* https://backstage.forgerock.com/docs/am/7/apidocs/org/forgerock/openam/auth/node/api/Action.html
* https://backstage.forgerock.com/docs/am/7/apidocs/org/forgerock/openam/auth/node/api/Action.ActionBuilder.html#putSessionProperty(java.lang.String,java.lang.String)
* https://backstage.forgerock.com/docs/am/7/apidocs/org/forgerock/openam/auth/node/api/TreeContext.html#getState(java.lang.String)

### Comments

The bindings are listed in the order of proposed appearance in the final doc; hence, the follow up comments may rely on information provided in previous sections.

0. The preface/introduction section.

    ### Action needed:

    May benefit from being presented as a titled section, like the others under Scripted Decision Node API Functionality, and being explicitly listed in the TOC under Scripted Decision Node API Functionality. The preface section will most likely contain important information, but currently it is easy to miss if you focus on the TOC items.

    All bindings available in the script context should be at least listed in preface for easy eye inspection and knowing of their existence in the scripting context. Additionally/alternatively, they _all_ could be present as corresponding items in the TOC (either as a binding name/key or, like currently, as a functional item; for example, "Making Outbound HTTP Request"), and linked from preface.

    The idea is that a developer is immediately aware of capabilities presented in the scripting environment. The current story style is good for intentional/dedicated reading, but it makes it difficult/inefficient for looking up information quickly.

1. `private static final String OUTCOME_IDENTIFIER = "outcome";`

    ### Action needed:

    Will benefit from an inline explanation of the `outcome` variable and its use, and/or a link to the existing doc: https://backstage.forgerock.com/docs/am/7/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision

    The link to the Scripted Decision Node doc could be included in the introduction/preface part of the Scripted Decision Node API Functionality section of the Authentication and Single Sign-On Guide, along with the (already present) links to Accessing HTTP Services and Debug Logging.

    The idea is that the developer knows exactly what the outcome of the script functionality needs to be/is expected on the server sides.

    ### Follow up:

    We can restructure the current Scripted Decision Node API Functionality doc and provide a designated section for describing basic required functionality, or we could continue to use preface for that purpose.

    In any case, a short introduction and a link to [Scripted Decision Node](https://backstage.forgerock.com/docs/am/7/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision) could be helpful for referencing the `outcome` and the `*` bindings. Maybe something like the following:

    > In scripted decision nodes you need to specify a server side script to be executed and its possible outcomes.
    >
    > The script defines the possible outcome paths by setting one or more values of a _string_ variable named `outcome`. For example:
    > ```javascript
    > if ( . . . ) {
    >   outcome = "true";
    > } else {
    >   outcome = "false";
    > }
    > ```
    >
    > Tree evaluation continues along the outcome path that matches the value of the outcome variable when script execution completes.
    >
    > In addition, all of the inputs required by the script and the outputs produced by it must be declared. The `*` (wildcard) variable could be used in the scripted decision node configuration to include all available inputs or outputs without verifying their presence in the [tree state](https://backstage.forgerock.com/docs/am/7/auth-nodes/core-action.html#accessing-tree-state).
    >
    > For example:
    >
    > <img alt="Scripted Decision Node Configuration" src="README_files/Scripted-Decision.Configuration.png" width="256">
    >
    > For more information about scripted decision nodes configuration, see [Scripted Decision Node](https://backstage.forgerock.com/docs/am/7/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision) in Authentication Nodes Configuration Reference.

    I am not suggesting a literal solution above; rather a possible approach.

1. `private static final String WILDCARD = "*";`

    ### Action needed:

    Will benefit from an inline explanation of the `*` variable and its use, and/or a link to the existing doc, which itself could benefit from explanation what a script's inputs/outputs are and of their connection to the `sharedState` object: https://backstage.forgerock.com/docs/am/7/authentication-guide/auth-node-configuration-hints.html#auth-node-scripted-decision

    ### Follow up:

    See the suggestions for `outcome` binding above.

1. `private static final String HTTP_CLIENT_IDENTIFIER = "httpClient";`

    ### Action needed:

    May benefit from explicit coverage of the `httpClient` binding.

    A link is provided to Accessing HTTP Services in the Getting Started with Scripting guide, which sufficiently explains the use of the `httpClient` object: https://backstage.forgerock.com/docs/am/7/scripting-guide/scripting-api-global-http-client.html. However, currently this information is easily omitted by the reader. Also, it could benefit from explicit mentioning the variable as being accessible from the script context. See the comment for preface.

1. `private static final String LOGGER_VARIABLE_NAME = "logger";`

    ### Action needed:

    A link is provided to Debug Logging in the Getting Started with Scripting guide, which sufficiently explains the use of the `logger` object: https://backstage.forgerock.com/docs/am/7/scripting-guide/scripting-api-global-logger.html. However, see the comments for the `httpClient` binding above.

1. `private static final String HEADERS_IDENTIFIER = "requestHeaders";`

    ### No action needed:

    Clearly present and sufficiently explained in the guide: [Accessing Request Header Data](https://backstage.forgerock.com/docs/am/7/authentication-guide/scripting-api-node.html#scripting-api-node-requestHeaders).

    ### Follow up:

    May benefit from example(s).

1. `private static final String SHARED_STATE_IDENTIFIER = "sharedState";`

    ### Action needed:

    Clearly present but insufficiently explained in the guide: https://backstage.forgerock.com/docs/am/7/authentication-guide/scripting-api-node.html#scripting-api-node-sharedState

    Will benefit from inline explanation of the Shared Tree State locations and/or a link to [Storing Values in Shared Tree State](https://backstage.forgerock.com/docs/am/7/auth-nodes/core-action.html#accessing-tree-state) in Authentication Node Development Guide.

    ### Follow up:

    While a link to the Action Interface in Authentication Node Development Guide will be helpful, it describes the functionality in the context of node development (in Java and entire tree context properties and methods being available).

    It may be better to explain relationship between `sharedState`, `secureState`, and `transientState` right in the body of the doc and in the scripting context.

    In addition, as noted in the linked [OPENAM-16856](https://bugster.forgerock.org/jira/browse/OPENAM-16856) issue, the provided example is based on the `getState(String stateKey)` method, which does not currently work in the AM 7 code.

    At the moment, one can use `sharedState.get(String stateKey)`, `sharedState.put(String stateKey)`, `transientState.get(String stateKey)`, and `transientState.put(String stateKey)` methods; hence, the examples need to be updated accordingly.

    > The [getState(String stateKey)](https://stash.forgerock.org/projects/OPENAM/repos/openam/browse/openam-auth-trees/auth-node-api/src/main/java/org/forgerock/openam/auth/node/api/TreeContext.java#262) method returns the string value of the named transient, secure, or shared state property (first found first served in that order), which seems to allow for name conflict between transient and shared states. If that is not the desired behavior, instead of binding `getState` in the future code, access to the [getTransientState(String stateKey)](https://stash.forgerock.org/projects/OPENAM/repos/openam/browse/openam-auth-trees/auth-node-api/src/main/java/org/forgerock/openam/auth/node/api/TreeContext.java#290) method could be provided, which will check for the property presence in the `secureState` object first.
    >
    > In any case, it looks like some kind of new binding needs to be introduced that allows access to values stored in the `secureState` object.

    In addition, the [current doc](https://ea.forgerock.com/docs/am/auth-nodes/core-action.html#set-get-values-in-tree-state) states that:
    > . . . getState() method tries to retrieve data from the different states in the following order:
    > 1. sharedState
    > 2. transientState
    > 3. secureState

    The [actual code](https://stash.forgerock.org/projects/OPENAM/repos/openam/browse/openam-auth-trees/auth-node-api/src/main/java/org/forgerock/openam/auth/node/api/TreeContext.java#262) reveals different order:
    ```java
    /**
     * Retrieves a field from one of the three supported state locations, or null if the key is not found in any of the
     * state locations.
     *
     * @param stateKey The key to look for.
     * @return The first occurrence of the key from the states, in order: Transient, Secure, Shared.
     */
    public JsonValue getState(String stateKey) {
        if (transientState.isDefined(stateKey)) {
            return transientState.get(stateKey);
        } else if (secureState.isDefined(stateKey)) {
            return secureState.get(stateKey);
        } else if (sharedState.isDefined(stateKey)) {
            return sharedState.get(stateKey);
        }
        return null;
    }
    ```

1. `private static final String TRANSIENT_STATE_IDENTIFIER = "transientState";`

    ### Action needed:

    Is NOT explicitly covered in the Accessing Shared State Data section of the Authentication and Single Sign-On Guide.

    Will benefit from inline explanation of the Shared Tree State locations and/or a link to [Storing Values in Shared Tree State](https://backstage.forgerock.com/docs/am/7/auth-nodes/core-action.html#accessing-tree-state) in Authentication Node Development Guide.

    ### Follow up:

   See comments for the `sharedState` binding above.

1. `private static final String ID_REPO_IDENTIFIER = "idRepository";`

    ### No action needed:

    Clearly present and sufficiently explained in the guide: https://backstage.forgerock.com/docs/am/7/authentication-guide/scripting-api-node.html#scripting-api-node-id-repo

    ### Follow up:

    As mentioned in the pre-face section comments, the binding may be explicitly listed upfront.

    Cannot find Javadoc for `path-to-openam/openam-scripting/src/main/java/org/forgerock/openam/scripting/idrepo/ScriptIdentityRepository.java` class providing the public methods described in this session:
    >
    > ¯\\\_(ツ)_/¯
    >
    > Doc not found

    ### Examples

    ```groovy
    idRepository.setAttribute(sharedState.get("username"), "mail", ["user.4@a.com", "user.4@b.com"] as String[]) // Set multiple values; cast a List as a String array.
    idRepository.setAttribute(sharedState.get("username"), "mail", "user.4@a.com") // Set a single value; could be a String.
    idRepository.addAttribute(sharedState.get("username"), "mail", "user.4@c.com") // Add a value as a String.
    var userMail = idRepository.getAttribute(sharedState.get("username"), "mail") // Get the attribute value as a Set.

    logger.error("mail" + idRepository.getAttribute(sharedState.get("username"), "mail"))
    // ERROR: [user.4@a.com, user.4@c.com]
    logger.error("email" + idRepository.getAttribute(sharedState.get("username"), "email"))
    // ERROR: []
    // If the attribute is not found, an empty Set is returned.
    ```

    ```javascript
    idRepository.setAttribute(sharedState.get("username"), "mail", ["user.4@a.com", "user.4@b.com"]) // Set multiple values; must be an Array.
    idRepository.setAttribute(sharedState.get("username"), "mail", ["user.4@a.com"]) // Set a single value; must be an Array.
    idRepository.addAttribute(sharedState.get("username"), "mail", "user.4@c.com") // Add a value as a String.
    var userMail = idRepository.getAttribute(sharedState.get("username"), "mail")

    logger.error("mail" + idRepository.getAttribute(sharedState.get("username"), "mail"))
    // ERROR: [user.4@a.com, user.4@c.com]
    logger.error("email" + idRepository.getAttribute(sharedState.get("username"), "email"))
    // ERROR: []
    // If the attribute is not found, an empty Set is returned.
    ```

    ### Questions

    Should `idRepository.addAttribute(String username, String attribute, String value)` be only applicable to attributes presented in the UI as multi-values?

1. `private static final String EXISTING_SESSION = "existingSession";`

    ### No action needed:

    Clearly present and sufficiently explained in the guide: https://backstage.forgerock.com/docs/am/7/authentication-guide/scripting-api-node.html#scripting-api-node-existingSession

    ### Follow up:

    As mentioned in the pre-face section comments, the binding may be explicitly listed upfront.



1. `private static final String ACTION_IDENTIFIER = "action";`

    ### Action needed:

    Will benefit from an inline explanation of the `action` variable and its use as a place holder for results of implementing the Action Interface, and from a link to the existing doc: https://backstage.forgerock.com/docs/am/7/auth-nodes/core-action.html

    The link to the Action Interface section of the Authentication Node Development Guide could be included in the introduction/preface part of the Scripted Decision Node API Functionality section of the Authentication and Single Sign-On Guide, along with the already present links to Accessing HTTP Services and Debug Logging.

1. `private static final String REALM_IDENTIFIER = "realm";`

    ### Action needed:

    Realm argument is used in the Action Interface examples at https://backstage.forgerock.com/docs/am/7/auth-nodes/core-action.html, but without explanation where the realm value may come from, and this reference itself is not provided in the Scripted Decision Node API section of the Authentication and Single Sign-On Guide.

    Will benefit from links to the Action Interface doc and an explanation for realm name being available in the node script via a variable of the same name.

    Provides access to current realm name; or realm name specified in `requestParameters`?

1. `private static final String CALLBACKS_IDENTIFIER = "callbacks";`

    ### Action needed:

    Explained sufficiently in the guide: https://backstage.forgerock.com/docs/am/7/authentication-guide/scripting-api-node.html#scripting-api-node-existingSession

    Might benefit from an example of running a client-side script and receiving client-side data.

1. `private static final String QUERY_PARAMETER_IDENTIFIER = "requestParameters";`

    ### Action needed:

    Will benefit from any coverage, for none is provided.

    Provides access to the authentication request query string parameters.

1. `private static final String SECRETS_IDENTIFIER = "secrets";`

    ### Action needed:

    Will benefit from any coverage, for none is provided.

    ### Follow up:

    The binding is not available in AM 7.0 and can only be found in cloud-specific branches.

1. `private static final String AUDIT_ENTRY_DETAIL = "auditEntryDetail";`

    ### Action needed:

    Will benefit from any coverage, for none is provided.

    The closest reference is the New Features in AM 6.5.3 > Extended Node for Auditing section at https://backstage.forgerock.com/docs/am/6.5/release-notes/index.html#whats-new

    Returned via a public method:

    ```java
    public JsonValue getAuditEntryDetail() {
        if (auditEntryDetail != null) {
            return auditEntryDetail;
        } else {
            return json(object());
        }
    }
    ```

## Upcoming Changes

* `binding.put(SECRETS_IDENTIFIER, secrets);`

    References:

    * [Feature/AME-20076](https://stash.forgerock.org/projects/OPENAM/repos/openam/pull-requests/12181/overview)

    * [OpenAM > OPENAM-16869 > Improve Scripting documentation > OPENAM-16870 | Document access to secrets API in scripted decision node](https://bugster.forgerock.org/jira/browse/OPENAM-16870):
