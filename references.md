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

1. Scripts (Behavior)

    1. Groovy considers the last evaluated expression of a method to be the returned value.
    1. JS as well?

