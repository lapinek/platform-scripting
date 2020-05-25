
# <a id="top"></a>Different Scripting Environments in ForgeRock Products

Three of ForgeRock Identity Platform products—[Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG)—allow to extend their functionality with scripts written in JavaScript or Groovy and evaluated during the run time.

The products, and sometimes frameworks within a product, define different environments for managing and executing scripts. As you move between these environments, it could be helpful to be aware of how your approach may change in performing a certain task. For this purpose, we will consider a common task of making an outbound HTTP request from a server-side script.

> Scripting is broadly used in the products and broadly covered across [ForgeRock Product Documentation](https://backstage.forgerock.com/docs/). There are many articles describing number of scripting applications, often in a context of a particular task and supplied with examples.
>
> The [References](#references) section contains a collection of links to scripting docs; some of the relevant references will be also provided inline.
> If you are unsure what scripting in ForgeRock products represents, see [Overview of Scripting Functionality](#overview).

## <a id="contents"></a>Contents
* [Making HTTP Request](#making-http-request)
    * [AM](#making-http-request-am)
    * [IDM](#making-http-request-idm)
    * [IG](#making-http-request-ig)
* [Summary](#summary)
* [Conclusion](#conclusion)
* [Examples](README.Examples.md)
* [References](README.References.md)

## <a id="making-http-request"></a>Making HTTP Request

[Back to Contents](#contents)

The context of a server-side script is largely defined by the functionality the script extends, and making an outbound HTTP requests will denote some specifics for that particular use case. Being a part of global APIs, HTTP services can be used to demonstrate differences in scripting environments that all scripts in a given environment share.

## <a id="making-http-request-am"></a>Making HTTP Request > AM

[Back to Contents](#contents)

Scripts in AM are stored as a part of configuration data, not as separate files. They can be edited in the administrative UI under Realms > _Realm Name_ > Scripts, but cannot be updated real time in the file system.

> In addition to the UI option, the [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts) chapter of the Development Guide describes two other ways to manage scripts in AM: via REST and command line interfaces, which could be effective in automated environments.

> One of the script types you can choose is `Client-side Authentication`. This type of script is executed in the user agent, a browser of sorts, and its runtime environment is not ForgeRock specific. A script of this type can only be used in [Authentication Chains and Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#configure-authn-chains-modules), while [Authentication Trees](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-configure-authentication-trees) present more recent alternative for implementing an authentication flow. In the latter case, front-channel authentication can still be assisted with a client-side script, but the script is defined in an authentication node and implementation details are different. In either case, the script itself is written in client-side [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript), which you probably know and love, and we will leave the implementation details specific to front-channel authentication out of this writing.

In any server-side script, you can use the `httpClient` object provided by [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global) for making an outbound HTTP request. To prepare the request (object), you can use the `org.forgerock.http.protocol` package, which is a part of [AM Public API](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html), the version 6.5.2.3 at the time of writing.

Server-side scripts in AM can be written in [Groovy](https://www.groovy-lang.org/documentation.html) or JavaScript running on [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). The 6.5 version of AM uses Groovy version 2.5.7 and Rhino version 1.7R4.

A JavaScript example of an HTTP request making script might look like this:

```javascript
var request = new org.forgerock.http.protocol.Request();
request.setUri("https://jsonplaceholder.typicode.com/users");
request.setMethod("GET");

var response = httpClient.send(request).get();
var users = JSON.parse(response.getEntity());
```

Things to notice:
* Server-side _JavaScript_ requires the full path to a Java class (or a  static method). An instance (or a static method) can be assigned to a JavaScript variable.
* The HTTP client requests are synchronous (and blocking until they are completed). There is a global Server-side Script Timeout setting for HTTP requests, described in [Accessing HTTP Services](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-http-client) chapter of the Development Guide.

A Groovy equivalent might look like the following:

```groovy
import org.forgerock.http.protocol.Request;
import groovy.json.JsonSlurper;

def request = new Request();
request.setUri("https://jsonplaceholder.typicode.com/users");
request.setMethod("GET");

def response = httpClient.send(request).get();
def result = new JsonSlurper().parseText(response.getEntity().toString());
```

Things to notice:
* To parse the response data, the `groovy.json.JsonSlurper` class is imported.

This brings us to AM's [Scripting Security](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#script-engine-security), which checks directly-called Java classes against a configurable blacklist and whitelist (and optionally, against the JVM SecurityManager).

For example, if you get the "Access to Java class . . . is prohibited." error trying to parse stringified JSON with `groovy.json.JsonSlurper`, you may need to explicitly allow the class (or `groovy.json.internal.LazyMap`) by adding it to the whitelist in your version of AM.

> `groovy.json.JsonSlurper` is whitelisted by default in AM version 7.0.

Depending on your AM version and configuration, you may see the debug output saved in the file system or standard output, as described in the [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global-logger) chapter of the Development Guide and linked from there [Setup and Maintenance](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#sec-maint-debug-logging) docs. There is no well-known way to attach a script to use in AM to a debugger.

The data persistence in AM depends on the script application. In authentication flows, the data received from an HTTP service can be parsed and used in the script or made available for other modules and nodes down the authentication flow. Please see [Examples](#examples) for an illustration and [References](#references) for further details.

## <a id="making-http-request-idm"></a>Making HTTP Request > IDM

[Back to Contents](#contents)

```groovy
// IDM

import org.forgerock.openidm.action.*

def result = openidm.action("external/rest", "call", {
    "url": "https://jsonplaceholder.typicode.com/users",
    "method": "GET"
});
```

```json
{
    "pattern" : "^(managed|system|internal)($|(/.+))",
    "onRequest" : {
        "type" : "javascript|groovy",
        "source|file" : "code|URI",
        "globals" : {}
    }
    },
    "methods" : [
        "patch"
    ]
},
```

## <a id="making-http-request-ig"></a>Making HTTP Request > IG

[Back to Contents](#contents)

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

Syntax for defining scripts in configuration files is different in IG comparing to IDM:

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

### <a id="summary-languages"></a>Languages

IG does not currently support JavaScript in any form.

It is tempting to say that for server-side scripts, Groovy is a preferable choice as it better integrates with the underlying Java environment. However, when supported, JavaScript can reproduce the same functionality and may be simpler to deal with for those who are familiar with the language and its ecosystem, especially in IDM, which allows to [load CommonJS modules](https://backstage.forgerock.com/knowledge/kb/book/b51015449#a44445500).

## <a id="conclusion"></a>Conclusion

[Back to Contents](#contents)

In this writing, we highlighted some important differences in scripting an outbound HTTP request. There are more details to consider when extending _other_ functionalities with scripts. Using HTTP services, however, is a common task accommodated by the global APIs available to scripts within a product, which hopefully makes it a representative example of what differences in scripting environment can be.