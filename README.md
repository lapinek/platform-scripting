
# <a id="top"></a>Scripting in ForgeRock Platform Components

ForgeRock Identity Platform components, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript and Groovy.

Scripting is broadly used in the components and broadly covered across [ForgeRock Product Documentation](https://backstage.forgerock.com/docs/). There are many articles describing scripting environment and application, often in a context of particular task and supplied with examples. Other places in the documentation cover functionality that is not directly related to scripting, but can be employed by scripts.

This writing aims at a quick introduction to scripting in the Platform via the references, comparing the scripting environments, and an example of a script with some additional details to compliment the official docs.

## Contents

* [An Example of Scripting in ForgeRock Components](#example)
    * [AM](#example-am)
    * [IDM](#example-idm)
    * [IG](#example-ig)
* [Summary](#summary)
* [Conclusion](#conclusion)
* [References](#references)

## <a id="example"></a>An Example of Scripting in ForgeRock Components

[Back to the Top](#top)

To compare scripting environments provided by ForgeRock components, we will create a script that will make an HTTP call to an online service and receive a response in the form of JSON, which the script could evaluate against other data accessible in the script's environment.

<!-- >> If you use server-side scripts to access an API over encrypted connection, you will make sure the scripting engine's Java trusts the underlying SSL/TLS certificate. -->

This is just one possible scripting application in ForgeRock products, but it will expose scripts' management, configuration, environment, and debugging options in the three products.

## <a id="example-am"></a>AM

[Back to the Top](#top)

AM provides authentication and authorization services, and custom scripts can be used to augment the default functionality.

### Managing Scripts in AM

The [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts) chapter shows how the scripts can be managed via REST and command line interfaces. These may represent the most efficient way to manage scripts in automated environments; for example, in production deployments.

At the same time, AM console provides an easy to use visual interface for managing scripts and applying them to authentication and authorization events. For the example purposes, we will use AM console to extend an authentication procedure with a script.

### Client-Side Scripts

When used for authentication in the front channel, AM allows for creating client-side scripts that would be executed in the user agent.

The use case for a client-side script is collecting information about the user agent's properties and its environment: [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/geolocation), IP, and whatever else that could be collected with a custom script running in a browser. Thus, the script needs to be written in JavaScript compatible with the browser.

The data collected by a client-side script can be submitted to the server side and become available for the server components involved in the same authentication procedure.

### Server-Side Scripts

The decision making process on user identification and access management can be aided with the server-side scripts. The server-side scripts can be written in Groovy or JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino).

> At the time of writing, the 6.5 version of AM is using Rhino version 1.7R4.

The server-side scripts can accept data from the client-side ones, but the way the data is sent and received depends on the type of the authentication flow.

### Authentication Chains and Authentication Trees

AM supports two types of authentication: with [Authentication Modules and Chains](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#about-authentication-modules-and-chains) and with [Authentication Nodes and Trees](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-about-authentication-trees).

A scriptable authentication module can use a pair of client-side and server-side scripts. Data collected with the client-side script can be submitted to the server as a single input and become available to the server-side script as a well-known variable.

A scriptable authentication node in a tree can run arbitrary JavaScript on the client-side and receive data back by using interactive features named [callbacks](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node-callbacks), as described in [Sending and Executing JavaScript in a Callback](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#client-side-javascript) in Authentication Node Development Guide.

In the following examples we will implement both.

### Scripting Authentication Chain Example

To outline basic principles of scripting authentication chains in AM, we offer an example of extending the authentication flow with a pair of simple client-side and server-side scripts.

> You can find links to official examples in the [References](#references) section of this writing, including detailed instructions on how to set up an authentication chain.

Sign in as an AM administrator, for example amadmin.

1. The Client-side Script

    The script will load an external library and make an HTTP request in order to get the client's IP information.

    1. Navigate to Realms > _Realm Name_ > Scripts

        You will see number of predefined scripts, some of which can serve as templates for the new ones. In particular, Scripted Module - Server Side example script will be the starting point for any added script of the Server-side Authentication type.

    1. Select + New Script

        In the New Script dialog, populate the inputs:

        * Name:  _Your Scripted Module Client Side Script_
        * Script Type: Client-side Authentication

        Select the Create button.

    1. In the next dialog, with the new script properties, populate the Script input with the following JavaScript code:

        * Language: JavaScript (disabled)

            The language for a client-side script is always JavaScript, for the script run time environment is going to be a browser.

        * Script:

            ```javascript
            var script = document.createElement('script'); // 1

            script.src = 'https://code.jquery.com/jquery-3.4.1.min.js';
            script.onload = function (e) { // 2
                $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
                    output.value = JSON.stringify({
                        ip: json
                    }); // 3

                    submit(); // 4
                });
            }

            document.getElementsByTagName('head')[0].appendChild(script); // 1

            autoSubmitDelay = 4000; // 5
            ```

            1. Script element is created and added to the page in the browser for loading an external library.

            2. When the script is loaded, it will make a request to an external source to obtain the client's IP information.

            3. The information, received as a JSON object, is then saved as a string in the `output` input of the form automatically provided on the client side.

                The expected result returned from the call to `https://ipgeolocation.com/?json=1` is a JSON containing client IP data. The data might look like the following:

                ```json
                {
                    "ip": "73.67.228.195",
                    "city": "Portland",
                    "region": "Oregon",
                    "country": "United States",
                    "coords": "45.547200,-122.641700",
                    "asn": "AS7922, Comcast Cable Communications, LLC",
                    "postal": "97212",
                    "timezone": "America/Los_Angeles"
                }
                ```

                The script uses stringified form of this data to populate the `output` input in the form on the page where the client-side script is running. When the form is auto-submitted, the posted value becomes available for the server-side scripts as the `clientScriptOutputData` variable.

                (See [Accessing Client-Side Script Output Data](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#scripting-api-authn-client-data) for details.)

            4. When the HTTP call is complete the form can be submitted.

            5. If the HTTP call takes too long to complete, the form is automatically submitted after the specified timeout, via a conventional setting that takes milliseconds.

            Select the Save Changes button.

    1. You can return to the script and change its definition by navigating to Realms > _Realm Name_ > Scripts >  Scripted Module - Client Side - Example

1. The Server-side Script

    The `Scripted Module - Client Side` script, included in AM configuration by default, serves as a starting template for all new scripts of type "Server-side Authentication". In our example, we will replace its content with functionality that relies on the results delivered by our client-side script.

    1. Navigate back to Realms > _Realm Name_ > Scripts

    1. Select + New Script

        In the New Script dialog, populate the inputs:

        For example:

        * Name:  _Your Scripted Module Server Side Script_
        * Script Type: Server-side Authentication

        Select the Create button.

    1. In the following dialog, populate the Language and the Script inputs:

        * Language: JavaScript

            For a Server-side script, you will be given a choice of language: JavaScript or Groovy. For the JavaScript version, the script might look like the following:

        * Script:

            ```javascript
            var failure = true; // 1

            try {
                var ip = JSON.parse(clientScriptOutputData).ip; // 2
                var postalAddress = idRepository.getAttribute(username, 'postalAddress'); // 3

                failure = postalAddress.toArray()[0].indexOf(ip.postal) === -1 // 4
            } catch (e) {
                logger.error(e.name + ': ' + e.message + ' Line Number: ' + e.lineNumber);
            }

            if (failure) {
                logger.error('Authentication denied.');

                authState = FAILED; // 5
            } else {
                logger.message('Authentication allowed.');

                authState = SUCCESS; // 5
            }
            ```

            1. We set expectations low and only allow for the success if everything checks out.

            2. The data submitted from the client-side script is a stringified JSON. It is used to create a JavaScript object so that its individual properties can be easily accessed.

            3.  `idRepository` object is a part of the APIs available for scripts used in authentication modules. Using its methods, we can get the user's postal address as it exists in the identity managed in AM.

                We assume that in this authentication process the user identity is checked with the `DataStore` authentication module and the login name of the user is available via the `username` variable. With this, an attribute can be requested from the corresponding identity.

            4. The user's postal address is compared with the zip code obtained from the online service.

                The value received from the `getAttribute` method is a Java `HashSet`; we convert it to a String and try to find the current client's zip code in the string.

                In this example, finding the current zip code in the user's address means success, but it could also be determined by checking the client's IP against a white list, for example.

            5. Depending on results that the script produces, the authentication state is set to define outcome of the module.

            As described in [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn), the functional part of the script have access to number of APIs and data objects.

            In addition, the [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global) allows for making HTTP requests to external resources, which is illustrated in the `Scripted Module - Server Side` and `Scripted Policy Condition` server-side scripts included in the default AM installation.

1. Authentication Module and Chain

    1. Navigate back to Realms > _Realm Name_ > Authentication > Modules.

    1. Select + Add Module.

        In the New Module dialog, populated the inputs:

        * Name:  _Your Scripted Module_
        * Script Type: Scripted Module

        Select the Create button.

    1. In the following dialog, populate the inputs as follows:

        * Client-side Script: Enabled
        * Client-side Script: _Your Scripted Module Client Side Script_
        * Server-side Script:  _Your Scripted Module Server Side Script_
        * Authentication Level: 1 (default)

    1. Navigate back to Realms > _Realm Name_ > Authentication > Chains.

    1. Select + Add Chain.

    1. In the Add Chain dialog, populate the Name input:

        * Name: _Your Chain_

        Select the Create button.

    1. In the following dialog, select + Add Module.

    1. In the popup windows, populate the inputs:

        * Select Module: DataStore
        * Select Criteria: Required

        Select the OK button.

    1. In the Edit Chain screen, select + Add Module.

    1. In the popup windows, populate the inputs:

        * Select Module: _Your Scripted Module_
        * Select Criteria: Required

        Select the OK button.

    1. In the Edit Chain screen, select the Save Changes button.

    > If you are unsure how to use scripts in an authentication chain, [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) provide comprehensive coverage for how the scripts can be employed in an authentication chain.

1. Data preparations

    To make a positive comparison with data delivered from the client script, you will need to add corresponding values to the identity with which you try to sign in AM. Out of the box, there should be `postalAddress` attribute associated with an identity, which can be updated in version 6.5 of AM administrative console via Realms > _Realm Name_ > Identities > _Identity_.

    > If you'd like to use custom identity attributes, their management is covered in [Setting Up Identity Stores](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#chap-maint-datastores).

1. Debugging

    AM does not provide an option for connecting a debugger. However, Global Scripting API Functionality facilitates [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger), which you can set as it is described in the Setup and Maintenance Guide.

    For example, for the scripts defined in AM console that are a part of an authentication chain, like the one we created, you could go to the `your-am-instance/Debug.jsp` page, select "amScript" for "Debug instances" and "Message" for "Level". Then, wherever in your script you use `logger.message` method, the output will be saved in the logs, along with warnings and errors.

    Then, to access the logs, you can navigate to the `your-am-instance/debug` directory in Terminal and `tail -f` the log file of interest; in this case the `Authentication` file.

    Alternatively, during development, you could use the `logger.error` method without changing the debugging configuration, for the "Error" level is the necessary one for all components in AM.

### Scripting Authentication Trees

As authentication proceeds, nodes in a tree may capture information and save it in shared and authentication states available for next node in the tree.

1. The Simple Example

    An equivalent of the client-side executed script used as an example above in an authentication chain, in an authentication tree, being used by the Scripted Decision node, might look like the following (in a Groovy implementation):

    ```groovy
    /*
    - Data made available by nodes that have already executed
        are available in the sharedState variable.
    - The script should set outcome to either "true" or "false".
    */

    // import static org.forgerock.json.JsonValue.*;
    import org.forgerock.openam.auth.node.api.*; // 1

    import com.sun.identity.authentication.callbacks.ScriptTextOutputCallback; // 2
    import com.sun.identity.authentication.callbacks.HiddenValueCallback; // 2

    def script = ''' // 5
    var script = document.createElement('script'); // 6

    script.src = 'https://code.jquery.com/jquery-3.4.1.min.js';
    script.onload = function (e) { // 2
        $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
            document.getElementById('ip').value = JSON.stringify(json); // 7

            document.getElementById("loginButton_0").click();
        });
    }

    document.getElementsByTagName('head')[0].appendChild(script); // 6

    setTimeout(function () {
        document.getElementById("loginButton_0").click()
    }, 44000); // 8
    '''

    if (callbacks.isEmpty()) { // 9
        action = Action.send([
            new HiddenValueCallback("ip", "false"),
            new ScriptTextOutputCallback(script)
        ]).build();
    } else {
        def failure = true;

        if (callbacks[0].getValue() != "ip") { // 10
            sharedState.put("ipString", callbacks[0].getValue());

            failure = false;
        }

        if (failure) {
            action = Action.goTo("false").build();
        } else {
            action = Action.goTo("true").build();
        }
    }
    ```

    The next node in the tree will be able to retrieve the IP information by querying the shared state. For example:

    ```groovy
    /*
    - Data made available by nodes that have already executed are available in the sharedState variable.
    - The script should set outcome to either "true" or "false".
    */

    import org.forgerock.openam.auth.node.api.*; // 1

    // import com.sun.identity.idm.AMIdentity; // 2
    import com.sun.identity.idm.IdUtils; // 3

    import groovy.json.JsonSlurper; // 4

    def ip = new JsonSlurper().parseText(sharedState.get("ipString"));
    def id = IdUtils.getIdentity(sharedState.get("username"), sharedState.get("realm"));

    def failure = id.getAttribute("postalAddress").toArray()[0].indexOf(ip.postal) == -1;

    if (failure) {
        action = Action.goTo("false").build();
    } else {
        action = Action.goTo("true").build();
    }
    ```

    Or, a JavaScript equivalent:

    ```javascript
    var goTo = org.forgerock.openam.auth.node.api.Action.goTo;
    var getIdentity = com.sun.identity.idm.IdUtils.getIdentity;

    var ip = JSON.parse(sharedState.get("ipString"));

    var id = getIdentity(sharedState.get("username"), sharedState.get("realm"));

    var failure = id.getAttribute("postalAddress").toArray()[0].indexOf(ip.postal) == -1;

    if (failure) {
        action = goTo("false").build();
    } else {
        action = goTo("true").build();
    }
    ```

    The authentication tree might look like the following:

    <img src="README_files/am.authentication-tree.scripted-decision-module.png" alt="Authentication Tree with the Scripted Decision node." width="1024">

    Alternatively, the client-side data could be processed in the same Scripted Decision node.

    In future versions of AM, there may already be predefined nodes to perform certain client-side operations. There is also an authentication node for version 6.5 that allows to run custom JavaScript in the user's browser: [Client Script Auth Tree Node](https://backstage.forgerock.com/marketplace/api/catalog/entries/AWAm-FCxfKvOhw29pnIp).

    References:

    * ["Scripted Decision Node API Functionality"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#scripting-api-node). Authentication and Single Sign-On Guide.
    * ["Scripted Decision Node"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#auth-node-scripted-decision). Authentication and Single Sign-On Guide.
    * ["Using Callbacks"](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node-callbacks). Development Guide.
    * ["Supported Callbacks"](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#supported-callbacks). Development Guide.
    * ["Sending and Executing JavaScript in a Callback"](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#client-side-javascript).  Authentication Node Development Guide.
    * ["Accessing an Identity's Profile"](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#accessing-user-profile). Authentication Node Development Guide.

1. Debugging

    If a script associated with the Scripted Decision node outputs logs of the allowed level set with Debug.jsp, the script specific log file is created under the `your-am-instance/debug` directory. For example:

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

    References

    * ["Debug Logging"](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#sec-maint-debug-logging). Setup and Maintenance Guide.
    * ["Scripted Authentication Module Properties"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#authn-scripted). Authentication and Single Sign-On Guide.

## <a id="example-idm"></a>IDM

[Back to the Top](#top)

See [IDM Docs](https://backstage.forgerock.com/docs/idm) for version-specific, comprehensive, and easy to read technical information about the component.

Basic information about scripting in IDM can be found in its Integrator's Guide, in the [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting) chapter, and in other sections of the documentation that have been referenced from there.

Scripts in IDM could be associated with its endpoints or events connected to managed objects.

As the docs state, the custom scripts could be written in JavaScript or Groovy. In this writing, we will create both versions of an example script to run against the default environment defined in the `/path/to/idm/conf/script.json` file (under the IDM installation in the running container); for example, in `/opt/openidm/conf/script.json`. If a corresponding file is defined in the staging area, in `/path/to/forgeops/docker/7.0/idm/conf/script.json` in the described here example, this file will be copied to the container when it is deployed.

### The Scripts' Location

The script content can be defined either inline in a configuration file (that is, a file under the `/path/to/idm/conf` directory), or in a script file. For the purposes of this example, we will use the latter option, as it provides a comfortable environment for writing multiline scripts and additional options for debugging.

> Depending on your deployment strategy, defining scripts in files may not be supported, but it is an option in the described here environment which will allow us to demonstrate general principles for scripting in IDM.

The locations that IDM is aware of and will read a script file from are defined in the `sources` key in the  `script.json` file:

```json
    "sources" : {
        "default" : {
            "directory" : "&{idm.install.dir}/bin/defaults/script"
        },
        "install" : {
            "directory" : "&{idm.install.dir}"
        },
        "project" : {
            "directory" : "&{idm.instance.dir}"
        },
        "project-script" : {
            "directory" : "&{idm.instance.dir}/script"
        }
    }
```

We will place the example scripts in the location denoted as `"&{idm.instance.dir}/script"`, which corresponds to `/path/to/idm/script` in the running IDM container and `/path/to/forgeops/docker/6.5/idm/script` in the staging area. You can navigate there and create `example.js` file with the following content:

```javascript
(function () {
    var result = openidm.action("external/rest", "call", params)

    return result
 }())
 ```

An equivalent in `Groovy` might look like the following:

```groovy
import org.forgerock.openidm.action.*

// final params = params as Map

def result = openidm.action("external/rest", "call", params)

println result

return result
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
        . . .
        "javascript.recompile.minimumInterval" : 60000
    },
    "Groovy" : {
        . . .
        "groovy.recompile.minimumInterval" : 60000
        . . .
    }
```

You can change the minimum interval setting (in milliseconds) before you deploy or redeploy the sample.

***

#### Evaluating Scripts

You can try out your script by validating it, as described in the [IDM Docs](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-endpoint). In order to be able to access the `/script` endpoint you will need to authorize your client for making request to the IDM `/script` endpoint. In ForgeOps, you would need to provide an access token from `amadmin` user. The token will need to be associated with the `openid` scope.

For this example, we will describe how you can create `scripts` OAuth 2.0 client in [ForgeRock Access Management](https://www.forgerock.com/platform/access-management) (AM), which can be performed with the following cURL command:

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

To evaluate the Groovy script you will need to change the "type" and teh "file" values in the cURL request data:

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

#### Debugging

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
        {" . . . "},
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
        {" . . . "}
    ]
}
```

In IDM, multiline scripts can be presented in the configuration files' JSON by concatenating the lines with the new line symbol, `\n`. To produce a visible effect for this script in the deployment logs, you can add `\nprint result` before the return statement, as shown in the example above.

When you change `router.json`, don't forget to build and deploy your sample, if this is not done automatically.

#### Inline Scripts in IDM Admin

Some configuration options can be associated with scripts in the IDM Admin UI.

To experience it first hand, you could, for example, sign in at `https://default.iam.example.com/admin`, navigate to CONFIGURE > MANAGED OBJECTS > USER, and select the Scripts tab. Here, you'll be provided with an a choice of modifying one of the existing scripts or creating a new one:

<img src="README_files/idm.admin.managed-object.user.script-manager.scripts.png" alt="IDM Admin, Configure Manged Object, User, Scripts" width="700">

Select Edit or Add Script button for an event associated with User object and populate the provided in Script Manager window input area with the content from a script file you've created earlier. Don't forget the parameters the script is expecting to receive. And make sure you selected the correct script engine from the Type dropdown. For example:

<img src="README_files/idm.admin.managed-object.user.script-manager.script.groovy.png" alt="IDM Admin, Configure Manged Object, User, Script, Groovy" width="700">

Select Save.

Now, if you trigger the event you associated your script with, for example update a user attribute (triggering `onUpdate`) or open a user record in the admin (triggering `onRead`), you may observe in the IDM pod logs the printed results of the network call (if it succeeded).

## <a id="example-ig"></a>IG

[Back to the Top](#top)

Please see [IG Docs](https://backstage.forgerock.com/docs/ig) for comprehensive coverage of the component.

### Scripts in IG

Scripts in IG may be associated with one of the [scriptable object types](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#script-conf).

Similar to IDM, IG allows to specify script content either inline in a configuration file or in a designated script file. In either case, only the `application/x-groovy` MIME type is supported. Similar to IDM, IG scripts accept parameters provided as the `args` key in the script configuration. For example, the following [ScriptableFilter](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableFilter) definition may be a part of a [Chain Handler](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Chain) and use `example.groovy` script to process the request:

```json
{
    . . .
     "handler": {
        "type": "Chain",
        "config": {
            "filters": [
                . . .
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
                . . .
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

## <a id="summary"></a>Summary

[Back to the Top](#top)

### Similarities


* All three components support scripting in Groovy.

* AM and IDM use [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino)—the scripting engine that has access to the Java environment provided by the corresponding component—for supporting server-side JavaScript.

### Differences

* Languages

    All three components support scripting in Groovy.

    AM allows for client-side scripts, which run in the browser environment. The server-side scripts, running on Rhino, can have access to data obtained with a client-side script.

    IDM only supports JavaScript on the server side, with Rhino.

    IG does not currently support JavaScript.

* Management

    In IDM, the scripts can be managed directly in separate files and referenced from the configuration. The configuration can be itself managed directly in the file system.

* Accessing HTTP Services

    * AM

        From authentication modules, AM makes _synchronous_ network requests with the HTTP client object that are blocking until the script returns or times out according to the Server-side Script Timeout setting, which could be in the AM console under Configure > Global Services > Scripting > Secondary Configurations > AUTHENTICATION_SERVER_SIDE > Secondary Configurations > EngineConfiguration, as described in [Scripted Authentication Module Properties](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#authn-scripted).


## Summary for Server-Side Scripts

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

#### Configuration File Syntax

1. IDM

    ```json
    {
        "type" : "javascript|groovy",
        "source|file" : "code|URI",
        "globals" : {}
    }
    ```

1. IG

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

## <a id="conclusion"></a>Conclusion

[Back to the Top](#top)

The scripting objectives and implementation are driven by the component's functionality and the environment it provides. Hence, the scripts' location, configuration, security, the data and methods a script can use, and the way the scripts are managed are specific to a component.

There are certain similarities too: the choice of scripting languages, ability to access the underlying Java functionality and the component's context data, logging methods, access to the request object, and ability to make back-channel network requests. In some deployments, the scripts configuration can be exported and tracked in the file system.

Scripts add flexibility to the ForgeRock Identity Platform. While a script may not be performing as well as a native/standard implementation, the scripts can be used to substitute functionality not yet present in the current version of the softwares.

## <a id="references"></a>References

[Back to the Top](#top)

### AM

* Introduction

    * ["Developing with Scripts"](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts). Development Guide.

        The contexts to which scripts can be applied, the ways of managing and configuring scripts in AM, and the APIs, objects, and data available for scripts at runtime.

    * ["Scripting Reference"](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#global-scripting). Development Guide.

        The scripting engine configuration.

* Languages


* Management

    * [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts). Development Guide.
        * Administrative Console (UI)
        * REST API
        * `ssoadm` Command (command line)

* Security

    * Java Class Whitelist
    * Java Class Blacklist

* Environment

    * [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn). Development Guide.

        The functionality available for scripted authentication modules.

    * [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node). Development Guide.

    * [The Node Class](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-class). Authentication Node Development Guide.

    * [AM 6.5.2.3 Public API Javadoc](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html). OpenAM Server Only 6.5.2.3 Documentation.

        Java Interfaces

* Debugging

* Application

    * Authentication

        * Chains

            * Client-side Script
            * Server-side Script

        * Trees

            * [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node). Development Guide.

                Client-side and Server-side scripting in Authentication Trees.

    * Authorization
        * Access Token Modification
        * OIDC Claims
        * Scripted Policy Condition

* Examples

    * ["Device ID (Match) Authentication Module"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints), ["Device ID (Save) Module"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-save-hints). Authentication and Single Sign-On Guide.

        The default AM configuration includes a functional set of client-side and server-side scripts, the Device Id (Match) scripts, to work together as a part of an authentication module, which is the elementary unit of an authentication chain.

    * ["Using Server-side Authentication Scripts in Authentication Modules"](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module). Authentication and Single Sign-On Guide.

        Describes in details how to set up and try a scripted authentication module and an authentication chain using this module.

        Instructions for setting up the Device Id (Match) module, the rest of the [Configuring Authentication Chains and Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#configure-authn-chains-modules) chapter, and this example can serve as a reference for setting up a custom authentication chain.



The script will load an external library and make an HTTP request in order to get the client's IP information.

### IDM

* Introduction

    * ["Extending IDM Functionality By Using Scripts"](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting). Integrator's Guide.

    * ["Setting the Script Configuration"](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-config). Integrator's Guide.

    * ["Calling a Script From a Configuration File"](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call). Integrator's Guide.

        Describes how a script could be used in different IDM contexts.

    * ["Scripting Reference"](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-scripting). Integrator's Guide.

    * [FAQ: Scripts in IDM/OpenIDM](https://backstage.forgerock.com/knowledge/kb/article/a29088283). Knowledge Base.

* Languages

* Management

    * Administrative UI
    * REST
    * File System

* Security

    * No scripting-specific security

* Environment

* Debugging

* Application/Extension Points

    * Mapping (sync.json)
    * Event hooks (managed.json)

        Managed Object Event Handlers

    * Custom Endpoints/Actions
    * Authentication / Authorization / Policy

    * OpenICF scripted
    * Workflow
    * Script evaluation
    * Custom OSGi bundles

* Examples

    * [How do I write to a file using JavaScript on a custom endpoint in IDM/OpenIDM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a88622670). Knowledge Base.

### IG

* Introduction

    * ["Extending IG"](https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/index.html#chap-extending). Gateway Guide.

    * ["Scripts"](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts). Configuration Reference.

        Usage, configuration, syntax, and environment.

* Languages

* Management

* Security

* Environment

    * ["Scripts"](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts). Configuration Reference.

    * [Identity Gateway 6.5.2 API](https://backstage.forgerock.com/docs/ig/6.5/apidocs/)

        Java interfaces.

* Debugging

* Application

    * [ScriptableFilter](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableFilter). Configuration Reference.

        Customize flow of requests and responses.

    * [ScriptableHandler](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableHandler). Configuration Reference.

        Customize creation of responses.

    * [ScriptableThrottlingPolicy](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableThrottlingPolicy). Configuration Reference.

        Customize throttling rates.

    * [ScriptableAccessTokenResolver](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableAccessTokenResolver). Configuration Reference.

         Customize resolution and validation of OAuth 2.0 access tokens.

    * `ScriptableResourceAccess` in [OAuth2ResourceServerFilter](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#OAuth2ResourceServerFilter). Configuration Reference.

        Customize the list of OAuth 2.0 scopes required in an OAuth 2.0 access_token.

