
# Scripting in ForgeRock Platform Components

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

# Exploration

ForgeRock Identity Platform components, [Access Management](https://www.forgerock.com/platform/access-management) (AM), [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM), and [Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG), allow to extend their functionality with scripts written in JavaScript and Groovy.

## Where to Start

Introduction to scripting in ForgeRock components and additional references to follow can be found in the components' documentation:

* For AM, you can read about scripting in [Developing with Scripts](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#chap-dev-scripts) section of its Development Guide.

    The doc provides information about the contexts to which scripts can be applied, the ways of managing and configuring scripts in AM, and the APIs, objects, and data available for scripts during runtime. The scripting engine configuration is described in the [Scripting Reference](https://backstage.forgerock.com/docs/am/6.5/dev-guide/#global-scripting) part of the doc.

    > Similar and less complete section, `About Scripting`, exists in AM's [Authentication and Single Sign-On](https://backstage.forgerock.com/docs/am/6.5/authentication-guide/index.html#about-scripting), and [Authorization](https://backstage.forgerock.com/docs/am/6.5/authorization-guide/#about-scripting) Guides.

* To learn about scripting in IDM, you can start with the [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting) chapter of IDM's Integrator's Guide.

    From there, [Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-config) chapter is referenced, which is followed by [Calling a Script From a Configuration File](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call) describing how a script could be used in different IDM contexts.

    The scripting environment is further explained in the [Scripting Reference]() chapter of the Guide.

    Information about scripting in IDM is also present in ForgeRock [Knowledge Base](https://backstage.forgerock.com/knowledge/kb/home). In particular, [FAQ: Scripts in IDM/OpenIDM](https://backstage.forgerock.com/knowledge/kb/article/a29088283) could serve as a good initial reference.

    > The knowledge base site content is being constantly updated and allows to search for articles addressing a particular problem. For example, [How do I write to a file using JavaScript on a custom endpoint in IDM/OpenIDM (All versions)?](https://backstage.forgerock.com/knowledge/kb/article/a88622670).

* Extending IG with scripts starts in the [About Scripting](https://backstage.forgerock.com/docs/ig/6.5/gateway-guide/index.html#about-scripting) section of its Gateway Guide.

    Further information about scripts' usage, configuration, syntax, and environment can be found in IG Configuration Reference for [Scripts](https://backstage.forgerock.com/docs/ig/6.5/reference/index.html#Scripts).

## Examples

Across documentation, there are meaningful, component specific examples of how the scripts could be employed.

For a quick overview of scripting in AM, IDM, and IG, we will perform a simple scripted operation in a script associated with an event in the corresponding component. This will allow us to depict some similarities and some differences in how scripting can be approached in different ForgeRock components. The script will perform a network call to an external service and print or log the results.

But first, we will need an environment for deploying all three components.

## Setting up the Platform Environment

The easiest way to establish a ForgeRock Identity Platform development environment is installing the [ForgeRock DevOps and Cloud Deployment](https://github.com/ForgeRock/forgeops) sample (forgeops) and running it in a [Minikube](https://kubernetes.io/docs/setup/minikube/) instance. ForgeRock documentation supplies detailed instructions on how to set it up in its [DevOps Developer's Guide: Using Minikube](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-implementation-env).

> You may also want to [Start Here](https://backstage.forgerock.com/docs/forgeops/6.5/start-here/) for getting familiar with the ForgeRock DevOps concepts.

Further instructions will assume that the ForgeRock platform software is running in Minikube in the `default` namespace.

> This means there is no namespace explicitly created with the `kubectl create namespace` _`my-namespace`_ command) and you set your Minikube context to the default one:
>
> ```bash
> kubectl config set-context --current --namespace=default
> ```
>
> We only need this convention to agree on the URLs used in examples.

Furthermore, we will assume the file structure that exists in the `forgeops` project at the time of writing, and unless specifically noted, base our examples on the version `7.0` of the platform.

> The scripting environment didn't change substantially between versions `6.5` and `7.0` and you should be able to use the same scripts in either of those.

In this setup, the custom configuration for the ForgeRock Identity Platform components, which the some of the scripts are a part of, is stored and versioned under the `/path/to/forgeops/config` directory, which is to serve as a master copy. However, the running platform sample reads custom configuration from a "staging area", under the `/path/to/forgeops/docker/7.0` directory and the custom configuration files in the staging area are not under version control. This means that prior the sample is deployed, they need to be copied to the staging area in order for the custom settings to take effect and for the (versioned) custom scripts to become available in the running platform sample.

> Learn more [About Data Used by the Platform](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-data) and its [Configuration Profiles](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-data-profiles) in the ForgeOps documentation.

As described in the [Managing Configurations](https://github.com/ForgeRock/forgeops/blob/master/README.md#managing-configurations) section of the main `forgeops` README file, you could use `/path/to/forgeops/bin/config.sh` script to manage configuration data. For example, to copy configuration for the version 7.0 of the ForgeRock Identity Platform stored under the `cdk` profile, you could run:

```bash
./bin/config.sh --profile=cdk --version=7.0 init
```

In this case the versioned configuration files, kept in `/path/to/forgeops/config/7.0/cdk`, will be copied to the `/path/to/forgeops/docker/7.0` directory and the custom script content will be a part of the copied content. The settings saved under `/path/to/forgeops/docker/7.0` directory, the staging area, will take precedence over the default configuration (from the docker images), when the  containers are deployed. The other commands that the `config.sh` script accepts may extract the platform configuration from the running containers and save it back to the master directory. This latter flow helps to preserve configurations changes made to the running platform sample with external tools—for example, via a platform component REST interface.

The script _files_, however, are not to be updated directly in the running containers and are not copied back to the master directory with the current implementation of the `config.sh` script.

Alternatively, the custom configuration can be updated directly in the staging area and copied back to the version-controlled master directory—to be preserved for future deployments.

At the time of writing, the recommended workflow for instantiating a ForgeRock Identity Platform sample with `forgeops` is using [Kustomize](https://kustomize.io/) and [Skaffold](https://skaffold.dev/). In the [development mode](https://skaffold.dev/docs/workflows/dev/), Skaffold will rebuild and redeploy the sample if changes in the source code are detected.

Redeploying may take considerable time, but the script files are read by the ForgeRock components from the container's file system and the sample does not need to be redeployed in order for any changes in the files to take effect. Hence, if you script source is a file, you may choose not to rebuild and redeploy your sample automatically, and instead only to copy the changed files into the corresponding container. One way to make this process automatic is to use Skaffold's [File Sync](https://skaffold.dev/docs/pipeline-stages/filesync/) feature—by adding the `sync` section to your development `yaml` file. For example, you can copy IDM scripts from the `script` directory in your source flies into the corresponding location in the running container:

```yaml
build:
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

> According to the Skaffold docs and the examples referenced there, the `strip` parameter should not be necessary in this case, as the files from the source directory, `docker/7.0/idm/script`, should be copied to the corresponding `script`  directory under the `<WORKDIR>` specified in the upstream `Dockerfile` (for example, in IDM's case, `/opt/openidmin/script`). However, at the time of writing, the beta version of the `File Sync` functionality copies the entire structure of the specified source into the destination folder; ending up with `/opt/openidmin/script/script` created in the container. The `strip` directive allows to specify directory hierarchy to be discarded while copying.

By default, Skaffold will read its configuration from `skaffold.yaml`, but you can keep a separate copy of this file for your development and make configuration changes in there. Then, specify this copy explicitly when starting Skaffold in the development mode, with the `--filename` flag.  For example:

```bash
skaffold dev --filename='skaffold-dev.yaml'
```

To prevent automatic rebuilding and redeploying, use the `--auto-build` and `--auto-deploy` options set to `false` in the development mode. You may also want to set the `--verbosity` option to the `debug` or `info` level to receive more information about the actions Skaffold performs and the results it achieves. For example:

```bash
skaffold dev --filename='skaffold-dev.yaml' --verbosity='debug' --auto-build=false --auto-deploy=false
```

> The `info` level option may be sufficient for simply registering file synchronization events.

With these options and the `--auto-sync` option being set to `true` by default, Skaffold will not redeploy your sample when a change is detected, but it will still copy the updated scripts according to the `sync` section in your `yaml` file. With the aforementioned example, when changes have been saved a file under the `docker/7.0/idm/script`, the synchronization event should be reflected in your terminal. For example:

```bash
INFO[1140] files modified: [docker/7.0/idm/script/example.js]

Syncing 1 files idm:g141394375ib414ber9is3h . . .

INFO[1140] Copying files: map[docker/7.0/idm/script/example.js:[/opt/openidm/script/example.js]] to idm:g141394375ib414ber9is3h . . .
```

> At the time of writing, Skaffold's File Sync did not work for files under deep directory structures copied into the staging area, which what `config.sh init` does, at least in some environments. Hence, it may be more reliable to edit files directly in the staging area or copy them there explicitly—that is, not as part of a directory tree—in order for the File Sync functionality to detect and pick up the changes.

When you are ready to rebuild and redeploy your platform instance, you can `Ctrl^C` and restart it in your terminal. If your process does not run in the foreground, producing visible output in the terminal, run `skaffold delete` to stop the deployment and  cleanup the deployed artifacts and then `skaffold dev . . .` with the options to start the platform again. Please see [Shutting Down Your Deployment](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#chap-devops-shutdown) in the DevOps Developer's Guide for complete instructions on how to stop your deployment.

You can also use the [Skaffold API](https://skaffold.dev/docs/design/api/) to control your deployment when it is running. For example, to rebuild and redeploy you could run (in a separate instance of the terminal):

```bash
curl -X POST http://localhost:50052/v1/execute \
-d '{
    "build": true,
    "deploy": true
}' \
-H "Content-Type: text/plain"
```

> Using the `Paste Raw Text` option, you can import cURL commands into [Postman](https://www.postman.com/), if that is your preferred environment for making arbitrary network requests. Explicitly adding the "Content-Type: text/plain" header will instruct Postman to use `raw` body for sending the data. In the terminal, this header is not needed.
>
> When you execute the command and the system does not redeploy immediately, it probably means that it didn't detect any changes in the file system that were worth of the effort. When such changes occur in the watched locations after executing the command, deployment will be initiated.

## Scripting in the ForgeRock Components

To compare environments provided by ForgeRock components, we will create a script that will make an HTTP call to an online service and receive a response in the form of JSON. For this purpose, as an example, we will visit a dummy API `http://dummy.restapiexample.com/api/v1/employees` endpoint.

> If you use ForgeRock Identity Platform scripts to access an API over encrypted connection, make sure the individual components' Java trusts the underlying SSL/TLS certificate.

## Scripting in [ForgeRock Identity Management](https://www.forgerock.com/platform/identity-management) (IDM)

### Basics

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

We will place the example scripts in the location denoted as `"&{idm.instance.dir}/script"`, which corresponds to `/path/to/idm/script` in the running IDM container and `/path/to/forgeops/docker/7.0/idm/script` directory will be our IDM staging area. You can navigate there and create `example.js` file with the following content:

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
    "url": "http://dummy.restapiexample.com/api/v1/employees",
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

You can try out your script by validating it, as described in the [IDM Docs](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-endpoint). In order to be able to access the `/script` endpoint you will need to authorize your client for making request to the IDM `/script` endpoint. In `forgeops`, you would need to provide an access token from `amadmin` user. The token will need to be associated with the `openid` scope.

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
            "url": "http://dummy.restapiexample.com/api/v1/employees",
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
            "url": "http://dummy.restapiexample.com/api/v1/employees",
            "method": "GET"
        }
    }
}'
```

***

#### Debugging

While working on a script (file) you may have an option to use a debugger. We will provide an example of the debugging process based on a popular IDE for developing in Java and Groovy, [IntelliJ IDEA](https://www.jetbrains.com/idea/). You can check out details on setting debugging environment in [IntelliJ's docs](https://www.jetbrains.com/help/idea/creating-and-editing-run-debug-configurations.html), but the general steps are outlined below:

1. Open your `forgeops` clone in IntelliJ.

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
                        "url" : "http://dummy.restapiexample.com/api/v1/employees",
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
+                        "url" : "http://dummy.restapiexample.com/api/v1/employees",
+                        "method" : "GET"
+                    }
+                },
+                "source" : "import org.forgerock.openidm.action.*\n\ndef result = openidm.action(\"external/rest\", \"call\", params)\n\nprintln result\n\nresult"          },
```

This can serve as an illustration for creating other inline scripts in the configuration files.

##### Notes

###### From IDM Integrator's Guide:

* [5.11.1.2. Custom Progressive Profile Conditions](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#progressive-profile-queries-scripts):

    > While you can also reference metadata for scripts, you can't check for all available fields, as there is no outer object field. However, you can refer to fields that are part of the user object.

* [6.4.1. Running Queries and Commands on the Repository](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#repo-commands)

    > The command can be called from a script.

* [7.7. Setting the Script Configuration](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-config)

* [7.8. Calling a Script From a Configuration File](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-call)

* [8.1. Accessing Data Objects By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#data-scripts)

## Scripting in [ForgeRock Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG)

Please see [IG Docs](https://backstage.forgerock.com/docs/ig) for comprehensive coverage of the component.

### IG in ForgeOps

IG is not included in the `cdk` profile we've been using so far. It is used, however, for OAuth 2.0 API protection in the `oauth2` profile in the 6.5 version of the ForgeOps configuration. To have the `oauth2` profile deployed, stop your current deployment with `Ctrl^C` if it is still running in the foreground, or run `skaffold delete` if the deployment is not active in your terminal. Then, clear the persistent volumes with `kubectl delete pvc --all`. Optionally, you can delete your VM with `minikube delete` and [create a new one](https://backstage.forgerock.com/docs/forgeops/6.5/devops-guide-minikube/#devops-implementation-env-cluster).

After setting your minikube development environment and before deploying with Skaffold, copy the `oauth2` profile configuration into the staging area. For that, navigate to `/path/to/forgeops` and run:

```bash
./bin/config.sh init --version 6.5 --profile oauth2
```

You should see that your staging area has been initialized with the specific configuration for IDM, IG, and AM (via the `amster` pod definition):

```bash
removing idm configs from docker/6.5
cp -r config/6.5/oauth2/idm docker/6.5

removing ig configs from docker/6.5
cp -r config/6.5/oauth2/ig docker/6.5

removing amster configs from docker/6.5
cp -r config/6.5/oauth2/amster docker/6.5
cp config/6.5/oauth2/secrets/config/* docker/forgeops-secrets/forgeops-secrets-image/config
```

Make a copy of the `skaffold-6.5.yaml` file for making configuration changes—such as Skaffold FileSync setup. For example:

```bash
cp skaffold-6.5.yaml skaffold-dev-6.5.yaml
```

Now, you can deploy the `oauth2` profile with the following Skaffold command:

```bash
skaffold dev --filename skaffold-dev-6.5.yaml --profile oauth2
```

You can confirm presence of the IG pod in your deployment, the pod that starts with the `ig-` prefix, by running:

```bash
kubectl get pods | grep ig-
ig-64895df56-cj6bc       1/1     Running     0          110m
```



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
                            "url": "http://dummy.restapiexample.com/api/v1/employees",
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

The script, functionally very similar to the one we used in IDM, itself might look like the following:

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
                "url": "http://dummy.restapiexample.com/api/v1/employees",
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

* AM and IDM use [Rhino](https://developer.mozilla.org/en-US/docs/Mozilla/Projects/Rhino) (scripting engine) to support server-side JavaScript. The server-side scripts

Now, to differences.

## Differences

* Languages

    IG, currently, does not support JavaScript.

    IDM only supports JavaScript on the server side, using Rhino.

    AM allows for client-side scripts, which run in the browser environment. The server-side scripts, running on Rhino, can use data obtained with the client-side ones.

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

