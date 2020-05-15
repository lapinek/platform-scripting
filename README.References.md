# <a id="references"></a>References

* [AM](#references-am)
* [IDM](#references-idm)
* [IG](#references-ig)
* [Commons](#references-commons)

### <a id="references-am"></a>AM

[Back to References](#references)

* Introduction

    * [Developing with Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts). Development Guide.

        The contexts to which scripts can be applied, the ways of managing and configuring scripts in AM, and the APIs, objects, and data available for scripts at runtime.

    * [Scripting Reference](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#global-scripting). Development Guide.

        The scripting engine configuration.

    * [Customizing Authentication](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#chap-authn-customization). Authentication and Single Sign-On Guide.

        Customizing authentication trees and chains.

* Application and Environment

    * [Global Scripting API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-global). Development Guide.

    * [AM 6.5.2.3 Public API Javadoc](https://backstage.forgerock.com/docs/am/6.5/apidocs/index.html). OpenAM Server Only 6.5.2.3 Documentation.

        Describes available Java interfaces.

    * Authentication

        * Chains

            * [Authentication API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-authn). Development Guide.

                The functionality available for scripted authentication modules.

            * [Scripted Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#scripted-module-conf-hints). Authentication and Single Sign-On Guide.

            * [Scripted Authentication Module Properties](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#authn-scripted). Authentication and Single Sign-On Guide.

            * [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module). Authentication and Single Sign-On Guide.

        * Trees

            * [Scripted Decision Node API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node). Development Guide.

                Client-side and Server-side scripting in Authentication Trees.

            * [Scripted Decision Node](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#auth-node-scripted-decision). Authentication and Single Sign-On Guide.

            * [Using Callbacks](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-node-callbacks). Development Guide.

            * [Supported Callbacks](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#supported-callbacks). Development Guide.

            * [The Node Class](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-class) and [The Action Interface](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#core-action). Authentication Node Development Guide.

            * [Storing Values in Shared Tree State](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#accessing-tree-state). Authentication Node Development Guide.

            * [Storing Secret Values in Transient Tree State](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#store-values-in-transient-state). Authentication Node Development Guide.

            * [Accessing an Identity's Profile](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#accessing-user-profile). Authentication Node Development Guide.

    * Authorization

        * [Authorization API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-policy). Development Guide.

        * [Scripting a Policy Condition](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/index.html#sec-scripted-policy-condition). Authorization Guide.

        * [Modifying Access Token Content Using Scripts](https://backstage.forgerock.com/docs/am/6.5/oauth2-guide/index.html#modifying-access-tokens-scripts). OAuth 2.0 Guide.

    * Federation

        * [OpenID Connect 1.0 Claims API Functionality](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#scripting-api-oidc). Development Guide.

* Management

    * [Managing Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#manage-scripts). Development Guide.
        * Administrative Console (UI)
        * REST API
        * `ssoadm` Command (command line)

* Languages

    * [JavaScript](https://developer.mozilla.org/en-US/docs/Web/JavaScript). MDN web docs.

    * [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). MDN web docs.

    * [Apache Groovy Documentation](https://www.groovy-lang.org/documentation.html). The Apache Groovy programming language.

* Security

    * [Security](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#script-engine-security)

* Debugging

    * [Debug Logging](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#sec-maint-debug-logging). Setup and Maintenance Guide.

* Examples

    * [Device ID (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints), [Device ID (Save) Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-save-hints). Authentication and Single Sign-On Guide.

        The default AM configuration includes a functional set of client-side and server-side scripts, the Device Id (Match) scripts, to work together as a part of an authentication module, which is the elementary unit of an authentication chain.

    * [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module). Authentication and Single Sign-On Guide.

        Describes in details how to set up and try a scripted authentication module and an authentication chain using this module.

        Instructions for setting up the Device Id (Match) module, the rest of the [Configuring Authentication Chains and Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#configure-authn-chains-modules) chapter, and this example can serve as a reference for setting up a custom authentication chain.

    * [Sending and Executing JavaScript in a Callback](https://backstage.forgerock.com/docs/am/6.5/auth-nodes/index.html#client-side-javascript). Authentication Node Development Guide.

    * [How do I share values between scripted policies in AM/OpenAM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a94496637). Knowledge Base.

* Performance

    [Scripted decision nodes under-performance vs. native nodes](https://bugster.forgerock.org/jira/browse/OPENAM-16112). ForgeRock JIRA.


### <a id="references-idm"></a>IDM

[Back to References](#references)

* Introduction

    * [Architectural Overview](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-overview). Integrator's Guide.

    * [Scripts in IDM/OpenIDM](https://backstage.forgerock.com/knowledge/kb/book/b51015449). Knowledge Base.

    * [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting). Integrator's Guide.

    * [Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-config). Integrator's Guide.

    * [Calling a Script From a Configuration File](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call). Integrator's Guide.

        Describes how a script could be used in different IDM contexts.

    * [Scripting Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#appendix-scripting). Integrator's Guide.

* <a id="references-idm-application-and-environment"></a>Application and Environment

    * [Managed Object Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#managed-object-configuration). Integrator's Guide.

    * [Registering Custom Scripted Actions](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#custom-scripted-actions). Integrator's Guide.

    * [Synchronization Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#sync-object-mapping). Integrator's Guide.

    * [Extending the Authorization Mechanism](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#authorization-extending). Integrator's Guide.

    * [Creating Custom Endpoints to Launch Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#custom-endpoints). Integrator's Guide.

    * [Scripting Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#appendix-scripting). Integrator's Guide.

    * [Router Reference](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#appendix-router). Integrator's Guide.

    * [Configuring HTTP Clients](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#http-client-config). Integrator's Guide.

    * [Accessing Data Objects By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#data-scripts). Integrator's Guide.

    * [OpenICF Framework 1.5.6.0 Documentation](https://backstage.forgerock.com/docs/idm/6.5/apidocs/). OpenICF Framework 1.5.6.0 Documentation.

    * [Writing Scripted Connectors With the Groovy Connector Toolkit](https://backstage.forgerock.com/docs/idm/6.5/connector-dev-guide/index.html#chap-groovy-connectors). Connector Developer's Guide.

        Scripting with Groovy in the ForgeRock Open Connector Framework and ICF Connectors.

    * [Defining Activiti Workflows](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#defining-activiti-workflows). Integrator's Guide.

    * [How do I invoke a jar file from a Groovy script in IDM/OpenIDM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a38809746). Knowledge Base.

    * [Defining Activiti Workflows](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#defining-activiti-workflows). Integrator's Guide.

* Management

    * [Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#script-config). Integrator's Guide.

    * [Managing Authentication, Authorization and Role-Based Access Control](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/index.html#chap-auth). Integrator's Guide.

    * Administrative UI
    * REST
    * File System

* Languages

    * [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino). MDN web docs.

    * [Apache Groovy Documentation](https://www.groovy-lang.org/documentation.html). The Apache Groovy programming language.

* Security

    * No scripting-specific security

* Debugging

* Examples

    * [Creating a Custom Endpoint](https://backstage.forgerock.com/docs/idm/6.5/samples-guide/index.html#chap-custom-endpoint). Samples Guide.

    * [How do I write to a file using JavaScript on a custom endpoint in IDM/OpenIDM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a88622670). Knowledge Base.

### <a id="references-ig"></a>IG

[Back to References](#references)

* Introduction

    * [Extending IG](https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/index.html#chap-extending). Gateway Guide.

    * [Scripts](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts). Configuration Reference.

        Usage, configuration, syntax, and environment.

* Application

    * [ScriptableFilter](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableFilter). Configuration Reference.

        Customize flow of requests and responses.

    * [ScriptableHandler](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableHandler). Configuration Reference.

        Customize creation of responses.

    * [ScriptableThrottlingPolicy](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableThrottlingPolicy). Configuration Reference.

        Customize throttling rates.

    * [ScriptableAccessTokenResolver](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#ScriptableAccessTokenResolver). Configuration Reference.

         Customize resolution and validation of OAuth 2.0 access tokens.

    * [OAuth2ResourceServerFilter > ScriptableResourceAccess](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#OAuth2ResourceServerFilter). Configuration Reference.

        Customize the list of OAuth 2.0 scopes required in an OAuth 2.0 access_token.

* Management

* Languages

    * [Apache Groovy Documentation](https://www.groovy-lang.org/documentation.html). The Apache Groovy programming language.

* Security

* Environment

    * [Scripts](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts). Configuration Reference.

    * [Identity Gateway 6.5.2 API](https://backstage.forgerock.com/docs/ig/6.5/apidocs/)

        Java interfaces.

* Debugging

### <a id="references-commons"></a>Commons

* [ForgeRock Common APIs](https://commons.forgerock.org/bom/apidocs/index.html). ForgeRock Common APIs.
