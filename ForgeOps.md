<a id="top">

* [Setting up the Environment and Running a Platform Sample with ForgeOps](#chapter-030)
* [Developing Script Files in ForgeOps](#chapter-040)

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

## Script Manager and Inline Scripts in ForgeOps

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
