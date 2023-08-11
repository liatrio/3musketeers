# ☁️ Cloud-in-a-Box ☁️
This example provides a working AWS cloud via LocalStack[^1] along with an EKS Kubernetes (k8s) cluster created via Terraform and helpful management tools.

It can serve as a local playground, starting point for local application development and testing, or just a way to get more familiar with containers, Kubernetes, terraform, and the other tools used here.

Also, **_everything_** runs in containers, so you only need the usual [3musketeers setup](../../README.md) to use this example!

## Guide
This guide walks you through the creation of a local Kubernetes cluster and sample app deployment.

### LocalStack
In this section we'll start a local AWS cloud with **many** _emulated_ services.

1. Copy the `env.example` and set your LocalStack API key
   ```shell
   cp env.example .env  # Next update the .env file with your LocalStack API key
   ```
2. Start the LocalStack cloud environment
   ```shell
   make localstack
   ```

See the [LocalStack Configuration](#localstack-configuration) section for environment variables you can modify to control the behavior of LocalStack.

**`TIP`** You can access the LocalStack web-based resource browser at https://app.localstack.cloud/resources

### Terraform
Now we can run our Infrastructure as Code (IaC) to create a working _emulated_ EKS cluster locally.

1. Initialize Terraform and download necessary modules
   ```shell
   make terraform init
   ```
2. Do a _dry run_ to see what changes Terraform would make (review the `main.tf` to see the source IaC)
   ```shell
   make terraform plan
   ```
3. Apply the changes without prompting for approval[^2]
   ```shell
   make -- terraform apply -auto-approve
   ```

At this point we have a functional EKS cluster as well as the other resources defined in the `main.tf` Terraform file.

Let's exercise some of the tools and inspect our infrastructure!

### AWS CLI
LocalStack typically uses an _awslocal_ wrapper which points the official AWS CLI at the local cloud instance.  We emulate that same behavior using an `awslocal` target in our 3Musketeers setup.

1. Check setup and confirm connectivity with LocalStack (dummy caller / account data is returned)
   ```shell
   make awslocal sts get-caller-identity
   ```
2. List the VPCs in our local AWS cloud
   ```shell
   make awslocal ec2 describe-vpcs
   ```
3. List all Subnets (both default and the ones we created in our VPC)
   ```shell
   make awslocal ec2 describe-subnets
   ```
   
Continue to inspect the infrastructure using additional AWS ClI commands.  **`NOTE`** that not _all_ AWS capabilities are mimicked by LocalStack, so you may encounter empty results or other unexpected behavior in some cases.

When you're finished, move to the next section to test our local EKS cluster.

### Kubernetes (k8s)
Now let's configure our k8s client to talk to the EKS cluster we created.

1. List the local EKS cluster info, then copy the cluster name from the output to use in the next step (e.g. `terraform-testing-haksfasE`)
   ```shell
   make awslocal eks list-clusters
   ```
 
    **`TIP`** You can also run `make -- awslocal eks list-clusters --query 'clusters[0]'` to print just the name
2. Generate a kubeconfig file `kube.config` for the cluster (replacing `<cluster-name>` with the name you copied above)
   ```shell
   make -- awslocal eks update-kubeconfig --name <cluster-name> --kubeconfig kube.config
   ```
3. Run `kubectl` to return some basic cluster information
   ```shell
   make kubectl cluster-info
   ```
   **`NOTE`** The _kubectl_ target automatically configures `kubectl` to use our generated `kube.config` and LocalStack AWS credentials
4. List everything running in our EKS cluster already
   ```shell
   make -- kubectl get all --all-namespaces
   ```

Next we'll launch a sample app in the cluster!

### Sample App
These steps are derived from the [Amazon EKS - Deploy a sample application](https://docs.aws.amazon.com/eks/latest/userguide/sample-deployment.html) guide.

1. Create a k8s namespace for our sample app
   ```shell
   make kubectl create namespace eks-sample-app
   ```
2. Create the app's _Deployment_ which manages the application instances or _Pods_
   ```shell
   make -- kubectl apply -f eks-sample-deployment.yaml
   ```
3. Create a _Service_ for the app, enabling a single point of access
   ```shell
   make -- kubectl apply -f eks-sample-service.yaml
   ```
4. List all the components of our application
   ```shell
   make -- kubectl get all -n eks-sample-app
   ```
   **`NOTE`** the _ReplicaSet_ was created automatically for us by k8s

Feel free to follow additional steps in the AWS guide (adapting the instructions as above) to validate that the service is working.  In the next section we'll configure a terminal-based "graphical" k8s client and use that to browse the cluster.

### k9s
[k9s](https://github.com/derailed/k9s) is a Kubernetes CLI that provides a visual interface to k8s clusters.  It uses key bindings similar to `vi` which makes it easy to learn.

This section also demonstrates the use of a `Dockerfile` to build and run a custom image.  The public `k9s` container image doesn't have the AWS CLI installed, which we need to authenticate to our cluster.

1. Build the image for our customized `k9s` Dockerfile
   ```shell
   make k9s-build
   ``` 
2. Run k9s
   ```shell
   make k9s
   ``` 
   You should be presented with a console-based _graphical_ interface showing all the pods in our cluster.  Type `?` for commands.
3. Shell into a _Pod_ for our sample app and test it
   1. Use `j` and `k` to highlight one of the _eks-sample..._ _Pods_
   2. Type `s` to start a shell on the running _Pod_
   3. Use `curl` to validate that the sample app is working
      ```shell
      curl eks-sample-linux-service
      ```
      You should see some HTML output containing a message that the server is successfully installed and working.  When you're finished in the _Pod_ shell, type `exit` (or `ctrl-d`) to return to k9s.
      
      From here you can continue to play with k9s, or exit and follow the [Cleanup](#cleanup) section to tear everything down.

### Cleanup
Now let's remove _everything_ 😁

1. Remove the sample EKS app from the cluster
   ```shell
   make kubectl delete namespace eks-sample-app
   ``` 
   **`NOTE`** This removes all resources associate with the namespace we created initially in a single step
2. Destroy all the infrastructure via Terraform
   ```shell
   make terraform destroy  # type 'yes' at the prompt to delete *everything*
   ``` 
   
   Now you can shut down LocalStack if you wish.

🏁 That's the end of this guide!  

## LocalStack Configuration
The following settings in the `.env` file can be used to alter LocalStack behavior.

<dl>
<dt>LOCALSTACK_DEBUG</dt>
<dd>
    <code>0</code> use standard log level  <code>default</code><br/>
    <code>1</code> enable debug logging
</dd>
<dt>LOCALSTACK_PERSISTENCE</dt>
<dd>
    <code>0</code> reset cloud state each restart <br/>
    <code>1</code> persist cloud state between restarts  <code>default</code>
</dd>
<dt>LOCALSTACK_SNAPSHOT_SAVE_STRATEGY</dt>
<dd>This settings controls the method and frequency for cloud state persistence.  The  <code>default</code> option <code>ON_REQUEST</code> persists state on every API call.  See <a href="https://docs.localstack.cloud/references/persistence-mechanism/#save-strategies" target="_blank">LocalStack Persistence Mechanism - Save Strategies</a> for other options you can set here.
</dd>
<dt>LOCALSTACK_ACTIVATE_PRO</dt>
<dd>
    <code>0</code> disable LocalStack Pro features<br/>
    <code>1</code> enable LocalStack Pro features (required for this example) <code>default</code>
</dd>
</dl>

[^1]: LocalStack Pro version required.  Set `LOCALSTACK_API_KEY` via environment or `.env` file.
[^2]: The extra `--` is required to prevent `make` from processing the `-auto-approve` argument.