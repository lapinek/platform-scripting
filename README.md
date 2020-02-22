
# Scripting in ForgeRock Platform Components

## Plan

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

## Exploration

## Setting up the Platform Environment

The easiest way to establish a ForgeRock Identity Platform development environment is installing the [ForgeRock DevOps and Cloud Deployment](https://github.com/ForgeRock/forgeops) sample (forgeops) and running it in a [Minikube](https://kubernetes.io/docs/setup/minikube/) instance. ForgeRock documentation supplies detailed instructions on how to set it up in its [Technology Preview: Using Minikube](https://backstage.forgerock.com/docs/platform/6.5/devops-guide-minikube/#chap-devops-implementation-env) and [DevOps Developer's Guide](https://backstage.forgerock.com/docs/platform/6.5/devops-guide/#chap-devops-implementation-env).

> The more up to date information could be found in the [Early Access DevOps Developer's Guide: Using Minikube](https://ea.forgerock.com/docs/forgeops/devops-guide-minikube/) documentation.

Further instructions will assume that the ForgeRock platform software is running in Minikube in the "default" namespace.

> This means there is no namespace explicitly created with the `kubectl create namespace` _`my-namespace`_ command). In that case, you set your current Minikube context to the default namespace:
>
> ```bash
> kubectl config set-context --current --namespace=default
> ```

Furthermore, we will assume the file structure that exists in the `forgeops` project at the time of writing, and base our examples on the version `7.0` of the platform.

> The scripting environment didn't change substantially between versions `6.5` and `7.0` and you should be able to use the same scripts in either of those.

In this setup, the custom configuration for the ForgeRock Identity Platform components, which the scripts are a part of, is stored and versioned under the `/path/to/forgeops/config` directory, which is to serve as a master copy. However, the running platform sample reads custom configuration from a "staging area", under the `/path/to/forgeops/docker/7.0` directory and the custom configuration files in the staging area are not under version control. This means they need to be copied there in order for the custom settings to take effect and for the custom scripts to become available in the running platform sample.

As described in the [Managing Configurations](https://github.com/ForgeRock/forgeops/blob/master/README.md#managing-configurations) section of the main `forgeops` README file, you could use `/path/to/forgeops/bin/config.sh` script to manage configuration data. For example, to copy configuration for the version 7.0 of the ForgeRock Identity Platform stored under the `cdk` profile, you could run:

```bash
./bin/config.sh --profile=cdk --version=7.0 init
```

In this case the versioned configuration files, kept in `/path/to/forgeops/config/7.0/cdk`, will be copied to the `/path/to/forgeops/docker/7.0` directory and the custom script content will be a part of the copied content. The settings saved under `/path/to/forgeops/docker/7.0` directory, the staging area, will take precedence over the default configuration (from the images), when the  containers are deployed. The other commands that the `config.sh` script accepts may extract the platform configuration from the running containers and save it back to the master directory. This flow preserves configurations changes made to the running platform sample with external tools; for example, via a platform component REST interface.

> The script files are not to be updated directly in the running containers and are not copied back to the master directory with the current implementation of the `config.sh` script.

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

When you are ready to rebuild and redeploy your platform instance, you can `Ctrl^C` and restart it in your terminal. If your process does not produce output in the terminal for some reason, run `skaffold delete` to stop the deployment and  cleanup the deployed artifacts and then `skaffold dev . . .` with the options to start the platform again.

You can also use the [Skaffold API](https://skaffold.dev/docs/design/api/) to control your deployment when it is running. For example, to rebuild and redeploy your sample, you could run (in a separate instance of the terminal):

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

We will create a script that will make an HTTP call to an online service and receive a response in the form of JSON. For this purpose, as an example, we will visit a dummy API `http://dummy.restapiexample.com/api/v1/employees` endpoint.

> If you use ForgeRock Identity Platform scripts to access an API over encrypted connection, make sure the individual components' Java trusts the underlying SSL/TLS certificate.

## Scripting in the [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM)

### Basics

Basic information about scripting in IDM can be found in its Integrator's Guide, in the [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting) chapter, and other sections of the documentation that have been referenced from there.

As the docs state, the custom scripts could be written in JavaScript or Groovy. In this writing, we will create both versions of an example script to run against the default environment defined in the `/path/to/idm/conf/script.json` file (under the IDM installation in the running container); for example, in `/opt/openidm/conf/script.json`. If a corresponding file is defined in the staging area, in `/path/to/forgeops/docker/7.0/idm/conf/script.json` in the described here example, this file will be copied to the container when it is deployed.

### The Scripts' Location

The script content can be defined either inline in a configuration file (that is, a file under the `/path/to/idm/conf` directory), or in a script file. For the purposes of this example, we will use the latter option, as it provides a comfortable environment for writing multiline scripts and additional options for debugging.

> Depending on your deployment strategy, defining scripts in files may not be supported, but it is an option in the described here environment which will allow us to demonstrate general principles for scripting in IDM.

The locations that IDM is aware of and can read a script file from are defined in the `sources` key in the  `script.json` file:

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

We will place the example scripts in the location denoted as `"&{idm.instance.dir}/script"`, which corresponds to the `/path/to/idm/script` in the running IDM container and the `/path/to/forgeops/docker/7.0/idm/script` directory will be our IDM staging area. You can navigate there and create or add `example.js` file with the following content:

```javascript
(function () {
    // Parameters for `openidm.action`.
    var params = {
        "url": "http://dummy.restapiexample.com/api/v1/employees",
        "method": "GET"
    }

    var result = openidm.action("external/rest", "call", params)

    return result
 }())
 ```

An equivalent script in `Groovy`, in `example.groovy` file, might look like the following:

```groovy
import org.forgerock.openidm.action.*

// Parameters for `openidm.action`.
def params = [
    url : "http://dummy.restapiexample.com/api/v1/employees",
    method: "GET"
]

openidm.action("external/rest", "call", params)
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

##### Authorization

You can see your script at work by validating it, as described in the [IDM Docs](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-endpoint). In order to be able to access the `/script` endpoint you will need to authorize your client. In `forgeops`, you would need to provide an access token from `amadmin` user associated with the `openid` scope in a request made to the IDM `/script` endpoint.

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

Then, you can validate the script by making a request to the `/script` end point and including the access token received from the authorization. For example:

```bash
curl -k -X POST \
'https://default.iam.example.com/openidm/script?_action=eval' \
-H 'Authorization: Bearer '$access_token \
-H 'Cache-Control: no-cache' \
-H 'Content-Type: application/json' \
-d '{
    "type": "javascript",
    "file": "example.js"
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
    "file": "example.groovy"
}'
```

***

##### Debugging

While working on a script you may have an option to use a debugger. We will provide an example of the debugging process based on a popular IDE for developing in Java and Groovy, [IntelliJ IDEA](https://www.jetbrains.com/idea/).

1. Open forgeops clone in IntelliJ.

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


1. In your staging area, under the IDM component directory, in Dockerfile (for example, in `/path/to/forgeops/docker/7.0/idm/Dockerfile`) change the environment variable `JAVA_OPTS` according to the debugging settings you find in the IDM project itself; for example, in `/path/to/idm/openidm-runtime/src/main/resources/startup.sh` you may find:

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

    In IntelliJ, you can now set breaking points in the script, start debugging, and then evaluate the script by making authorized request to the IDM `/script` endpoint. IntelliJ should react on messaged coming from localhost:5005 and follow the code in your file.






***
***
***

1. Debugging

    1. References

        1. `forgeops/cicd/forgeops-ui/README.MD`

    1. Docker file

        1.

    1. Kubernetes

        1. Debug


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
