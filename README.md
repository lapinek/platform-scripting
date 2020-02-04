
# Notes

## Compare developing against AM, IDM, IG

1. AM

    1. JVM
    1. No file reference option

1. IG

    1. Multiline script as an array
    1. Access to JVM and API

1. IDM

    1. API: create, read, etc., request/response object


## Suggested Example

1. Make HTTP request to a service

## Exploration

### Setting up the Platform Environment

The easiest way to establish ForgeRock development environment is installing the [ForgeRock DevOps and Cloud Deployment](https://github.com/ForgeRock/forgeops) sample (forgeops) and running it in a [Minikube](https://kubernetes.io/docs/setup/minikube/) instance. ForgeRock documentation supplies detailed instructions on how to set it up in its [Technology Preview: Using Minikube](https://backstage.forgerock.com/docs/platform/6.5/devops-guide-minikube/#chap-devops-implementation-env) and [DevOps Developer's Guide](https://backstage.forgerock.com/docs/platform/6.5/devops-guide/#devops-implementation-env-cluster).

Further instructions will assume that the ForgeRock platform software is running in Minikube in the "default" namespace (which means there is no namespace explicitly created with the `kubectl create namespace` _`my-namespace`_ command). Then, you can set your current Minikube context to the default namespace:

```bash
kubectl config set-context --current --namespace=default
```

Furthermore, we will assume the file structure that exists in the `forgeops` project at the time of writing, and base our examples on the version `7.0` of the platform that can currently be found under the `docker/7.0/` directory in the `forgeops` project.

> The scripting environment didn't change substantially between versions `6.5` and `7.0`; you should be able to use scripts written for one in another.

You can use [Skaffold](https://skaffold.dev/) to facilitate continuous development in the Kubernetes environment, and start the platform in the [development mode](https://skaffold.dev/docs/workflows/dev/). By default, Skaffold will read its configuration from `skaffold.yaml`, but you can keep a separate version of this file for your development and specify this version explicitly when starting Skaffold in the development mode. For example:

```bash
skaffold dev --filename='skaffold-dev.yaml'
```

In the development mode, if changes in the source code are detected, by default, it will trigger rebuilding, redeploying, and restarting the affected pod.

Redeploying takes considerable time, but the content of the script files is read by the ForgeRock components directly from the container's file system and does not need to be redeployed in order for the changes to take effect. Hence, if you script source is a file, you may choose not to rebuild and redeploy your sample automatically, and instead copy the changed files into the affected container. You can use Skaffold's [FileSync](https://skaffold.dev/docs/pipeline-stages/filesync/) feature to make this process automatic. In order to copy changed files into a container, you will need to add the `sync` section to your development `yaml` file. For example, you can copy IDM scripts from the `script` directory in your source flies into the corresponding location in the deployed sample:

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

> According to Skaffold docs and examples referenced there, the `strip` parameter should not be necessary in this case, as the files from the source directory, `docker/7.0/idm/script`, should be copied to the corresponding `script`  directory under the `<WORKDIR>` specified in the upstream `Dockerfile` (for example, `/opt/openidmin/script`). However, at the time of writing, the beta version of the File Sync functionality copies the entire structure of the specified source into the destination folder; ending with `/opt/openidmin/script/script` created in the container. The `strip` directive allows to specify directory hierarchy to be discarded while copying.

To prevent automatic rebuilding and redeploying, use the `--auto-build` and `--auto-deploy` options set to `false` in the development mode. You may also want to set the `--verbosity` option to the `debug` level to receive more information about the actions Skaffold performs and the results it achieves. For example:

```bash
skaffold dev --filename='skaffold-dev.yaml' --verbosity='debug' --auto-build=false --auto-deploy=false
```

> In order to see just the messages related to syncing files, you may limit the log level to the `info` option. For example:

```bash
skaffold dev --filename='skaffold-dev.yaml' --verbosity='info' --auto-build=false --auto-deploy=false
```

With this, Skaffold will not redeploy your sample, but will still copy the updated scripts according to the `sync` section in the `yaml` file you use in your deployment. When you save changes in a file under the `docker/7.0/idm/script`, you should be able to observe the copying taking place in your terminal (where you started the deployment with the Skaffold CML). For example:

```bash
INFO[1140] files modified: [docker/7.0/idm/script/example.js]

Syncing 1 files idm:g141394375ib414ber9is3h . . .

INFO[1140] Copying files: map[docker/7.0/idm/script/example.js:[/opt/openidm/script/example.js]] to idm:g141394375ib414ber9is3h . . .
```

The updated scripts will be copied promptly, but the time it takes for ForgeRock component to pick up the change will be affected by settings in `docker/7.0/idm/conf/script.json`:

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

When you are ready to rebuild and redeploy your platform instance, you can `Ctrl^C` and restart it in your terminal. If you process has already been terminated, run `skaffold delete` to cleanup the deployed artifacts and then `skaffold dev . . .` with options to restart the platform.

You can also use the [Skaffold API](https://skaffold.dev/docs/design/api/) to control your deployment when it is running. For example:

```bash
curl -X POST http://localhost:50052/v1/execute -d '{"build": true, "deploy": true}'
```

### Scripting in ForgeRock [Identity Management](https://www.forgerock.com/platform/identity-management) (IDM)

#### Basics

Some basic information about scripting in IDM can be found in its Integrator's Guide, in the [Extending IDM Functionality By Using Scripts](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#chap-scripting) chapter, and other sections of the documentation referenced from there.

As the docs state, the custom scripts could be written in JavaScript or Groovy. In this writing, we will create both versions of an example script to run against the default environment defined in the `conf/script.json` file that can be found under your IDM installation.

#### Scripts' Location

We will create a script that will make an HTTP call to an online service and receive a response in the form of JSON. We will place the script in a location that IDM is aware of and read a script from; these locations are defined in the `conf/script.json` file. For example:

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

#### Executing Scripts

##### Script Content

We will place the example scripts in the location denoted as `"&{idm.instance.dir}/script"`, which corresponds to the `docker/7.0/idm/script` directory in the described here `forgeops` environment.

For the JavaScript example, create `example.js` file in the `script` directory and populate it with the following content:

```javascript
(function () {
   var result = openidm.action("external/rest", "call", {
      "url": "http://dummy.restapiexample.com/api/v1/employees",
      "method": "GET"
  })

  print(result)

  return(result)
}())
```

Note that as you change your script it will be automatically copied to the container, which is reflected in the terminal logs as described above.

##### Script Authorization

You can see your script at work by validating it, as described in the [IDM Docs](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#script-endpoint). In order to call the `/script` endpoint you will need to authorize your client. In `forgeops`, you would need to provide an access token from `amadmin` user associated with the `openid` scope in a request made to the IDM's `/script` endpoint.

For example, you can create an OAuth 2.0 client in [ForgeRock Access Management](https://www.forgerock.com/platform/access-management) (AM) with the following cURL command:

```bash
curl -k 'https://default.iam.example.com/am/json/realms/root/realm-config/agents/OAuth2Client/script' \
-X PUT \
--data '{
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
authz_code=$(curl -k -s -w "%{redirect_url}" 'https://default.iam.example.com/am/oauth2/authorize?response_type=code&client_id=script&redirect_uri=http://localhost:9999&scope=openid' \
-H 'Cookie: iPlanetDirectoryPro='$(curl -k -s 'https://default.iam.example.com/am/json/realms/root/authenticate' \
    -X POST \
    -H 'X-OpenAM-Username:amadmin' \
    -H 'X-OpenAM-Password:password' \
    | sed -e 's/^.*"tokenId":"\([^"]*\)".*$/\1/') \
| sed 's/^.*?code=\([^&]*\).*$/\1/') \
&& access_token=$(curl -k 'https://default.iam.example.com/am/oauth2/access_token' \
-X POST \
--data 'client_id=script&redirect_uri=http://localhost:9999&grant_type=authorization_code&code='$authz_code \
-H 'Content-Type: application/x-www-form-urlencoded' \
| sed 's/^.*"access_token":"\([^"]*\)".*$/\1/') \
&& echo $access_token
```

| sed 's/^.*"access_token"":"\([^"]*\)".*$/\1/') \
echo $access_token

> If you try using a script to access an API accessible only over encrypted connection with a self signed certificate, make sure IDM's Java trusts this certificate.







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
