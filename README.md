
# <a id="top"></a>Scripting in ForgeRock Platform Components

ForgeRock Identity Platform components, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript and Groovy.

## Contents

* [Where to Start](#chapter-010)
* [A Look Into the Platform Scripting](#chapter-020)
* [Setting up the Environment and Running a Platform Sample with ForgeOps](#chapter-030)
* [Developing Script Files in ForgeOps](#chapter-040)
* [An Example of Scripting in ForgeRock Components](#chapter-050)
    * [ForgeRock Access Management (AM)](#top)
    * [ForgeRock Identity Management (IDM)](#top)
    * [ForgeRock Identity Gateway (IG)](#top)
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

    The doc provides information about the contexts to which scripts can be applied, the ways of managing and configuring scripts in AM, and the APIs, objects, and data available for scripts during runtime. The scripting engine configuration is described in the [Scripting Reference](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#global-scripting) part of the doc.

    > Similar and less complete section, `About Scripting`, exists in AM's [Authentication and Single Sign-On](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#about-scripting), and [Authorization](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#about-scripting) Guides.

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

## <a id="chapter-030"></a>Setting up the Environment and Running a Platform Sample with ForgeOps

[Back to the Top](#top)

The easiest way to establish a ForgeRock Identity Platform development environment is downloading and installing the [ForgeRock DevOps and Cloud Deployment](https://github.com/ForgeRock/forgeops) example (ForgeOps), and running it in a [Minikube](https://kubernetes.io/docs/setup/minikube/) instance.

The easiest way to accomplish this task is to follow [DevOps Developer's Guide: Using Minikube](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-implementation-env) article in ForgeRock documentation. You may, however, want to [Start Here](https://backstage.forgerock.com/docs/forgeops/6.5/start-here/) for getting familiar with the ForgeOps concepts.

Further instructions will assume that the ForgeRock platform software is running in Minikube. In addition, we will assume the file structure that exists in the ForgeOps project at the time of this writing.

As you go through the guide and arrive at:

* [Creating a Namespace](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-implementation-env-namespace)

    The Guide recommends [creating a namespace](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-implementation-env-namespace) in your Minikube cluster—for reasons of easier maintenance—so that you wouldn't have to remove obsolete objects by hand.

    > Otherwise, per [official Kubernetes recommendation](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/#when-to-use-multiple-namespaces), there should be no need for custom namespaces in a single user development environment that Minikube provides.
    >
    > The default namespace will provide the scope for your Kubernetes objects. You will not need to set a specific namespace in your current Minikube context, and you will not have to make changes in your trackable deployment files as described in the [Deploying the Platform](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-implementation-deploy) chapter of the guide.

    In this writing, we will follow the recommendation. We will assume _`my`_ namespace _was_ created.

    <!--
    Not sure about this section, as it might introduce unnecessary confusion. However, being aware of the default seems valuable information to consider. At the same time, just ignoring the guide that was recommended to follow may be confusing in itself too.
    -->

* [To Deploy the ForgeRock Identity Platform](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-implementation-deploy-steps)

    At the time of writing, the recommended workflow for standing up a ForgeRock Identity Platform instance with ForgeOps is using [Kustomize](https://kustomize.io/) and [Skaffold](https://skaffold.dev/). This chapter describes some preparations you need to make before deploying the platform.

    We will use Skaffold in the [development mode](https://skaffold.dev/docs/workflows/dev/), which can detect and redeploy changes in the source code (in the staging area).

    We will need an IG instance for our scripting excursion. For that, we will deploy a particular profile, `oauth2`, because at the moment it is the only one in ForgeOps that deploys IG by default. The `oauth2` profile only exists for the version 6.5 of the platform in ForgeOps; as this version is not the default one (7.0 is), we will need to specify it explicitly too.

    > For the purposes of this demo, the scripting environment didn't change substantially between versions `6.5` and `7.0`.
    <!--
    >
    > At the time version 7.0 is released, there may be additional support for scripting new functionality. For example, there may be new scripted nodes for the authentication trees.
    -->

    Now, to the steps described in the chapter and adjustment we will make for our example:

    1. Your custom namespace (unless you stayed with the `default` one) will need to be set in the `kustomization.yaml` file under `/path/to/forgeops/kustomize/overlay/6.5/oauth`.

    2. Choose version 6.5 and `oauth2` configuration profile to initiate your deployment with.

        ```bash
        $ cd /path/to/forgeops
        $ bin/config.sh init --version 6.5 --profile oauth2
        ```

        > As explained in the [Configuration Data](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-data-configuration) chapter of the Guide, deployment configurations in ForgeOps, which scripts may be a part of, are stored and versioned under the `/path/to/forgeops/config` directory, which serves as a master copy. The running platform sample reads custom configuration from a "staging area", under the `/path/to/forgeops/docker` directory and the staging area is not under version control. This means that prior to the sample being deployed, a configuration needs to be copied to the staging area in order for the custom settings to to become available in the running platform sample.
        >
        > As described in the [Managing Configurations](https://github.com/ForgeRock/forgeops/blob/master/README.md#managing-configurations) section of the main ForgeOps README, you can use `/path/to/forgeops/bin/config.sh` script to manage configurations in the running containers, the staging area, and the master directory. In this case, we use the config script to copy `oauth2` profile to the staging area. The settings saved in the staging area will take precedence over the default configuration (from the docker images), when the  containers are deployed.
        >
        > The other commands for the `config.sh` script may extract the platform configuration from the running containers and save it back to the staging area and the master directory. This allows to preserve configurations changes made to the running platform sample made, for example, via the component's REST or user-friendly graphic interface.
        >
        > As an option, a custom configuration can be updated directly in the staging area and copied back to the version-controlled master directory—to be preserved for future deployments.
        >
        > Keep in mind, however, that the script _files_ are not to be updated directly in the running containers and are not subject to be copied back to the master directory in the current implementation of the `config.sh` script.

    3. By default, if no configuration file is specified in the command line, Skaffold will read its workflow from `skaffold.yaml`. If your configuration file name is different, you will need to specify it with the `-f` or `--filename` parameter.

        In ForgeOps, `skaffold-6.5.yaml` provides deployment details for the version 6.5 of the platform. We will specify this file when executing the Skaffold command.

        > You can also use `skaffold-6.5.yaml` as a template for your custom copies of the configuration.

        We will also specify `oauth2` profile (defined in this file), for which we have copied configuration into the staging area.

        In addition, to eliminate dependency on time it takes for the deployment to stabilize, we will disable Skaffold [healthcheck feature](https://skaffold.dev/docs/workflows/ci-cd/#waiting-for-skaffold-deployments-using-healthcheck) by using the `status-check` flag set to `false`.

        > As of Skaffold [1.4.0](https://github.com/GoogleContainerTools/skaffold/releases/tag/v1.4.0), the deadline for status check is two minutes, which may not be enough for a typical ForgeOps deployment. As of version [1.6.0](https://github.com/GoogleContainerTools/skaffold/releases/tag/v1.6.0), the status check is on by default.

        The final command should look like the following:

        ```bash
        $ skaffold dev --filename=skaffold-6.5.yaml --profile=oauth2 --status-check=false
        ```

At this point, Skaffold should build and deploy your platform sample. If it fails on the first attempt, sometimes just trying it again helps. If there are persistent problems with the deployment, try [Shutting Down Your Deployment](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-shutdown) cleanly and consult with the [Troubleshooting Your Deployment](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-troubleshoot) section of the Guide.

## <a id="chapter-040"></a>Developing Script Files in ForgeOps

[Back to the Top](#top)

IDM and IG allow to define scripts in separate files, which in some cases may prove more convenient for script development and provides additional options for debugging.

In the [development mode](https://skaffold.dev/docs/workflows/dev/), by default, Skaffold will rebuild and redeploy the sample if changes in the source code are detected (in the staging area).

Redeploying may take considerable time. If a script is defined in a separate file, it is read directly from the container's file system when executed. The component does not need to be rebuilt and redeployed in order for changes in the file to take effect; the file can simply be copied into the container.

Thus, when trying out file based scripts, you may choose not to rebuild and redeploy your platform sample automatically, and instead only to copy the changed files into the corresponding container.

One way to make this process automatic is to use Skaffold's [File Sync](https://skaffold.dev/docs/pipeline-stages/filesync/) feature—by adding the `sync` section to the Skaffold `yaml` file you use for development. For example, you can copy IDM scripts from the `script` directory in your staging area into the corresponding location in the running container:

```yaml
apiVersion: skaffold/v1beta12
kind: Config
build: &default-build
artifacts:
# . . .
- image: idm
    context: docker/7.0/idm
    sync:
    manual:
        - src: 'script/*'
        dest: script
        strip: 'script/'
# . . .
```

> According to the Skaffold docs and the examples referenced there, the `strip` parameter should not be necessary in this case, as the files from the source directory—for example, `docker/6.5/idm/script`—should be copied to the corresponding `script`  directory under the `<WORKDIR>` specified in the upstream `Dockerfile`, which in this case is `/opt/openidmin/script`.
>
> However, at the time of writing, the beta version of the `File Sync` functionality copies the entire structure of the specified source into the destination folder. This means that without the `strip` parameter one may end up with a `/opt/openidmin/script/script` path created in the container. The `strip` directive allows to specify a directory hierarchy to be discarded while copying.

To prevent automatic rebuilding and redeploying, use the `--auto-build` and `--auto-deploy` options set to `false` in the development mode. You may also want to set the `--verbosity` option to the `debug` or `info` level to receive more information about the actions Skaffold performs and the results it achieves. To extend the previous example:

```bash
skaffold dev --filename=skaffold-6.5.yaml --profile=oauth2 --status-check=false --verbosity='debug' --auto-build=false --auto-deploy=false
```

> The `info` level option may be sufficient for mere registering the file synchronization events.

With these options and the `--auto-sync` option being set to `true` by default, Skaffold will not redeploy your sample when a change is detected, but it will still copy the updated files according to the `sync` section in your `yaml` file. With the non-default verbosity level, when changes have been made in a file under the `docker/7.0/idm/script`, the synchronization event should be reflected in your terminal. For example:

```bash
INFO[1140] files modified: [docker/6.5/idm/script/example.js]

Syncing 1 files idm:g141394375ib414ber9is3h . . .

INFO[1140] Copying files: map[docker/6.5/idm/script/example.js:[/opt/openidm/script/example.js]] to idm:g141394375ib414ber9is3h . . .
```

> At the time of writing, Skaffold's File Sync did not work reliably when files located deep in directory structures, under `/path/to/forgeops/config` were copied into the staging area by the `config.sh` script. Hence, it may be more dependable to edit files directly in the staging area or copy them there as files, not as part of a directory tree.

When you are ready to rebuild and redeploy your platform instance, you can `Ctrl^C` and restart it in your terminal. If your process does not run in the foreground (that is, producing visible output in the terminal), run `skaffold delete` to stop the deployment and to clean up the deployed artifacts. Then run `skaffold dev . . .` with the desired options to start the platform again. Please see [Shutting Down Your Deployment](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-shutdown) in the DevOps Developer's Guide for complete instructions on how to stop your deployment.

You can also use the [Skaffold API](https://skaffold.dev/docs/design/api/) to control your deployment when it is running. For example, to rebuild and redeploy you could run (in a separate instance of the terminal) the following:

```bash
curl -X POST http://localhost:50052/v1/execute \
-d '{
    "build": true,
    "deploy": true
}' \
-H "Content-Type: text/plain"
```

> Using the `Paste Raw Text` option, you can import cURL commands into [Postman](https://www.postman.com/), if that is your preferred environment for making arbitrary network requests. Explicitly adding the "Content-Type: text/plain" header will instruct Postman to use `raw` body for sending the data. In the terminal, this header is not needed, but provides consistency between the two environments.
>
> When you execute the command and the system does not redeploy immediately, it probably means that it didn't detect any changes in the file system that were worth of the effort. When such changes occur in the watched locations after executing the command, the sample will be redeployed.

Finally, remember that the script files are not expected to be edited directly in the containers. Thus, the scripts files are not copied by `bin/config.sh export` from the containers to the staging area and more importantly, they are not copied to the master directory with `bin/config.sh save`. This means that if you are changing script files in your staging area, you will need to remember to copy the good ones back to the master directory manually in order for them to be versioned.

## <a id="chapter-050"></a>An Example of Scripting in ForgeRock Components

[Back to the Top](#top)

To compare environments provided by ForgeRock components, we will create a script that will make an HTTP call to an online service and receive a response in the form of JSON. For this purpose, as an example, we will visit a dummy API employee record at `http://jsonplaceholder.typicode.com/users/1`. This endpoint returns JSON, which the script _could_ evaluate against other data provided by the script's environment.

> If you use server-side scripts to access an API over encrypted connection, make sure Java, the script engine is running on, trusts the underlying SSL/TLS certificate.

## <a id="chapter-060"></a>[ForgeRock Access Management](https://www.forgerock.com/platform/identity-management) (AM)

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

The server-side scripts can accept data from the client side via a well-know variable.

### Authentication Trees and Authentication Chains

AM supports two basic authentication workflows: `trees` and `chains`.

The latter approach allows for use of a client-side script defined directly in AM console. Thus, to observe a scripted authentication with a client-side script you could use an authentication chain configured in the a realm of your choice.

> The Top Level Realm is created by default during AM installation. You can find more information about [Setting Up Realms](https://backstage.forgerock.com/docs/am/6.5/maintenance-guide/index.html#chap-maint-realms) in the docs.

### Scripting in AM Console

To ensure you sign in AM with administrative configuration, navigate to your AM instance using the `/console` path. For example:

https://my-namespace.iam.example.com/am/console/

> AM allows to use separate authentication chains for administrative and non-administrative users. The choice can be made in AM's administrative console under Realms > _Realm Name_ > Authentication > Settings > Core—by selecting desired values for Administrator Authentication Configuration and Organization Authentication Configuration inputs.
>
> If you don't use the `/console` path, the default _Organization Authentication Configuration_ chain will be used, regardless of whether the actual user is an administrator or not.
>
> This may not matter if both options point to the same authentication chain.

### Scripting Authentication Chain

The default AM configuration includes a functional set of client-side and server-side scripts, the Device Id (Match) scripts, to work together as a part of an authentication module, which is the elementary unit of an authentication chain. Setting up a Device Id (Match) module is described in details in the docs under AM 6.5 › Authentication and Single Sign-On Guide > [Device Id (Match) Authentication Module](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-match-hints), along with the related [Device Id (Save)](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#device-id-save-hints) one.

Instructions for setting up the Device Id (Match) module, the rest of the [Configuring Authentication Chains and Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#configure-authn-chains-modules) chapter, and the [Using Server-side Authentication Scripts in Authentication Modules](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#sec-scripted-auth-module) one in the  Authentication and Single Sign-On Guide can serve as a reference for setting up a custom authentication chain.

### A Simple Example

To outline basic principles of scripting authentication chains in AM, we offer an example of extending the authentication flow with a simple client-side script. The script will load an external library and make an HTTP request in order to get the client's IP information.

1. The Client-side Script.

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

            1. Script element for loading an external library.

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

            For a Server-side script, you will be given a choice of language: JavaScript or Groovy. Leave the default JavaScript option selected for now.

        * Script:

            ```javascript
            ```

            The functional part of the script could be anything that may work with the available data, which includes:

            1. User record properties.
            1. Request properties.
            1. In our case, we also have a piece of information coming from the client side—the IP and some related data, received from an online provider.

            At this point, we can compare this IP with a list of allowed IP associated with the user, check the zip code in client-side data with the one in user's postal address, or make a call to a service for processing the data.



## [ForgeRock Identity Management](https://www.forgerock.com/platform/identity-management) (IDM)

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

You can run the script at `/path/to/forgeops/bin/config.sh` with the `save` command to see how this change is reflected in configuration files, as described in [Managing Configurations](https://github.com/ForgeRock/forgeops/blob/master/README.md#managing-configurations) in ForgeOps README.

Running the differences will reveal the way your multiline script is preserved in JSON. For example:

```diff
             "onUpdate" : {
-                "type" : "text/javascript",
-                "source" : "require('onUpdateUser').preserveLastSync(object, oldObject, request);"
+                "type" : "groovy",
+                "globals" : {
+                    "params" : {
+                        "url" : "http://jsonplaceholder.typicode.com/users/1",
+                        "method" : "GET"
+                    }
+                },
+                "source" : "import org.forgerock.openidm.action.*\n\ndef result = openidm.action(\"external/rest\", \"call\", params)\n\nprintln result\n\nresult"          },
```

The overwritten configuration may serve as an example for creating other inline scripts in the configuration files.

## Scripting in [ForgeRock Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG)

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

### Scripting in AM

* Get running
* Interface
* Select authentication method (tree or chain)
* Script, client (optional)

    * Access to client information. For example: user agent, geolocation, or IP.

* Script, server-side

    * Access to data from client-side script
    * Access to user record data
    * Access to scripting API


#### Environment

1. Client-side Scripting

    * Optional

1. Server-side Scripting

#### Goal

1. During authentication, perform scripted action on the client side and pass resulting data to the server-side script.

1. On server side, analyse the data received from the client-side script and make authentication decision.

#### Means

1. Authentication Chains



1. Authentication Trees

#### Debugging

Set debugging level on a Category or an Instance level: `/am/Debug.jsp`

Debug code with (the default) `logger.error` to reduce output.

Change default `Organization Authentication Configuration` to the custom chain or tree.

Editor: no `find and replace`,  no `Save` in full-screen mode.

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

