#### <a id="overview-idm-osgi-debugging"></a>IDM > Core IDM > Debugging

Below is an example of attaching a debugger in [IntelliJ IDEA](https://www.jetbrains.com/idea/). You can check out details on setting debugging environment in [IntelliJ's docs](https://www.jetbrains.com/help/idea/creating-and-editing-run-debug-configurations.html), but the general steps are outlined below:

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


1. In your staging area in IDM Dockerfile (for example, in `/path/to/forgeops/docker/7.0/idm/Dockerfile`) change the environment variable `JAVA_OPTS` according to the debugging settings in the IDM project itself—as described in the [Starting in Debug Mode](https://backstage.forgerock.com/docs/idm/6.5/integrators-guide/#starting-in-debug-mode) section of the IDM Integrator's Guide. For example, in `/path/to/idm/openidm-runtime/src/main/resources/startup.sh` you may find:

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

    Another way to set an environment variable in ForgeOps is to specify one in a `configmap` references from the IDM deployment. For example:

    ```yaml
    # kustomize/base/idm-cdk/configmap.yaml

    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: idm
    data:
    IDM_ENVCONFIG_DIRS: /opt/openidm/resolver
    LOGGING_PROPERTIES: /var/run/openidm/logging/logging.properties
    OPENIDM_ANONYMOUS_PASSWORD: anonymous
    OPENIDM_CLUSTER_REMOVE_OFFLINE_NODE_STATE: "true"
    OPENIDM_CONFIG_REPO_ENABLED: "false"
    PROJECT_HOME: /opt/openidm
    # see additional RCS Agent related config in statefulset.yaml
    RCS_AGENT_HOST: rcs-agent
    RCS_AGENT_PORT: "80"
    RCS_AGENT_PATH: idm
    RCS_AGENT_USE_SSL: "false"
    RCS_AGENT_IDM_PRINCIPAL: idmPrincipal
    RCS_AGENT_CONNECTION_GROUP_CHECK_SECONDS: "900"
    RCS_AGENT_CONNECTION_CHECK_SECONDS: "5"
    RCS_AGENT_CONNECTION_TIMEOUT_SECONDS: "10"
    RCS_AGENT_WEBSOCKET_CONNECTIONS: "1"
    OPENIDM_ICF_RETRY_DELAYSECONDS: "10"
    OPENIDM_ICF_RETRY_MAXRETRIES: "12"
    OPENIDM_AUDIT_HANDLER_JSON_ENABLED: "false"
    OPENIDM_AUDIT_HANDLER_STDOUT_ENABLED: "true"
    JAVA_OPTS: "-XX:MaxRAMPercentage=65 -XX:InitialRAMPercentage=65 -XX:MaxTenuringThreshold=1 -Djava.security.egd=file:/dev/urandom -XshowSettings:vm  -XX:+PrintFlagsFinal -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n"

    # [ . . . ]
    ```

    Then, apply the change; for example:

    ```
    kubectl apply -f kustomize/base/idm-cdk/configmap.yaml
    ```

    You can check if the change was applied with the following command:

    ```
    kubectl get configmap idm -o yaml
    ```

    In order for the change to take effect, restart the IDM pod; for example:

    ```
    kubectl delete pod idm-7898bdb6b8-5zqnp
    ```

    Yet another way to apply dynamically an environment variable to a running deployment is by using `kubectl set env [ . . . ]` command. For example:

    ```
    kubectl set env deployments/idm -c openidm JAVA_OPTS="-XX:MaxRAMPercentage=64 -XX:InitialRAMPercentage=64 -XX:MaxTenuringThreshold=1 -Djava.security.egd=file:/dev/urandom -XshowSettings:vm  -XX:+PrintFlagsFinal -Xdebug -Xrunjdwp:transport=dt_socket,address=5005,server=y,suspend=n"
    ```

    You can check the updated environment with the following command:

    ```
    kubectl set env deployments/idm -c openidm --list=true
    ```

    You can remove the variable with the following command:

    ```
    kubectl set env deployments/idm -c openidm JAVA_OPTS-
    ```

    See `kubectl set env -h` for details.

    Note, a variable added to the deployment with `kubectl set env` will override one applied from the configmap, and changes in the configmap will take precedence over the environment variable specified in the Dockerfile.

1. Run the following command in your terminal against your ForgeOps deployment:

    ```bash
    kubectl port-forward idm-pod-name 5005:5005
    ```

1. In IntelliJ, open a Groovy script located in your staging area that you'd like to debug. For example, `docker/7.0/idm/script/example.groovy`.

    Debugging a script in your staging area, with auto-sync or auto-deploy on, assures that you are debugging the same content as the one that is running in the container.

    In IntelliJ, you can now set breaking points in the script, start debugging, and then evaluate the script by making authorized request to the IDM `/script` endpoint. IntelliJ should react on messages coming from localhost:5005 and follow the code in your file.
