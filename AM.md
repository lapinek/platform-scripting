# Scripting in ForgeRock Access Management (AM)—A Quick Introduction

If you haven't done so, please get yourself familiar with AM by visiting its [documentation](https://backstage.forgerock.com/docs/am/6.5) site.

AM provides authentication and authorization services. Custom scripts can be used to augment the default functionality.

## What can be done with Scripts in AM

The scripts in AM could be client-side, running in the user agent, and server-side, running after the user submits their request. There is more details in [The Scripting Environment](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#script-env)

### Client-Side Scripts

The use case for the client-side scripts is collecting information about the user agent: its properties, environment (including [Geolocation](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/geolocation)), IP, and whatever else that could be collected with a custom script.

The client-side scripts are to run in a browser and as such, they need to be written in JavaScript and be otherwise compatible with the browser.

### Server-Side Scripts

As AM provides authentication and authorization services to applications, the decision making process on user identification and access management can be aided with server-side scripts. The server-side scripts can be written in JavaScript or Groovy.

For more information about scripting environment in AM, please consult with the [About Scripting](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/#about-scripting) and [Developing with Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts) sections in its documentation.

## How to approach scripting in AM

As follows from the [docs](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#manage-scripts), AM supplies scripting API that can be utilized via REST or command line interfaces, which could be an efficient way to manage scripts in automatically maintained environments—like production deployments.

At the same time, AM console provides a visual and easy to use interface for managing scripts and applying them to authentication and authorization means.

To illustrate, we will outline basic steps for applying a script to an authentication procedure using the AM console.

In default AM configuration, there is a set of client-side and server-side scripts to work together as a part of an authentication module. These are described in in the docs at AM 6.5 › Authentication and Single Sign-On Guide > [Device ID (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints).

We will use simpler scripts and just outline the process of implementing scripted authentication.

> You can read more about authentication in AM's in its [Authentication and Single Sign-On Guide](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html).

### Scripting in AM Console

In the following example, we will extend an authentication procedure used by AM to verify user identity.

AM supports authentication with `trees`—built with `nodes`, and `chains`—built with `modules`. The latter approach allows for use of client-side scripts defined directly in AM, using its console. To demonstrate a scripted authentication with the AM's built-in means, we will use an authentication chain configured in the Top Level Realm, which is set in AM by default.

> You can read about [Setting Up Realms](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#chap-maint-realms) in the docs.

1. The Authentication Chain Example

    1. The Administrative Interface

        To sign in with administrative configuration, navigate to your AM instance `/console` path. For example:

        https://default.iam.example.com/am/console/

        > AM allows to use separate authentication chains for administrative and non-administrative users. The choice can be made in AM's administrative console under Realms > Top Level Realm > Authentication > Settings > Core—by selecting desired values for Administrator Authentication Configuration and Organization Authentication Configuration inputs.
        If you don't use the `/console` path, the default _Organization Authentication Configuration_ chain will be used, regardless of whether the actual user is an administrator or not.
        >
        > This may not matter if both options point to the same authentication chain.

    1. The Client-Side Script

        1. Navigate to Top Level Realm > Scripts.

            You will see number of predefined scripts, some of which can serve as templates for the new ones.

        1. Select + New Script.

            In the New Script dialog, provide Name and select Client-side Authentication for the Script Type input. For example:

            * Name:  Scripted Module - Client Side Example
            * Script Type: Client-side Authentication

        1. Select the Create button.

            In the next dialog, with the new script properties, populate the Script input with the following JavaScript code:

            * Script:

            ```javascript
            /*
            * Object to hold the data to be passed to the server-side processing.
            *
            * The name of this object can be any valid variable name.
            */
            var data = {};

            /*
            * Script element for loading an external library.
            *
            * When the script is loaded, it will make a request to an external source to obtain the client's IP information.
            *
            * The information, received as a JSON object, is then saved as a string in the
            * value of the `output` input in the form provided on the client side automatically. The value will become available to the server-side script as the `clientScriptOutputData` javascript variable.
            */
            var script = document.createElement('script');

            script.src = 'https://code.jquery.com/jquery-3.4.1.min.js';
            script.onload = function (e) {
                $.getJSON('https://ipgeolocation.com/?json=1', function (json) {
                clientScriptOutputData.ip = json;
                    output.value = JSON.stringify(data);

                    submit();
                });
            }

            document.getElementsByTagName('head')[0].appendChild(script);
            /*
            *
            * To allow for the asynchronous script operation to complete,
            * automatic submission of the form on the page is delayed via a setting that takes milliseconds.
            */
            autoSubmitDelay = 4000;
            ```

            The language for a client-side script is always JavaScript, for the script's run time environment is assumed to be a browser of some sort.

        1. Select the Save Changes button.

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

    1. The Server-Side Script

        You can read about [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) in the docs.

        The script used in the described module, the `Scripted Module - Server Side` script, is included in AM and can be used directly, by being included in an authentication module. But it also serve as a starting template for all new scripts of type "Server-side Authentication". In our example, we will replace it with functionality that relies on the results delivered by our client-side script.

        1. Navigate back to Top Level Realm > Scripts.

        1. Select + New Script.

            In the New Script dialog, provide Name and this time, select Server-side Authentication for the Script Type input. For example:

            * Name:  Scripted Module - Server Side Example
            * Script Type: Server-side Authentication

        1. Select the Create button.

            In the following dialog, for a server-side script, you will be given a choice of language: JavaScript or Groovy. This time we will leave the default JavaScript option selected.

            The functional part of the script could be anything that may work with the available data:

            1. User record properties.
            1. Request properties.
            1. In our case, we also have a piece of information coming from the client side—the IP and some related data, received from an online provider.

            At this point, we can compare this IP with a list of allowed IP associated with the user, check the zip code in client-side data with the one in user's postal address, or make a call to a service for processing the data.


## The Key Specifics in Scripting in AM

AM offers an interface in its console for

## Examples

Introduction to scripting authentication chains:
https://forum.forgerock.com/2016/02/scripting-in-openam-13/
