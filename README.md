
# <a id="top"></a>Different Scripting Environments in ForgeRock Products

Three of ForgeRock Identity Platform products, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript or Groovy and evaluated during the run time.

Scripting is broadly used in the products and broadly covered across [ForgeRock Product Documentation](https://backstage.forgerock.com/docs/). There are many articles describing scripting environment and application, often in a context of particular task and supplied with examples.

This writing aims at a comparison of scripting environments in the three products in the context of a particular task—making an outbound HTT request.

The [References](#references) section contains a comprehensive list of relevant links to the official docs; some are also will also be provided inline.

## <a id="contents"></a>Contents
* [Overview](#overview)
    * [AM](#overview-am)
        * [Server-side](#overview-am-server-side)
        * [Client-side](#overview-am-client-side)
    * [IDM](#overview-idm)
        * [Core IDM](#overview-idm-osgi)
        * [ICF Connectors](#overview-idm-icf)
        * [Workflows](#overview-idm-workflow)
    * [IG](#overview-ig)
* [Comparison](#comparison)
* [Summary](#summary)
* [Conclusion](#conclusion)
* [Examples](README.Examples.md)

## <a id="overview"></a>Overview

[Back to Contents](#contents)

Below you will find non-exhaustive description of the existing environment by product.

## <a id="overview-am"></a>AM

[Back to Contents](#contents)

#### Points of Consideration:

* Scripting application in AM could be summarized into the following categories:
    * Authentication, Client-side and Server-side
        * Modules and Chains
        * Nodes and Trees
    * Authorization, Server-side only
        * Scripting Policy Condition
        * Access Token Modification
    * Federation, Server-side only
        * OIDC Claims Handling
* Server-side scripting environment is different for each category in terms of automatically provided functionality.

    However:
    * All of the categories share access to some common, globally provided objects and methods.
    * All server-side scripts have access to the same underlying Java API.
* Client-side scripting environment is defined by the user browser and is not specific to ForgeRock.
* Scripts management requires administrative rights. Scripts can be uploaded but are stored as AM configuration data, not as files.

    The [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts) chapter shows how the scripts can be managed via REST and command line interfaces. These two approaches may represent the most efficient way to manage scripts in automated environments; for example, in production deployments. At the same time, AM console UI provides an easy to use visual interface for creating and updating scripts.

    Managing scripts requires an administrative account; for example, the built in `amadmin` login. The admin user credentials can be used directly in AM console and with the `ssoadmin` command. To manage scripts via the REST, you'd need to provide an authentication header, `iPlanetDirectoryPro` is expected by default, populated with the SSO token of an administrative user.

    Behavior of a particular script type can be be adjusted in AM console at Configure > Global Services > Scripting > Secondary Configurations > _Server-Side Script Type_.

    Scripts included in the default AM configuration can serve as a great source of example scripting for the script types supported in AM.

    > The Decision node script for authentication trees example script is very basic; for this one, see the [example](#examples-ams-tree) provided in this writing. The default scripts can be found in the AM console under Realms > _Realm Name_ > Scripts.

### <a id="overview-am-server-side"></a>AM > Server-side

[Back to Contents](#contents)

#### Points of Consideration:

* Server-side scripts in AM can be written in [Groovy](https://www.groovy-lang.org/documentation.html) or JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). The 6.5 version of AM uses Groovy version 2.5.7 and Rhino version 1.7R4.
* The server-side scripts have global access to [AM 6.5.2.3 Public API](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html).

    Server-side _JavaScript_ requires the full path to a Java class or a  static method. An instance or a static method can be assigned to a JavaScript variable.

* [Scripting Security](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#script-engine-security) checks directly-called Java classes against a configurable blacklist and whitelist, and, optionally, against the JVM SecurityManager.

    For example, if your script is written in Groovy, and you need to parse stringified JSON with `groovy.json.JsonSlurper`, the `groovy.json.internal.LazyMap` class would have to be allowed in the scripting engine setting. For getting AM identity with the `IdUtils` method, `com.sun.identity.idm.AMIdentity` would have to be explicitly whitelisted.

* [Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-http-client) is provided by [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global).

    The HTTP client requests are synchronous, blocking until they return. The global setting for request timeout can be found under Realms > Realm Name > Authentication > Modules.

* [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger) methods are provided by [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global).

    Server-side scripts in AM cannot be attached to a debugger.

    By default, debug logs are saved in (separate) files.

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


* Besides the globally accessible APIs, [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn), [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node) and [The Action Interface](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-action), [Authorization API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-policy), and [OpenID Connect 1.0 Claims API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-oidc) are available for scripts when they extend _specific_ parts of authentication and authorization procedures.

### <a id="overview-am-client-side"></a>AM > Client-side

[Back to Contents](#contents)

#### Points of Consideration:

* Client-side scripts need to be written in [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript) and be compatible with the users' _browser_.

    In AM, authentication in the front channel can be assisted with custom client-side scripts written in JavaScript and executed in the user's browser. The collected data can be posted to the server and become available for the server-side components involved in the same authentication procedure.

    > An important use case for a client-side script could be collecting user input and/or information about the user agent: [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/geolocation), IP, the navigator properties, and so on.

## <a id="overview-idm"></a>IDM

[Back to Contents](#contents)

#### Points of Consideration:

* IDM presents three distinct environments for scripting:
    * [Core IDM functionality defined in the OSGi framework](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-overview).
    * [ForgeRock Open Connector Framework and ICF Connectors](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#chap-about).
    * [Embedded workflow and business process engine based on Activiti and the Business Process Model and Notation (BPMN) 2.0 standard](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-workflow).

### <a id="overview-idm-osgi"></a>IDM > Core IDM

[Back to Contents](#contents)

#### Points of Consideration:

* Languages:
    * The Script Engine supports [Groovy](https://www.groovy-lang.org/documentation.html) and JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). The 6.5 version of IDM uses Groovy version 2.5.7 and Rhino version 1.7.12 (the latest release of Rhino at the time of writing).
* Scopes:
    * [Router Service](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#appendix-router) provides the uniform interface to all IDM objects and global [Script Scope](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#filter-script-scope) in the _core_ IDM.
    * Scripting application could be summarized into the following environments, which add additional specific scopes, described in [Scripting Reference](https://backstage.forgerock.com/docs/idm/6/integrators-guide/#appendix-scripting):
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
    * An individual script configuration can specify a script "source" as a single line or a script "file" reference. The configuration itself can be managed directly in the file system.
    * Scripts defined in separate files need to be placed in certain locations specified in [Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config).
    * Inline scripts can be created and updated in the admin UI or directly in configuration files.
    * Existing scripts, including the default ones under "&{idm.install.dir}/bin/defaults/script", can be overridden by placing custom versions later in the script sources, as described in [Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config).
* Debugging
    * Debug logging is provided with the `logger` object methods.
    * _JavaScript_ scripts can use `console.log()`.
    * Scripts can be evaluated via REST, which can be used to test them if all the necessary bindings can be provided.
    * Scripts defined in separate files can be attached to a debugger.

### <a id="overview-idm-osgi-http"></a>IDM > Core IDM > HTTP Request

In order to make an HTTP request, the script used `action` method of the `openidm` Java object. You can find more about scripts environment and available for scripts functionality in the IDM docs, in its [Scripting Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-scripting). In particular, the `action` method is described in the [openidm.action(resource, actionName, content, params, fields)](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#function-action) section.

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

The updated scripts will be copied promptly, but the time it takes for ForgeRock component to pick up the change will be affected by the configuration settings in the `script.json` file:

```json
    "ECMAScript" : {

        "javascript.recompile.minimumInterval" : 60000
    },
    "Groovy" : {

        "groovy.recompile.minimumInterval" : 60000

    }
```

***

### <a id="overview-idm-osgi-evaluating"></a>IDM > Core IDM > Evaluating Scripts

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

#### <a id="overview-idm-osgi-debugging"></a>IDM > Core IDM > Debugging

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

### <a id="overview-idm-osgi-inline"></a>IDM > Core IDM > Inline Scripts in Configuration Files

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

### <a id="overview-idm-icf"></a>IDM > ICF Connectors

[Back to Contents](#contents)

#### Points of Consideration:

* Languages:
    * You can write [Scripted Connectors With the Groovy Connector Toolkit](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#chap-groovy-connectors), which "enables you to run Groovy scripts to interact with any external resource".
    * JavaScript is NOT supported.
* Scopes:
    * The environment is separate from one described for the OSGi framework.
    * [Implementing ICF Operations With Groovy Scripts](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#implementing-operations-groovy) describes scopes available for all and particular types of scripted ICF operations.

### <a id="overview-idm-workflow"></a>IDM > Workflow

* Languages:
    * Groovy, as described in [Defining Activiti Workflows](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#defining-activiti-workflows).
    * JavaScript is NOT supported.
* Management:
    * Access to workflows is based on IDM roles, and is configured in your project's conf/process-access.json file—as described in [Managing User Access to Workflows](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#ui-managing-workflows).

## <a id="overview-ig"></a>IG

[Back to Contents](#contents)

NOTES:

* The `attributes` scope can be used for data exchange between scriptable objects (that are part of the same chain).

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

## <a id="comparison"></a>Comparison

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

    Any bindings specified by a scripted connector author can also be made available to the script.

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

    IG does not currently support JavaScript in any form.

    It is tempting to say that for server-side scripts, Groovy is a preferable choice as it better integrates with the underlying Java environment. However, when supported, JavaScript can reproduce the same functionality and may be simpler to deal with for those who are familiar with the language and its ecosystem, especially in IDM, which allows to [load CommonJS modules](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a44445500).

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

## <a id="conclusion"></a>Conclusion

[Back to Contents](#contents)

The scripting objectives and implementation are driven by the product's functionality and the environment it provides. Hence, the scripts' location, configuration, security, the data and methods a script can use, and the way the scripts are managed are specific to a product.

There are certain similarities as well: the choice of scripting languages, ability to access the underlying Java functionality and the context data, logging methods, access to the request object, and ability to make back-channel HTTP requests—all converge into a similar experience at certain level.

Scripts add flexibility to the ForgeRock Identity Platform. Custom scripts can be used to substitute functionality that is not yet present in the software or is specific to a certain deployment.
