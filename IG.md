# Scripting in [ForgeRock Identity Gateway](https://www.forgerock.com/platform/identity-gateway) (IG)

## IG in ForgeOps

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

