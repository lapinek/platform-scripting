
# <a id="top"></a>Scripting in ForgeRock Platform Components

ForgeRock Identity Platform components, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript and Groovy.

## Contents

* [Where to Start](#chapter-010)
* [A Look Into the Platform Scripting](#chapter-020)
* [An Example of Scripting in ForgeRock Components](#chapter-050)
    * [AM](#top)
    * [IDM](#top)
    * [IG](#top)
* [Similarities and Differences](#top)
    * [Supported Languages](#top)
    * [Script Locations](#top)
    * [Script Management](#top)
    * [Syntax](#top)
    * [Script Environment](#top)
    * [Debugging Options](#top)
* [Summary Table](#top)
* [Conclusion](#top)

## <a id="chapter-010"></a>Where to Start

[Back to the Top](#top)

Introduction to scripting in ForgeRock components and additional references to follow can be found in the components' documentation:

* For AM, you can read about scripting in [Developing with Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts) section of its Development Guide.

    The doc provides information about the contexts to which scripts can be applied, the ways of managing and configuring scripts in AM, and the APIs, objects, and data available for scripts during runtime.

    The scripting engine configuration is described in the [Scripting Reference](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#global-scripting) part of the doc.

    In addition, [Device ID (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints), [Device ID (Save) Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-save-hints), and [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) chapters of the Authentication and Single Sign-On Guide demonstrate how scripts included in AM could be used for extending authentication chains.

* To learn about scripting in IDM, you can start with the [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting) chapter of IDM's Integrator's Guide.

    From there, [Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-config) chapter is referenced, which is followed by [Calling a Script From a Configuration File](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call), which describes how a script could be used in different IDM contexts.

    The scripting environment is further explained in the [Scripting Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-scripting) chapter of the Guide.

    Information about scripting in IDM is also present in ForgeRock [Knowledge Base](https://backstage.forgerock.com/knowledge/kb/home). In particular, [FAQ: Scripts in IDM/OpenIDM](https://backstage.forgerock.com/knowledge/kb/article/a29088283) could serve as a good initial reference.

    > The knowledge base site content is being constantly updated and allows to search for articles addressing a particular problem. For example, [How do I write to a file using JavaScript on a custom endpoint in IDM/OpenIDM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a88622670).

* Extending IG with scripts starts in the [About Scripting](https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/index.html#about-scripting) section of its Gateway Guide.

    Further information about scripts' usage, configuration, syntax, and environment can be found in IG Configuration Reference for [Scripts](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts).

* Examples

    Across documentation, there are meaningful, component and content specific examples of how the scripts could be employed. Some of them will be referenced later in this document.

## <a id="chapter-020"></a>A Look Into the Platform Scripting

[Back to the Top](#top)

For a quick overview of scripting in AM, IDM, and IG, we will make our own example, a simple, generic script associated with an event in the corresponding component. This will allow us to depict some similarities and some differences in how scripting can be approached in different ForgeRock components, and hopefully create a useful illustration for further explorations.

But first, we will need an environment for deploying all three components, an environment to run this script in.

> If you already have ForgeRock platform components running, you may want to skip the next section and make necessary adjustments to any instructions provided there.

## <a id="chapter-050"></a>An Example of Scripting in ForgeRock Components

[Back to the Top](#top)

To compare environments provided by ForgeRock components, we will create a script that will make an HTTP call to an online service and receive a response in the form of JSON. For this purpose, as an example, we will visit a dummy API employee record at `http://jsonplaceholder.typicode.com/users/1`. This endpoint returns JSON, which the script _could_ evaluate against other data provided by the script's environment.

> If you use server-side scripts to access an API over encrypted connection, make sure Java, the script engine is running on, trusts the underlying SSL/TLS certificate.

## <a id="chapter-060"></a>[AM](https://www.forgerock.com/platform/identity-management)

[Back to the Top](#top)

AM documentation can be found at [https://backstage.forgerock.com/docs/am](https://backstage.forgerock.com/docs/am).

AM provides authentication and authorization services, and custom scripts can be used to augment the default functionality.

### Managing Scripts in AM

The [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#manage-scripts) chapter in AM's docs shows how the scripts can be managed via REST and command line interfaces. This may be the most efficient way to manage scripts in automatically maintained environments; for example, in production deployments.

At the same time, AM console provides a visual and easy to use interface for managing scripts and applying them to authentication and authorization events. We will use the console to apply a script to an authentication procedure in AM.

### Client-Side Scripts

When used for authentication in the front channel, AM allows for creating client-side scripts that would be executed in the user agent.

The use case for a client-side script is collecting information about the user agent's properties and its environment: [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/geolocation), IP, and whatever else that could be collected with a custom script running in a browser. Thus, the script needs to be written in JavaScript compatible with the browser.

From the client side, the data collected with the script can be submitted to the server and become available to the server-side scripts involved in the same authentication procedure.

### Server-Side Scripts

The decision making process on user identification and access management can be aided with the server-side scripts. The server-side scripts can be written in Groovy or JavaScript; with the latter running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino).

The server-side scripts can accept data from the client side via a well-known variable.

### Authentication Trees and Authentication Chains

AM supports two basic authentication workflows: `trees` and `chains`.

The latter approach allows for use of a client-side script defined directly in AM console. Thus, to observe a scripted authentication with a client-side script you could use an authentication chain.

### Scripting Authentication Chain

The default AM configuration includes a functional set of client-side and server-side scripts, the Device Id (Match) scripts, to work together as a part of an authentication module, which is the elementary unit of an authentication chain. Setting up a Device Id (Match) module is described in details in the docs under AM 6.5 › Authentication and Single Sign-On Guide > [Device Id (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints), along with the related [Device Id (Save)](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-save-hints) one.

Instructions for setting up the Device Id (Match) module, the rest of the [Configuring Authentication Chains and Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#configure-authn-chains-modules) chapter, and the [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) one in the  Authentication and Single Sign-On Guide can serve as a reference for setting up a custom authentication chain.

### A Simple Example

To outline basic principles of scripting authentication chains in AM, we offer an example of extending the authentication flow with a simple client-side script. The script will load an external library and make an HTTP request in order to get the client's IP information.

1. The Client-side Script

    1. Navigate to Realms > _Realm Name_ > Scripts.

        You will see number of predefined scripts, some of which can serve as templates for the new ones. In particular, Scripted Module - Server Side example script will be the starting point for any added script of the Server-side Authentication type.

    1. Select + New Script.

        In the New Script dialog, provide name for your script in the Name input and select Client-side Authentication for the Script Type input. For example:

        * Name:  Scripted Module - Client Side - Example
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
                clientScriptOutputData.ip = json;
                    output.value = JSON.stringify(data); // 3

                    submit();
                });
            }

            document.getElementsByTagName('head')[0].appendChild(script); // 1

            autoSubmitDelay = 4000; // 4
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

                The script uses stringified form of this data to populate the `output` input in the form on the page where the client-side script is running. When the form is submitted, the value of the input will become available for the server-side scripts as the `clientScriptOutputData` variable.

            4. To allow for the HTTP call to complete, which is asynchronous operation, automatic submission of the form is delayed via a conventional setting that takes milliseconds.

            Select the Save Changes button.

    1. You can return to the script and change its definition by navigating to Realms > _Realm Name_ > Scripts >  Scripted Module - Client Side - Example

1. The Server-side Script

    The `Scripted Module - Client Side` script, included in AM configuration by default, serves as a starting template for all new scripts of type "Server-side Authentication". In our example, we will replace its content with functionality that relies on the results delivered by our client-side script.

    1. Navigate back to Realms > _Realm Name_ > Scripts.

    1. Select + New Script.

        In the New Script dialog, provide a Name. This time, select Server-side Authentication for the Script Type input.

        For example:

        * Name:  Scripted Module - Server Side - Example
        * Script Type: Server-side Authentication

        Select the Create button.

    2. In the following dialog, populate the Language and the Script inputs:

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

                In this example, finding the current zip code in the user's address means success, but it could also be determined by checking the client's IP against a white list.

            5. Depending on results that the script produces, the authentication state is set to define outcome of the module.

            As described in [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn), the functional part of the script have access to number of APIs and data objects.

            In addition, the [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global) allows for making HTTP requests to external resources, which is illustrated in the `Scripted Module - Server Side` and `Scripted Policy Condition` server-side scripts included in the default AM installation.

1. Using the Scripts

    The [Device Id (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints) and [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) chapters of the Authentication and Single Sign-On Guide provide comprehensive coverage for how the scripts can be employed in an authentication chain.

1. Data preparations

    To make a positive comparison with data delivered from the client script, you will need to add corresponding values to the identity with which you try to sign in AM. Out of the box, there should be `postalAddress` attribute associated with an identity, which can be updated in version 6.5 of AM administrative console via Realms > _Realm Name_ > Identities > _Identity_.

    > Managing custom identity attributes in AM is covered in [Setting Up Identity Stores](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#chap-maint-datastores).

1. Debugging

    None of the interfaces for [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#manage-scripts) in AM allow for traditional debugging. However, Global Scripting API Functionality facilitates [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger).

    You can set up [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#sec-maint-debug-logging) as it is described in the Setup and Maintenance Guide.

    For example, for the scripts defined in AM console that are a part of an authentication chain, like the one above, you could go to the `your-am-instance/Debug.jsp` page, select "amScript" for "Debug instances" and "Message" for "Level". Then, wherever in your script you use `logger.message` method, the output will be saved in the logs, along with warnings and errors.

    Then, to access the logs, you can navigate to `your-am-instance/debug` in the Terminal and `tail -f` the log file of interest; in this case `Authentication` one.

    Alternatively, during development, you could use the `logger.error` method without changing the debugging configuration, for the "Error" level is the necessary one for all components in AM.

## [IDM](https://www.forgerock.com/platform/identity-management)

Please see [IDM Docs](https://backstage.forgerock.com/docs/idm) for version-specific, comprehensive, and easy to read technical information about the component.

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

An equivalent script in `Groovy`, in `example.groovy` file, might look like the following:

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

As you change scripts in a watched location in the staging area, it will be automatically copied to the container, which is going to be reflected in the terminal output if you deployed your sample with the verbosity level of `info` or `debug`.

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

You can evaluate the Groovy script with the following cURL command:

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

    > You can find more details on

    The resulting line in your Dockerfile might look like this:

    ```docker
    ENV JAVA_OPTS "-Djava.compiler=NONE -Xnoagent -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n -server -XX:MaxRAMPercentage=75"
    ```

    Make sure that the port you use in IntelliJ and in the Dockerfile are the same.

1. Run the following command in your terminal against your ForgeOPS deployment:

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

        . . .

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

        . . .
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

## [IG](https://www.forgerock.com/platform/identity-gateway)

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
    . . .
]
```

## Similarities

Scripts extend existing functionality and their application is specific to a component. The component also defines the script what type of data and functionality is available for scripts. The the scripts' environment, configuration, and sometimes even syntax may be specific to a component.

Nevertheless, scripts work at a low level, and there are similarities:

* All three components support scripting in Groovy.

* AM and IDM use [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino)—the scripting engine having access to Java functionality provided by the corresponding component—to support server-side JavaScript.

Now, to differences.

## Differences

* Languages

    AM allows for client-side scripts, which run in the browser environment. The server-side scripts, running on Rhino, can have access to data obtained with a client-side script.

    IDM only supports JavaScript on the server side, with Rhino.

    IG does currently not support JavaScript.

*


## Summary for Server-Side Scripts

| Script Feature | IDM | IG | AM |
|-|-|-|-|
| References | https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting | https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/#chap-extending | https://backstage.forgerock.com/docs/am/6/dev-guide/#chap-dev-scripts<br>https://backstage.forgerock.com/docs/am/6/dev-guide/#global-scripting<br>https://backstage.forgerock.com/docs/am/6/maintenance-guide/index.html#sec-maint-debug-logging<br>https://backstage.forgerock.com/docs/am/6.5/authentication-guide/#configuring-the-default-auth-chain<br>https://backstage.forgerock.com/docs/am/6/authentication-guide/index.html#sec-scripted-auth-module<br>https://backstage.forgerock.com/docs/am/6/authentication-guide/index.html#scripting-api-authn-client-data<br>https://forum.forgerock.com/topic/realm-authentication-chain/ |
| Commons | Defined with JSON<br>Administrator account is required for managing scripts|
| Type | `text/javascript`, `groovy` | `application/x-groovy` | JAVASCRIPT or GROOVY—depending on script `context` type (labeled `Script Type` in AM Console) |
| Configuration | Part of a configuration file (JSON) | Part of a configuration file (JSON) | |
| Managing | File, JSON configuration, Script Manager | File, JSON configuration, Studio (may not be available in ForgeOps) | AM Console, REST, `ssoadm` command, allows for setting defaults |
| Validation | REST | | AM Console, REST |
| Multiline Source | `\n` | Array (of strings) | |
| Arguments | The `globals` namespace | `args` key | |
| Access to | `openidm` functions, request, context, managed object, resource information, operation results | request, context, etc., [Properties, Available Objects, and Imported Classes](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#script-conf)| |
| Other Context Differences | | |
| Extras | | Capture Decorator | |
| Security | | | Security Settings Component: Java Class White/Black Lists, System (JVM) SecurityManager|
| Debugging | | | [Debug Logging](https://backstage.forgerock.com/docs/am/6/dev-guide/#scripting-api-global-logger) |
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

***
***
***


## Plan

Need to define the series, so that the scope of the first article is outlined.

Chapters:

1. What scripts can be used for?
2. Where are they located?
3. What data do they have access to? (For example echo.js)
4. Debugging and logging.

1. AM

    1. JVM
    1. No file reference option

1. IG

    1. Multiline script as an array
    1. Access to JVM and API

1. IDM

    1. API: create, read, etc., request/response object


1. Suggested Example

    1. Make HTTP request to a service
    1. Location, Syntax, and Examples
    1. Summary Table
    1. Differences in Context, Use of the Scripts

1. Questions

    1. Use case for each component? Or abstract from use cases and focus on the script environment?
    1. Full implementation details (that is, step-by-step functional example) or just key concepts? (No)
    1. How not to repeat existing docs and reference them efficiently?
    1. Should we cover IG Studio?
    1. Scripts' security.
    1. AM

        1. Client-side (async) and server-side data exchange.

1. Follow Ups

    1. Debug logger in IDM
    1. Debug logger in IG

***

References:

1. Conventions:
    1. https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/#formatting-conventions

1. Debugging

    1. `forgeops/cicd/forgeops-ui/README.MD`

1. IG

    1. Chain Scriptable Filter

        1. https://backstage.forgerock.com/knowledge/kb/article/a77687377

Notes

1. Eval and Compile

    1. Credentials

        1. Bearer
        2. X-OpenIDM- . . . headers mentioned in docs do not seem to work in 7

1. Custom Endpoints

    1. “source" does not seem to work > `Expected ',' instead of ‘’`
    2. Use “file”

1. Actions

    1. `"http://localhost:8080/openidm/managed/user/:ID?_actionId=toggleUpdate”` does not seem to work.
    2. Needs to be `/user/12a59751-17c3-49ad-9521-610c02299d41?_action=togglePreferences` like.

1. Postman

    1.

1. Scripts (Behavior)

    1. Groovy considers the last evaluated expression of a method to be the returned value.
    1. JS as well?

