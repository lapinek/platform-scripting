
# <a id="top"></a>Particularities of Scripting Environments in ForgeRock Products

Three of ForgeRock Identity Platform products, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript or Groovy and evaluated during the run time.

Scripting is broadly used in the products and broadly covered across [ForgeRock Product Documentation](https://backstage.forgerock.com/docs/). There are many articles describing scripting environment and application, often in a context of particular task and supplied with examples.

This writing aims at a quick comparison of scripting environments in the three products and highlighting some important details. The [References](#references) section will contain a comprehensive set of relevant links to the official docs, but some will also be provided inline.

## <a id="contents"></a>Contents

* [Overview](#overview)
    * [AM](#overview-am)
        * [Client-side](#overview-am-client-side)
        * [Server-side](#overview-am-server-side)
        * [Debugging](#overview-am-debugging)
        * [Managing](#overview-am-managing)
        * [Authentication Chain Example](#overview-am-chain)
        * [Authentication Tree Example](#overview-am-tree)
    * [IDM](#overview-idm)
        * [OSGi Framework](#overview-idm-osgi)
        * [ICF Connectors](#overview-idm-icf)
        * [Workflow](#overview-idm-workflow)
    * [IG](#overview-ig)
* [Summary](#summary)
* [Conclusion](#conclusion)

## <a id="overview"></a>Overview

[Back to Contents](#contents)

To highlight some differences in the scripting environments, we will use an example script to make an outbound HTTP call.

<!-- This is just one possible scripting application in ForgeRock products that will help to compare scripts' management, configuration, debugging options, and runtime environment in the three products. -->

## <a id="overview-am"></a>Overview > AM

[Back to Contents](#contents)

NOTES:

* Scripting application in AM could be summarized into the following categories:
    * Authentication, Client-side and Server-side
        * Modules and Chains
        * Nodes and Trees
    * Authorization, Server-side only
        * Scripting Policy Condition
        * Access Token Modification
    * Federation, Server-side only
        * OIDC Claims Handling
* Client-side scripting environment is defined completely by the user agent and is not specific to ForgeRock.
* Server-side scripting environment is different for each category in terms of automatically provided functionality. However:
    * All of the categories share some common, globally provided objects and methods.
    * All server-side scripts have access to the same underlying Java API.

### <a id="overview-am-client-side"></a>Overview > AM > Client-side

[Back to Contents](#contents)

NOTES:

* Client-side scripts need to be written in [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) and be compatible with the users' _browser_.

In AM, authentication in the front channel can be assisted with custom client-side scripts written in JavaScript and executed in the user's browser. The collected data can be posted to the server and become available for the server-side components involved in the same authentication procedure.

> An important use case for a client-side script could be collecting user input and/or information about the user agent: [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/geolocation), IP, the navigator properties, and so on.

### <a id="overview-am-server-side"></a>Overview > AM > Server-side

[Back to Contents](#contents)

NOTES:

* Server-side scripts in AM can be written in [Groovy](https://www.groovy-lang.org/documentation.html) or JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). The 6.5 version of AM uses Groovy version 2.5.7 and Rhino version 1.7R4.
* The server-side scripts have global access to [AM 6.5.2.3 Public API](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html) and [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global), the latter providing HTTP services and debug logging methods.
* [Scripting Security](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#script-engine-security) checks directly-called Java classes against a configurable blacklist and whitelist, and, optionally, against the JVM SecurityManager.
* Other, application-specific APIs are available to server-side scripts that are specific to the extended functionality.
* HTTP requests can be made with the `httpClient` object. The requests are synchronous and blocking until resolved.
* In server-side _JavaScript_ you need to use the full path to a Java class or a  static method. An instance or a static method can be assigned to a JavaScript variable.

The decision making process on user identification and access management can be aided with the server-side scripts.

Besides the globally accessible APIs, [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn), [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node), [Authorization API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-policy), and [OpenID Connect 1.0 Claims API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-oidc) are available for scripts when they extend particular parts of authentication and authorization procedures.

[Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-http-client) is possible with the `httpClient` object (and the `org.forgerock.http.protocol` package). The HTTP client requests are synchronous, blocking until they return, and have to be controlled with the global timeout setting under Realms > Realm Name > Authentication > Modules.

The ability to run Java in the server-side scripts is limited by configurable blacklist and whitelist, and, optionally, by configuring the JVM SecurityManager.

> For example, if your script is written in Groovy, and you need to parse stringified JSON with `groovy.json.JsonSlurper`, the `groovy.json.internal.LazyMap` class would have to be allowed in the scripting engine setting. For getting AM identity with the `IdUtils` method, `com.sun.identity.idm.AMIdentity` would have to be explicitly whitelisted.

### <a id="overview-am-debugging"></a>Overview > AM > Debugging

[Back to Contents](#contents)

NOTES:

* Server-side scripts in AM cannot be attached to a debugger.
* The global scripting API allows for [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger).
* By default, debug logs are saved in (separate) files.

The location of the log files can be found in the administrative console under CONFIGURE > SERVER DEFAULTS > General > Debugging.

[Debug Logging By Service](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#log-debug-selective-capture) allows for setting a _level_ of debug logging to capture in the log files for the scripting service and for some individual scripts. Alternatively, during development, you could use the `logger.error` method, for the `error` level logs are always saved.

Logs for scripts of the `Decision node script for authentication trees` type are saved individually when a script associated with a `Scripted Decision Node` outputs logs (at the allowed level). The file name is of the following pattern:

scripts.AUTHENTICATION_TREE_DECISION_NODE._script-id_

The _script-id_ part corresponds to the Realms > _Realm Name_ > Scripts > _script-id_ on the script details page in AM console. For example:

<img alt="Script ID in AM Console" src="README_files/am.scripts.script-id.png" width="1024" />

This is also how these scripts appear in the Debug instances input on the Debug Logging By Service page. For example:

<img alt="Script ID on the Debug.jsp page" src="README_files/am.debug.debug-instances.script-id.png" width="1024" />

In the debug directory, `path/to/am/instance/debug` by default, you can `tail -f` the log files during the development. For example:

```bash
$ cd ~/openam/am/debug$
$ ls
Authentication  CoreSystem  IdRepo  scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc
```

```bash
$ tail -f scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc
scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc:04/26/2020 07:34:02:654 PM GMT: Thread[ScriptEvaluator-5,5,main]: TransactionId[88093018-65c0-4987-b7af-ef1429ac1c04-46398]
ERROR: helpful info.
```

If an error is not handled within the script itself, it may be reported in the Authentication log. For example, it you try to employ a Java package that is not whitelisted in the scripting engine settings, the "Access to Java class . . . is prohibited." error will appear in the Authentication file.


> Server-side JavaScript `console.log()` and Rhino's `print()` are not supported and neither is `println()` in Groovy. You can use the `logger` object methods to output in Standard Output, though.
>
>The client-side JavaScript can output logs into the browser's console as usual.

### <a id="overview-am-managing"></a>Overview > AM > Managing

[Back to Contents](#contents)

NOTES:

* Scripts management requires administrative rights.
* Scripts can be uploaded but are stored as AM configuration data, not as files.
* Scripts can be designed through the AM console with the provided in UI text editor.
* Scripts included in AM can serve as examples.

The [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts) chapter shows how the scripts can be managed via REST and command line interfaces. These two approaches may represent the most efficient way to manage scripts in automated environments; for example, in production deployments. At the same time, AM console UI provides an easy to use visual interface for creating and updating scripts and applying them to authentication, authorization, and [OpenID Connect](https://openid.net/connect/) procedures.

Managing scripts requires an administrative account; for example, the built in `amadmin` login. The admin user credentials can be used directly in AM console and with the `ssoadmin` command. To manage scripts via the REST, you'd need to provide an authentication header, `iPlanetDirectoryPro` is expected by default, populated with the SSO token of an administrative user.

Behavior of script type can be be adjusted in AM console at Configure > Global Services > Scripting > Secondary Configurations > _Server-Side Script Type_.

Scripts included in the default AM configuration can serve as a great source of example scripting for the script types supported in AM. The Decision node script for authentication trees example script is very basic; for this one, see the [example](#overview-am-tree) provided in this writing. The default scripts can be found in the AM console under Realms > _Realm Name_ > Scripts.

### <a id="overview-am-chain"></a>Overview > AM > Authentication Chain Example

[Back to Contents](#contents)

NOTES:

* Custom scripts can be employed in the [Scripted Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#scripted-module-conf-hints). The module can take a pair of scripts of the following types:
* `Client-side Authentication` (optional):
    * Everything you know and love about JavaScript in the browser environment is applicable here and is not specific to Forgerock in terms of run time environment—such as compatibility, debugging options, etc. No server-side Java functionality is available.
    * There will be automatically rendered _self-submitting_ form on the page where the script runs. The form data is POSTed back to AM and the value of an input in the form, populated by the client-side script,  will become available to the server side.
    * For asynchronous JavaScript, you will need to delay auto-submission of the form, and submit it manually when the asynchronous call is completed.
* `Server-side Authentication`:
    * The `requestData` object provides access to the Request data.
    * The `idRepository` object provides access to Profile data.
    * The `authState` object value determines outcome of a scripted authentication module. The outcome can be either `SUCCESS` or `FAILURE`.

You can read about setting up a custom scripted module in [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) and [Device ID (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints) provides an example of using a pair of client-side and server-side scripts.

Scripts can be created and managed in AM console under Realms > _Realm Name_ > Scripts.

A Scripted Module - Client Side script—that loads an external library, makes a call to an external service, and obtains the client's IP—might look like the following:

```javascript
var script = document.createElement('script'); // 1

script.src = 'https://code.jquery.com/jquery-3.4.1.min.js'; // 1
script.onload = function (e) { // 2
    $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
        output.value = JSON.stringify({
            ip: json
        }); // 3
    })
    .always(function () {
        submit(); // 4
    });
}

document.getElementsByTagName('head')[0].appendChild(script); // 1

autoSubmitDelay = 4000; // 5
```

Legend:

1. Create a script element and add to DOM for loading an external library.
2. When the library is loaded, make a request to an external source to obtain the client's IP information.
3. Save the information, received as a JSON object, as a string in an input in the automatically rendered form.
4. When the HTTP call is complete, submit the form.
5. If the HTTP request takes more time than the specified timeout, auto submit the form.

Specific for Scripted Authentication Module points of consideration:

* The form is self-submitting.
* The input for the client-side data can be referenced via the `output` object.
* The form can be submitted with the automatically provided `submit()` function.

> If you'd like to inspect the page content, you can further delay submission of the form or stop JavaScript execution with the good old `alert()`.

The corresponding server-side script, used in the same authentication module, can [Access Client-Side Script Output Data](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn-client-data) via a String object named `clientScriptOutputData`.

A Scripted Module - Server Side script written in _JavaScript_ might look like the following:

```javascript
var failure = true; // 1

var ip = JSON.parse(clientScriptOutputData).ip; // 2

failure = idRepository.getAttribute(username, 'postalAddress').toArray()[0].indexOf(ip.postal) === -1 // 3

var request = new org.forgerock.http.protocol.Request(); // 4
request.setUri("https://jsonplaceholder.typicode.com/users");
request.setMethod("GET");

var response = httpClient.send(request).get(); // 5
var users = JSON.parse(response.getEntity());

failure = failure || users.some(function (user) { // 6
    return (
        user.username === username ||
        user.email === idRepository.getAttribute(username, "mail").toArray()[0] // 3
    );
});

if (failure) {
    logger.error('Authentication denied.');

    authState = FAILED; // 7
} else {
    logger.message('Authentication allowed.');

    authState = SUCCESS; // 7
}
```

Legend:

1. Set expectations low and only allow for the success outcome if everything checks out.
2. Parse the data submitted from the client-side, assuming it is stringified JSON. Create a JavaScript object—so that its individual properties can be easily accessed.
3. Compare the user's identity postal address managed in AM with the zip code obtained from the client side.

    The `idRepository` object is a part of the [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn) available for scripts in authentication modules. Using its methods, we can access the identity's attributes.

    We assume that in this authentication process `username` is set in an earlier authentication module.

    The value received from the `getAttribute` method is a Java `HashSet`; we convert it to a string before the comparison.

4. Use the `org.forgerock.http.protocol` package for configuring an HTTP request. Use the full path to a Java class in server-side _JavaScript_.
5. Use the `httpClient` object provided by [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global) for making an outbound HTTP request.
6. Check the user's email against a "blacklist" received from an external resource.
7. Depending on the result that the script produced, set the [Authentication State](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn-state) value to define the outcome of this module.

> The client IP information could be used in [Scripting a Policy Condition](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/index.html#sec-scripted-policy-condition)—as demonstrated in the `Scripted Policy Condition` script included in the default AM configuration.

### <a id="overview-am-tree"></a>Overview > AM > Authentication Tree Example

[Back to Contents](#contents)

NOTES:

* Custom scripts of the `Decision node script for authentication trees` type can be used in a [Scripted Decision Node](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#auth-node-scripted-decision).
* `outcome` of a Scripted Decision Node could be populated with any string. The tree layout determines the path a particular outcome takes the authentication flow to.
* In a Scripted Decision Node, accessing the authentication state, the identity's profile, the client side and the request data, interacting with the client side, and moving to the next node can done with methods specific to [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node).
* To exit a Scripted Decision Node and to interact with the client side, you need to use [The Action Interface](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-action). As the Scripted Decision Node does not provide a convenient wrapper for a client-side script. You need to use [Supported Callbacks](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#supported-callbacks) to insert the script and to receive the client-side data.

In our example, following the "single task per node" philosophy, the client-side data will be obtained and preserved by one node, and processed and analyzed in the next one.

The authentication tree might look like the following:

<img src="README_files/am.authentication-tree.scripted-decision-module.png" alt="Authentication Tree with the Scripted Decision node." width="1024">

### The First Scripted Decision Node

The Action Interface, the callbacks, and other functionality can be provided by the AM's Java API. It is easier to consume with a Groovy script, so we will take a look at a Groovy example first:

```groovy
/*
- Data made available by nodes that have already executed
    are available in the sharedState variable.
- The script should set outcome to either "true" or "false".
*/

import org.forgerock.openam.auth.node.api.*; // 1
import com.sun.identity.authentication.callbacks.ScriptTextOutputCallback;
import com.sun.identity.authentication.callbacks.HiddenValueCallback;

def script = ''' // 2
var script = document.createElement('script'); // A

script.src = 'https://code.jquery.com/jquery-3.4.1.min.js'; // A
script.onload = function (e) { // B
    $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
        document.getElementById('clientScriptOutputData').value = JSON.stringify({
            ip: json
        }); // C
    })
    .always(function () {
        document.getElementById("loginButton_0").click(); // D
    });
}

document.getElementsByTagName('head')[0].appendChild(script); // A

setTimeout(function () { // E
    document.getElementById("loginButton_0").click();
}, 4000);
'''

if (callbacks.isEmpty()) { // 3
    action = Action.send([
        new HiddenValueCallback("clientScriptOutputData", "false"),
        new ScriptTextOutputCallback(script)
    ]).build();
} else {
    def failure = true;

    if (callbacks[0].getValue() != "clientScriptOutputData") { // 4
        sharedState.put("clientScriptOutputData", callbacks[0].getValue());

        failure = false;
    }

    if (failure) { // 5
        logger.error('Authentication denied.');

        action = Action.goTo("false").build();
    } else {
        logger.message('Authentication allowed.');

        action = Action.goTo("true").build();
    }
}
```

Legend:

1. Import the API that allows for using the Action Interface and executing callbacks.
2. The client-side portion can be defined directly in the body of `Decision node script for authentication trees` script. Provide a multiline definition of the client-side script to be executed in the user's browser.

    ```javascript
    var script = document.createElement('script'); // A

    script.src = 'https://code.jquery.com/jquery-3.4.1.min.js'; // A
    script.onload = function (e) { // B
        $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
            document.getElementById('clientScriptOutputData').value = JSON.stringify({
                ip: json
            }); // C
        })
        .always(function () {
            document.getElementById("loginButton_0").click(); // D
        });
    }

    document.getElementsByTagName('head')[0].appendChild(script); // A

    setTimeout(function () { // E
        document.getElementById("loginButton_0").click();
    }, 4000);
    ```

    Client-side Script Legend:

    * A. Create a script element and add to DOM for loading an external library.
    * B. When the library is loaded, make a request to an external source to obtain the client's IP information.
    * C. Save the information, received as a JSON object, as a string in an input in the automatically rendered form.
    * D. When the HTTP call is complete, submit the form.
    * E. If the HTTP request takes more time than the specified timeout, auto submit the form.

    Specific for Scripted Decision Node points of considerations:

    * The form is NOT self-submitting.
    * The input for the client-side data needs to be referenced directly.
    * There is no automatically provided `submit()` function.

    > If you'd like to inspect the page content, you can further delay submission of the form or stop JavaScript execution with `alert()`.

3. Check if any callbacks have been already requested by the node; if not, specify the two for inserting a script in the user's browser and receiving a submitted form value from the client side. The callbacks will be sent to the user's browser.

4. When the callbacks have been requested, and the form input has been populated and submitted to the server side, access the form value and save under the `clientScriptOutputData` key in the shared state object.

    As authentication in a tree worries along, the nodes may capture information and save it in special objects named [sharedState and transientState](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#accessing-tree-state). This shared state is available for the next node in the tree.

    It has been a success; indicate it by setting the failure status to false.

5. Move to the next node with the outcome being set according to the failure status.

#### The Second Scripted Decision Node

The next node in the tree will be able to retrieve the IP information by querying the shared state. A Groovy example:

```groovy
/*
- Data made available by nodes that have already executed are available in the sharedState variable.
- The script should set outcome to either "true" or "false".
*/

import org.forgerock.http.protocol.*; // 1
import org.forgerock.openam.auth.node.api.*; // 2
import com.sun.identity.idm.IdUtils; // 3
import groovy.json.JsonSlurper; // 4

def jsonSlurper = new JsonSlurper();
def failure = true;
def id = IdUtils.getIdentity(sharedState.get("username"), sharedState.get("realm")); // 5
def ip = jsonSlurper.parseText(sharedState.get("clientScriptOutputData")).ip; // 6

failure = id.getAttribute("postalAddress").toArray()[0].indexOf(ip.postal) == -1; // 7

def request = new Request(); // 8
request.setUri("https://jsonplaceholder.typicode.com/users");
request.setMethod("GET");

def response = httpClient.send(request).get(); // 9
def users = jsonSlurper.parseText(response.getEntity().toString());

failure = failure || users.find() { // 10
    it.username == sharedState.get("username") ||
    it.email == id.getAttribute("mail").toArray()[0];
};

if (failure) { // 11
    action = Action.goTo("false").build();
} else {
    action = Action.goTo("true").build();
}
```

1. Import the `org.forgerock.http.protocol` package to configure `httpClient`.
2. Import the API that enables the Action Interface.
3. Import the `IdUtils` static class which allows access to the identity's profile.
4. Import the `jsonSlurper` class in order to parse the stringified JSON received from the client-script and preserved in the shared state.
5. Assuming the identity has been verified in a previous node, refer to the identity by its username.
6. Parse the client data preserved in the shared state.
7. Define the outcome by matching an attribute from the client data and one from the identity.
8. Prepare a network request as described in [Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-http-client) in the Development Guide.
9. Receive and parse the response.
10. Decide the outcome of the node depending on whether or not the user can be found in the online resource, which represents a "blacklist".
11. Proceed to the next node using the Action interface method.

> The client IP information could be used in [Scripting a Policy Condition](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/index.html#sec-scripted-policy-condition)—as demonstrated in the `Scripted Policy Condition` script included in the default AM configuration.

A JavaScript equivalent of the above script might look like the following:

```javascript
var goTo = org.forgerock.openam.auth.node.api.Action.goTo; // Assign a static method to a variable.
var getIdentity = com.sun.identity.idm.IdUtils.getIdentity;

var failure = false;
var id = getIdentity(sharedState.get("username"), sharedState.get("realm"));
var ip = JSON.parse(sharedState.get("clientScriptOutputData")).ip;

failure = id.getAttribute("postalAddress").toArray()[0].indexOf(ip.postal) === -1;

var request = new org.forgerock.http.protocol.Request();
request.setUri("https://jsonplaceholder.typicode.com/users");
request.setMethod("GET");

var response = httpClient.send(request).get();
var users = JSON.parse(response.getEntity());

failure = failure || users.some(function (user) {
    return (
        user.username === sharedState.get("username") ||
        user.email === id.getAttribute("mail").toArray()[0]
    );
});

if (failure) {
    action = goTo("false").build();
} else {
    action = goTo("true").build();
}
```

In future versions of AM, there may already be predefined nodes to perform certain client-side operations. In the marketplace, there is an authentication node for version 6.5 that allows to run custom JavaScript in the user's browser, [Client Script Auth Tree Node](https://backstage.forgerock.com/marketplace/api/catalog/entries/AWAm-FCxfKvOhw29pnIp).

## <a id="overview-idm"></a>IDM

[Back to Contents](#contents)

NOTES:

* IDM presents three distinct environments for scripting:
    * [Core IDM functionality defined in the OSGi framework](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-overview).
    * [ForgeRock Open Connector Framework and ICF Connectors](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#chap-about).
    * [Embedded workflow and business process engine based on Activiti and the Business Process Model and Notation (BPMN) 2.0 standard](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-workflow).


### <a id="overview-idm-osgi"></a>IDM > OSGi Framework

NOTES:

* Languages:
    * The Script Engine supports [Groovy](https://www.groovy-lang.org/documentation.html) and JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). The 6.5 version of IDM uses Groovy version 2.5.7 and Rhino version 1.7.12 (the latest release of Rhino at the time of writing).
* Scopes:
    * Scripting application could be summarized into the following environments described in [Scripting Reference](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#appendix-scripting):
        * Managed Objects:
            * Events.
            * Custom Scripted Actions.
            * Validating data via Scripted Policies.
        * Synchronization Service:
            * Events defined via Object-Mapping objects.
            * Correlation scripts.
            * Filtering (the source).
            * Validating (the source and the target).
            * Validating data via Scripted Policies.
        * Custom Endpoints, providing arbitrary functionality over REST API.
        * Authentication, when security context is augmented with a script.
        * Authorization, implemented with scripts and extendable with scripts.
    * [Router Service](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#appendix-router) provides the uniform interface to all IDM objects and additional scope to all scripts in the core IDM.
    * Scripts accept arbitrary param objects defined under "globals" namespace in the individual script configuration.
    * Scripts have access to custom "properties" defined in [Script Engine Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config).
* Functionality:
    * Access to managed, system, and configuration objects within the core IDM is abstracted via the `openidm` object.
    * Custom Java functionality:
        * Can be provided as a custom OSGi bundle under the `path/to/idm/instance/bundle` directory, or as a regular JAR file under `path/to/idm/instance/lib` directory.
        * Once available, you can [use custom Java packages in scripts](https://backstage.forgerock.com/knowledge/kb/book/b51015449#custom_package), both JavaScript and Groovy.
        * You can check for available classes and JAR files and use GroovyScriptLoader to [invoke a jar file from a Groovy script](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a38809746).
    * You can [load JavaScript functions](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a44445500) in scripts using the fully compliant CommonJS module implementation.
* Management:
    * An individual script configuration can specify a script "source" as a single line or a script "file" reference.
    * Scripts defined in separate files need to be places in certain locations specified in [Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config).
* Debugging
    * Debug logging is provided with the `logger` object methods.
    * _JavaScript_ scripts can use `console.log()`.
    * Scripts can be evaluated via REST, which can be used to test them if all the necessary bindings can be provided.
    * Scripts defined in separate files can be attached to a debugger.

### <a id="overview-idm-icf"></a>IDM > ICF Connectors

### <a id="overview-idm-workflow"></a>IDM > Workflow

### <a id="idm-scripts-location"></a>IDM > The Scripts' Location

```javascript
(function () {
    var result = openidm.action("external/rest", "call", params)

    return result
 }())
 ```

An equivalent in `Groovy` might look like the following:

```groovy
import org.forgerock.openidm.action.*

def result = openidm.action("external/rest", "call", params)
```

Both scripts expect `params` argument; we will provide it as a JSON at the time the script is called:

```JSON
params = {
    "url": "http://jsonplaceholder.typicode.com/users/1",
    "method": "GET"
}
```

In order to make an HTTP request, the script used `action` method of the `openidm` Java object. You can find more about scripts environment and available for scripts functionality in the IDM docs, in its [Scripting Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-scripting). In particular, the `action` method is described in the [openidm.action(resource, actionName, content, params, fields)](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#function-action) section.

The updated scripts will be copied promptly, but the time it takes for ForgeRock component to pick up the change will be affected by the configuration settings in the `script.json` file:

```json
    "ECMAScript" : {

        "javascript.recompile.minimumInterval" : 60000
    },
    "Groovy" : {

        "groovy.recompile.minimumInterval" : 60000

    }
```

You can change the minimum interval setting (in milliseconds) before you deploy or redeploy the sample.

***

#### <a id="idm-evaluating"></a>IDM > Evaluating Scripts

You can try out your script by validating it, as described in the [IDM Docs](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-endpoint). In order to be able to access the `/script` endpoint you will need to authorize your client for making request to the IDM `/script` endpoint. In ForgeOps, you would need to provide an access token from `amadmin` user. The token will need to be associated with the `openid` scope.

For this example, we will describe how you can create "scripts" OAuth 2.0 client in [ForgeRock Access Management](https://www.forgerock.com/platform/access-management) (AM), which can be performed with the following cURL command:

```bash
curl -k 'https://default.iam.example.com/am/json/realms/root/realm-config/agents/OAuth2Client/scripts' \
-X PUT \
-d '{
    "clientType": "Public",
    "redirectionUris": ["http://localhost:9999"],
    "scopes": ["openid"],
    "responseTypes": ["code"],
    "tokenEndpointAuthMethod": "client_secret_post",
    "isConsentImplied": true,
    "postLogoutRedirectUri": ["http://localhost:9999"]
    }' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
-H 'Cookie: iPlanetDirectoryPro='$(curl -k 'https://default.iam.example.com/am/json/realms/root/authenticate' \
    -X POST \
    -H 'X-OpenAM-Username:amadmin' \
    -H 'X-OpenAM-Password:password' \
    | sed -e 's/^.*"tokenId":"\([^"]*\)".*$/\1/' \
)
```

With the client in place, you can make an authorization request and obtain the access token. For example:

```bash
authz_code=$(curl -k -s -w "%{redirect_url}" 'https://default.iam.example.com/am/oauth2/authorize?response_type=code&client_id=scripts&redirect_uri=http://localhost:9999&scope=openid' \
-H 'Cookie: iPlanetDirectoryPro='$(curl -k -s 'https://default.iam.example.com/am/json/realms/root/authenticate' \
    -X POST \
    -H 'X-OpenAM-Username:amadmin' \
    -H 'X-OpenAM-Password:password' \
    | sed -e 's/^.*"tokenId":"\([^"]*\)".*$/\1/') \
| sed 's/^.*?code=\([^&]*\).*$/\1/') \
&& access_token=$(curl -k 'https://default.iam.example.com/am/oauth2/access_token' \
-X POST \
-d 'client_id=scripts&redirect_uri=http://localhost:9999&grant_type=authorization_code&code='$authz_code \
-H 'Content-Type: application/x-www-form-urlencoded' \
| sed 's/^.*"access_token":"\([^"]*\)".*$/\1/') \
&& echo $access_token
```

Then, you can validate the script by making a request to the `/script` end point and including the access token received from the authorization. You can provide script parameters under the "globals" namespace. For example:

```bash
curl -k -X POST \
'https://default.iam.example.com/openidm/script?_action=eval' \
-H 'Authorization: Bearer '$access_token \
-H 'Cache-Control: no-cache' \
-H 'Content-Type: application/json' \
-d '{
    "type": "javascript",
    "file": "example.js",
    "globals": {
        "params": {
            "url": "http://jsonplaceholder.typicode.com/users/1",
            "method": "GET"
        }
    }
}'
```

If the API call made from the script has been successful, you should see a JSON content returned which might look like the following:

```bash
{"status":"success","data":[{"id":"1","employee_name":"Tiger Nixon","employee_salary":"320800","employee_age":"61","profile_image":""}, . . . ,"code":200}
```

To evaluate the Groovy script you will need to change the "type" and the "file" values in the cURL request data:

```bash
curl -k -X POST \
'https://default.iam.example.com/openidm/script?_action=eval' \
-H 'Authorization: Bearer '$access_token \
-H 'Cache-Control: no-cache' \
-H 'Content-Type: application/json' \
-d '{
    "type": "groovy",
    "file": "example.groovy",
    "globals": {
        "params": {
            "url": "http://jsonplaceholder.typicode.com/users/1",
            "method": "GET"
        }
    }
}'
```

***

#### <a id="idm-debugging"></a>IDM > Debugging

While working on a script file you may have an option to use a debugger. We will provide an example of the debugging process based on a popular IDE for developing in Java and Groovy, [IntelliJ IDEA](https://www.jetbrains.com/idea/). You can check out details on setting debugging environment in [IntelliJ's docs](https://www.jetbrains.com/help/idea/creating-and-editing-run-debug-configurations.html), but the general steps are outlined below:

1. Open your ForgeOps clone in IntelliJ.

1. Select "Run" > "Edit Configurations...".

    1. Select "Add New Configuration" ("+") and select "Remote" in the list of predefined templates.

        1. In "Configuration" tab, provide or verify the defaults for the following settings:

            1. Debugger mode: Attach to remote JVM
            1. Host: localhost
            1. Port: 5005
            1. Command line arguments for remote JVM (for JDK 9 or later): -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
            1. Use module classpath: forgeops

        1. Provide "Name" for your new configuration; for example, "forgeops".

        1. Select "Apply" or "OK".

            <img alt="Run/Debug Configurations Window in IntelliJ" src="README_files/intellij.run-debug-configurations.png" width="700" />


1. In your staging area, under the IDM component directory, in Dockerfile (for example, in `/path/to/forgeops/docker/7.0/idm/Dockerfile`) change the environment variable `JAVA_OPTS` according to the debugging settings in the IDM project itself—as described in the [Starting in Debug Mode](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#starting-in-debug-mode) section of the IDM Integrator's Guide. For example, in `/path/to/idm/openidm-runtime/src/main/resources/startup.sh` you may find:

    ```java
    if [ "$JPDA" = "jpda" ] ; then
    if [ -z "$JPDA_TRANSPORT" ]; then
        JPDA_TRANSPORT="dt_socket"
    fi
    if [ -z "$JPDA_ADDRESS" ]; then
        JPDA_ADDRESS="5005"
    fi
    if [ -z "$JPDA_SUSPEND" ]; then
        JPDA_SUSPEND="n"
    fi
    if [ -z "$JPDA_OPTS" ]; then
        JPDA_OPTS="-Djava.compiler=NONE -Xnoagent -Xdebug -Xrunjdwp:transport=$JPDA_TRANSPORT,address=$JPDA_ADDRESS,server=y,suspend=$JPDA_SUSPEND"
    fi
    OPENIDM_OPTS="$OPENIDM_OPTS $JPDA_OPTS"
    fi
    ```

    The resulting line in your Dockerfile might look like this:

    ```docker
    ENV JAVA_OPTS "-Djava.compiler=NONE -Xnoagent -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n -server -XX:MaxRAMPercentage=75"
    ```

    Make sure that the port you use in IntelliJ and in the Dockerfile are the same.

1. Run the following command in your terminal against your ForgeOps deployment:

    ```bash
    kubectl port-forward idm-pod-name 5005:5005
    ```

    > You can see the pod names by running:
    > ```bash
    > kubectl get pods
    > ```

1. In IntelliJ, open a Groovy script located in your staging area that you'd like to debug; in our example, in `docker/7.0/idm/script/example.groovy`.

    Debugging a script in your staging area, with auto-sync or auto-deploy on, assures that you are debugging the same content as the one that is running in the container.

    In IntelliJ, you can now set breaking points in the script, start debugging, and then evaluate the script by making authorized request to the IDM `/script` endpoint. IntelliJ should react on messages coming from localhost:5005 and follow the code in your file.

***

#### Inline Scripts in Configuration Files

As described in the [Calling a Script From a Configuration File](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call) section of the IDM docs, script content can be provided directly in the code of an event handler in IDM. For example, you can invoke the inline equivalent of the groovy script when a managed object is updated in IDM by adding the following filter in `/path/to/staging/area/idm/conf/router.json`:

```json
{
    "filters" : [

        {
            "pattern" : "^(managed|system|internal)($|(/.+))",
            "onRequest" : {
                "type" : "groovy",
                "source" : "import org.forgerock.openidm.action.*\n\ndef result = openidm.action(\"external/rest\", \"call\", params)\n\nprintln result\n\nresult",
                "globals" : {
                    "params" : {
                        "url" : "http://jsonplaceholder.typicode.com/users/1",
                        "method" : "GET"
                    }
                }
            },
            "methods" : [
                "patch"
            ]
        },

    ]
}
```

In IDM, multiline scripts can be presented in the configuration files' JSON by concatenating the lines with the new line symbol, `\n`. To produce a visible effect for this script in the deployment logs, you can add `\nprint result` before the return statement, as shown in the example above.

When you change `router.json`, don't forget to build and deploy your sample, if this is not done automatically.

#### Inline Scripts in IDM Admin

Some configuration options can be associated with scripts in the IDM Admin UI.

To experience it first hand, you could, for example, sign in at `https://default.iam.example.com/admin`, navigate to CONFIGURE > MANAGED OBJECTS > USER, and select the Scripts tab. Here, you'll be provided with a choice of modifying one of the existing scripts or creating a new one:

<img src="README_files/idm.admin.managed-object.user.script-manager.scripts.png" alt="IDM Admin, Configure Manged Object, User, Scripts" width="700">

Select Edit or Add Script button for an event associated with User object and populate the provided in Script Manager window input area with the content from a script file you've created earlier. Don't forget the parameters the script is expecting to receive. And make sure you selected the correct script engine from the Type dropdown. For example:

<img src="README_files/idm.admin.managed-object.user.script-manager.script.groovy.png" alt="IDM Admin, Configure Manged Object, User, Script, Groovy" width="700">

Select Save.

Now, if you trigger the event you associated your script with, for example update a user attribute (triggering `onUpdate`) or open a user record in the admin (triggering `onRead`), you may observe in the IDM pod logs the printed results of the network call (if it succeeded).

## <a id="overview-ig"></a>IG

[Back to Contents](#contents)

Scripts in IG may be associated with one of the [scriptable object types](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#script-conf).

Similar to IDM, IG allows to specify script content either inline in a configuration file or in a designated script file. In either case, only the `application/x-groovy` MIME type is supported. Similar to IDM, IG scripts accept parameters provided as the `args` key in the script configuration. For example, the following [ScriptableFilter](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableFilter) definition may be a part of a [Chain Handler](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Chain) and use `example.groovy` script to process the request:

```json
{

     "handler": {
        "type": "Chain",
        "config": {
            "filters": [

                {
                    "name": "ScriptableFilter",
                    "type": "ScriptableFilter",
                    "config": {
                        "args": {
                            "url": "http://jsonplaceholder.typicode.com/users/1",
                            "method": "GET"
                        },
                        "type": "application/x-groovy",
                        "file": "example.groovy"
                    }
                },

            ],
            "handler": "someHandler"
        }
}
```

The script itself, functionally very similar to the one we used in IDM, might look like the following:

```groovy
def call = new Request()
call.setUri(url)
call.setMethod(method)

http.send(call)
.thenOnResult { response ->
    def result = response.entity.json

    println result

    response.close()
}
.thenAsync({
    next.handle(context, request)
} as AsyncFunction)
```

For making the dummy API call, the script is using an [HTTP Client](https://backstage.forgerock.com/docs/ig/6.5/apidocs/org/forgerock/http/Client.html) represented by the `http` object, one of the available objects described in [Scripts Configuration](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#script-conf) in IG docs. We use `thenOnResult` notification (and you can compliment it with `thenOnException`) because in this example we do not use the results of the dummy request, except printing them in the IG pod's logs for demonstration purposes. Once that Promise is complete, `thenAsync` calls the next filter or handler in the chain by returning `next.handle(context, request)`. You can find more details on using IG's non-blocking APIs in scripts in [this Knowledge Base article](https://backstage.forgerock.com/knowledge/kb/article/a77687377).

A multiline script can be defined in a configuration file as an array of strings. Then, an equivalent of the above script might look like the following:

```json
[
    {" . . . "},
    {
        "name": "ScriptableFilter",
        "type": "ScriptableFilter",
        "config": {
            "args": {
                "url": "http://jsonplaceholder.typicode.com/users/1",
                "method": "GET"
            },
            "type": "application/x-groovy",
            "source": [
                "def call = new Request();",
                "call.setUri(url);",
                "call.setMethod(method);",

                "http.send(call)",
                ".thenOnResult { response ->",
                    "def result = response.entity.json;",

                    "println result;",

                    "response.close();",
                "}",
                ".thenAsync({",
                    "next.handle(context, request);",
                "} as AsyncFunction);"
            ]
        }
    },
    {" . . . "}
]
```

## <a id="conclusion"></a>Conclusion

[Back to Contents](#contents)

The scripting objectives and implementation are driven by the product's functionality and the environment it provides. Hence, the scripts' location, configuration, security, the data and methods a script can use, and the way the scripts are managed are specific to a product.

There are certain similarities as well: the choice of scripting languages, ability to access the underlying Java functionality and the context data, logging methods, access to the request object, and ability to make back-channel HTTP requests—all converge into a similar experience at certain level.

Scripts add flexibility to the ForgeRock Identity Platform. Custom scripts can be used to substitute functionality that is not yet present in the software or is specific to a certain deployment.

## <a id="summary"></a>Summary

[Back to Contents](#contents)

This section is a non-exhaustive overview of different scripting aspects in the three products.

The [References](#references) section contains collection of links to the official scripting documentation. The links are organized by product and by area of concern.

* ### <a id="summary-application-and-environment"></a>Application and Environment

    Scripting application is augmenting or extending native functionality of a product. The extension points could be events associated with an object or a procedure; for example, an update event on a managed object in IDM. Or, the scripts could represent a procedure; for example, scripts performing authentication in AM.

    Scripts' environment could be described as access to methods and data. This may depend on the context the script is running in: the product and the particular procedure the script is extending. Even within the same product, the context may vary as the product components implement different functionality and expose different APIs.

    ### <a id="summary-application-and-environment-am"></a> AM

    #### <a id="am-scripting-client-side"></a>AM > Client-Side Scripts

    Scriptable access to the browser environment is a unique feature of authentication procedures in AM, in comparison to the other script applications in the three products.

    #### <a id="am-scripting-server-side"></a>AM > Server-Side Scripts

    All server-side scripts have access to the following functionality:

    * [Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-http-client) with the client object, httpClient, and the `org.forgerock.http.protocol` package.

        From scripts, AM makes synchronous network requests with the HTTP client object. The requests are blocking until the script returns or times out. The latter is defined in the Server-side Script Timeout setting. The setting could be in the AM console under Configure > Global Services > Scripting > Secondary Configurations > AUTHENTICATION_SERVER_SIDE > Secondary Configurations > EngineConfiguration.

    * [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger) with the `logger` object methods.

    Although via different methods and objects, the server-side scripts are also capable of:

    * Accessing request data.

        Limited to request headers in authentication nodes.

    * Accessing profile data, when `username` is available.

        This means read, add, and update access to the AM identity attributes.

    * Accessing existing session data.

    In addition:

    * Authentication scripts in chains have access to authentication state, `authState`, indicating the outcome of the current authentication in either `SUCCESS` or `FAILED` value.

    * Authentication scripts in trees can set and access properties in the `sharedState` object and in `transientState` object; the latter may not persist through authentication and is designated for sensitive information like passwords.

    * Scripted policy decision scripts have access to the authorization state, passed in data, and username; they can set attributes in the authorization response.

    * OAuth2 Access Token Modification script has access to the access token and to the scope associated with the authorization request.

    * OIDC Claims Script has access to the server default and the requested claims information.

    You can find details on APIs available to server-side scripts in AM in the docs, under [Developing with Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts), [Scripting a Policy Condition](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/index.html#sec-scripted-policy-condition), and [Modifying Access Token Content Using Scripts](https://backstage.forgerock.com/docs/am/6.5/oauth2-guide/index.html#modifying-access-tokens-scripts).


    The server-side scripts can load available Java classes and packages. [OpenAM Server Only 6.5.2.3 Documentation](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html) describes the single default source of Java functionality available for the server-side scripts, although some features may only make sense in certain contexts.

    > For example, the `org.forgerock.openam.auth.node.api.Action` class, representing [The Action Interface](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-action), is applicable only in the context of authentication nodes and trees, but it is not usable in authentication modules.
    >
    > Extending AM with custom Java development is available via plugins, modules, and nodes and is described in part in [Customizing Authorization](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/index.html#chap-authz-customization) and [Customizing Authentication](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#chap-authn-customization) chapters of the corresponding guides.

    #### <a id="am-trees-and-chains"></a>AM > Server-side Scripts in Authentication Chains and Authentication Trees

    The server-side authentication functionality can accept data collected by the client-side scripts, but the way the data is sent and received depends on the type of the authentication flow.

    AM supports two types of authentication: with [Authentication Modules and Chains](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#about-authentication-modules-and-chains) and with [Authentication Nodes and Trees](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-about-authentication-trees).

    A scriptable authentication module can use a pair of client-side and server-side scripts. Data collected with the client-side script can be used to populate the `output` input in automatically provided form. The form can be submitted to the server, automatically or by using provided `submit()` method. Then, the string value of the `output` input becomes available to the server-side script as a well-known variable, `clientScriptOutputData`.

    A scriptable authentication node in a tree can run arbitrary JavaScript on the client-side and receive data back by using interactive features named [callbacks](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node-callbacks), as described in [Sending and Executing JavaScript in a Callback](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#client-side-javascript) in Authentication Node Development Guide.

    ### <a id="summary-application-and-environment-idm"></a> IDM

    IDM manages identities within and across identity stores. Seemingly, at any stage of this process scripts can be applied as a part of a security decision, managed object action, event handler, or validation policy, custom endpoint action, synchronization procedure, or connection to backend resource. The major applications could be categorized as the following:

    * Managed Object

        * Events (Triggers), such as onCreate, onUpdate, onDelete, etc.
        * Custom Scripted Actions, performed in the context of the managed object.

    * Synchronization Service

        * Events—such as onCreate, onUpdate, onDelete, etc., or successful reconciliation—defined via Object-Mapping Objects.
        * Correlation scripts, to determine unlinked target object.
        * Filtering the source.
        * Validating the source and the target.

    * Scripted Policies, used for data validation in Managed Objects and Synchronization Service.

    * Authentication, when security context is augmented with a script.

    * Authorization, implemented with scripts and extendable with scripts.

    * Scripted Connectors, to communicate with specific identity providers/resources.

    * Custom Endpoints, providing arbitrary functionality over REST API.

    * Activiti Workflows, referencing a Groovy script.

    In addition:

    * Router Service, provides the uniform interface to all IDM objects, and its conditions and event handlers can be scripted.

    > The events by which scripts can be invoked are also summarized in [Places to Trigger Scripts](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#script-places).
    >
    > Links to documentation where various aspects of scripts' application and environment are covered in details could be found at the end of this writing, in [References > IDM > Application and Environment](#references-idm-application-and-environment).

    A script scope will depend on the script's application. [Variables Available to Scripts](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#script-variables) and [Router Service Reference > Script Scope](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#filter-script-scope) provide detailed information on the context information available to scripts in IDM.

    [Variables Available to All Groovy Scripts](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#groovy-script-variables) in the Connector Developer's Guide describe the scripted connectors scope.

    In addition, in a script configuration, you can provide arbitrary arguments, defined as JSON (normally, under the "globals" namespace). Any bindings specified by a scripted connector author can also be made available to the script. Properties provided to the script engine (in `conf/script.json`, as described in [Integrator's Guide > Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config)) may also be available in scripts.

    The functionality supported by the script engine in IDM is available to scripts via the `openidm` object and described in [Integrator's Guide > Scripting Reference > Function Reference](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#function-ref). Scripted connectors have access to the [ICF framework](https://backstage.forgerock.com/docs/idm/6.5/apidocs/) framework.

    In addition, you can [use custom Java packages](https://backstage.forgerock.com/knowledge/kb/book/b51015449#custom_package) and [load JavaScript functions](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a44445500) in scripts, and [invoke a jar file from a Groovy script](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a38809746).

    ### <a id="summary-application-and-environment-ig"></a> IG



    As you could observe, the context of a server-side script largely depends on the functionality the script extends, although some global APIs are universally available within a product.

    Some methods and data, provide same functionality but via different implementations. Consider, for example, making back-channel outbound HTTP call in all three products:

    ```groovy
    // AM

    import groovy.json.JsonSlurper;

    def request = new Request();
    request.setUri("https://jsonplaceholder.typicode.com/users");
    request.setMethod("GET");

    def response = httpClient.send(request).get();
    def result = new JsonSlurper().parseText(response.getEntity().toString());
    ```

    ```groovy
    // IDM

    import org.forgerock.openidm.action.*

    def result = openidm.action("external/rest", "call", {
        "url": "https://jsonplaceholder.typicode.com/users",
        "method": "GET"
    });
    ```

    ```groovy
    // IG

    def call = new Request();
    call.setUri("https://jsonplaceholder.typicode.com/users");
    call.setMethod("GET");

    return http.send(call)
    .thenOnResult { response ->
        def result = response.entity.json;

        logger.info("Call result: " + result);

        response.close();
    }
    .thenAsync({
        next.handle(context, request);
    } as AsyncFunction)
    ```

    A notable difference in IG implementation here is that it allows for asynchronous operation.

* ### <a id="summary-managing-scripts"></a>Management and Configuration

    ### IDM

    In IDM, the scripts can be managed directly in separate files and referenced from the configuration. The configuration can be itself managed directly in the file system. Alternatively configuration files may be populated with the script content.

    ### IG

    ### Configuration File Syntax in IDM and IG

    * IDM

        ```json
        {
            "type" : "javascript|groovy",
            "source|file" : "code|URI",
            "globals" : {}
        }
        ```

    * IG

        ```json
        {
            "name": "name",
            "type": "ScriptableFilter|ScriptableHandler|ScriptableThrottlingPolicy|ScriptableAccessTokenResolver|OAuth2ResourceServerFilter",
            "config": {
                "type": "application/x-groovy",
                "file": "SimpleFormLogin.groovy",
                "args": {}
            }
        }
        ```

* ### <a id="summary-languages"></a>Languages

    All three components support server-side scripting in Groovy.

    For supporting server-side JavaScript, AM and IDM use [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino)—the scripting engine that has access to the Java environment provided by the products.

    > At the time of this writing, the 6.5 version of AM use Rhino version 1.7R4 and IDM was using version 1.7.12_1. Both products use Groovy version 2.5.7.

    AM allows for client-side scripts, which run in the browser environment and have to comply with it.

    IDM does not support custom client-side JavaScript.

    IG does not currently support JavaScript in any form.

    It is tempting to say that for server-side scripts, Groovy is a preferable choice as it better integrates with the underlying Java environment. However, when supported, JavaScript can reproduce the same functionality and may be simpler to deal with for those who are familiar with the language and its ecosystem, especially in IDM, which allows to [load CommonJS modules](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a44445500).

* ### <a id="summary-security"></a>Security

    * Across products, administrative access is required for script management.

    1. AM

        * Java Class Whitelist
        * Java Class Blacklist

    1. IDM

        * No script specific security?

    1. IG

        * No script specific security?

* ### <a id="summary-debugging"></a>Debugging

    ### <a id="summary-debugging-am"></a> AM

    AM does not provide an option for connecting a debugger. However, Global Scripting API Functionality facilitates [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger), which you can set as described in this Setup and Maintenance Guide chapter.

    Debug logging for scripting service and individual scripts could be configured as described in the Development Guide at [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger).

    > AM server debugging configuration can be found in the administrative console under CONFIGURE > SERVER DEFAULTS > General > Debugging. The Debug Directory setting specifies location of the log files. Managing server-wide debugging settings is described in the Setup and Maintenance Guide under [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#sec-maint-debug-logging).

    For example, for the server-side scripts defined in AM console that are a part of an authentication chain, like the one we created, you could navigate to the `your-am-instance/Debug.jsp` page, select "amScript" for Debug instances and "Message" for Level. Then, whenever in your script you use `logger.message` method, the output will be saved in the logs, along with any warnings and errors.

    Then, to access the logs, you can navigate to `your-am-instance-debugging-directory` in Terminal and `tail -f` the log file of interest; in this case the `Authentication` file.

    Alternatively, during development, you could use the `logger.error` method without changing the default debugging configuration, for the "Error" level is always on.

    > JavaScript `console.log` and Rhino's `print` are not implemented for server-side scripts. The client-side JavaScript can output logs into the browser's console as usual.


    The Debug instances input on `your-am-instance/Debug.jsp` page will list the Decision Node scripts in the following format:

    scripts.AUTHENTICATION_TREE_DECISION_NODE._script-id_

    The script ID part correspond to the Realms > _Realm Name_ > Scripts > _script-id_ in AM console on a script details page. For example:

    <img alt="Script ID in AM Console" src="README_files/am.scripts.script-id.png" width="1024" />

    <img alt="Script ID on the Debug.jsp page" src="README_files/am.debug.debug-instances.script-id.png" width="1024" />

    When a script associated with the Scripted Decision node outputs logs (at the allowed level set with `Debug.jsp`), the script specific log file is created under `your-am-instance-debugging-directory`. For example:

    ```bash
    $ cd ~/openam/am/debug$
    $ ls
    Authentication  CoreSystem  IdRepo  scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc
    ```

    ```bash
    $ tail -f scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc
    scripts.AUTHENTICATION_TREE_DECISION_NODE.fe4a7e3e-aa1d-4d2d-82ad-4830d0c98adc:04/26/2020 07:34:02:654 PM GMT: Thread[ScriptEvaluator-5,5,main]: TransactionId[88093018-65c0-4987-b7af-ef1429ac1c04-46398]
    ERROR: Helpful error description.
    ```

    If an error occurs that is not handled within the script itself, it may be reported in the Authentication log. For example, it you try to employ a Java package that is not white listed in the scripting engine settings, the "Access to Java class . . . is prohibited." error will appear in the Authentication log.

    > In the example above, parsing JSON with `groovy.json.JsonSlurper` (in the Groovy version of the script) would require the `groovy.json.internal.LazyMap` class to be allowed in the scripting engine setting. For getting identity with the `IdUtils` method, `com.sun.identity.idm.AMIdentity` would have to be white listed.

    You can specify allowed and dis-allowed Java classes in AM administrative console at Realms > _Realm Name_ > Configure > Global Services > Scripting > Secondary Configurations > AUTHENTICATION_TREE_DECISION_NODE > Secondary Configurations > EngineConfiguration > Java class whitelist/Java class blacklist.

    ### <a id="summary-debugging-idm"></a> IDM

    ### <a id="summary-debugging-ig"></a> IG

## Summary Table for Server-Side Scripts

| Script Feature | IDM | IG | AM |
|-|-|-|-|
| Type/Language | `text/javascript`, `groovy` | `application/x-groovy` | JavaScript  (Rhino), JavaScript (browser), Groovy<br>Depends on script's `context` type (labeled `Script Type` in AM Console) |
| Configuration | Part of a configuration file (JSON) | Part of a configuration file (JSON) | Defined in AM console and saved in encoded form in a configuration file in the `amster` pod file system (`/opt/amster/config/realms/root/Scripts`) |
| Managing | File, JSON configuration, Script Manager | File, JSON configuration, Studio (may not be available in ForgeOps) | AM Console, REST, `ssoadm` command |
| Validation | REST | | AM Console, REST |
| Multiline Source | `\n` | Array (of strings) | UI editor |
| Arguments | The `globals` namespace | `args` key | Direct editing |
| Access to | `openidm` functions, request, context, managed object, resource information, operation results | request, context, etc., [Properties, Available Objects, and Imported Classes](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#script-conf) | Depends on context |
| Other Context Differences | | |
| Extras | | Capture Decorator | |
| Security | | | Security Settings Component: Java Class White/Black Lists, System (JVM) SecurityManager|
| Debugging | Debugger can be attached | | [Debug Logging](https://backstage.forgerock.com/docs/am/6/dev-guide/#scripting-api-global-logger) |
| Particularities | | | User-created scripts are realm-specific |
| HTTP Request | | | `org.forgerock.http.protocol`, Synchronous [Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6/dev-guide/#scripting-api-global-http-client)|
| Exported Scripts Location | | | `/path/to/forgeops/docker/6.5/amster/config/realms/root/Scripts` |

