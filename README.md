# kubernetes-kong-multinode
Deploy multinode Kong, Cassandra, Kong-UI with Kubernetes 

# Configure a Cluster for Kong

## Setup Cassandra

Cassandra needs somekind of persistent storage. If you deploy in AWS or GCE then you should modify cassandra-pet-set.yml and enable volume attachment. For others, create a folder for /cassandra-data and don't deploy more than one cassandra pod per node.

### Create the namespace for the cluster

Each kong cluster will have their namespace

```
$ kubectl create names <DC_NAME>
```

where DC_NAME must be in lowercase.

### Create a secret to access your own private repostory

```
$ kubectl --namespace=<DC_NAME> create -f moocheriokey-secret.yml 
```

See http://stackoverflow.com/questions/32726923/pulling-images-from-private-registry-in-kubernetes

### Launch the seed Cassandra node

```
$ ./start-cassandra.sh <DC_NAME>
```

Wait for cassandra-0 pod...

```
$ kubectl get pods --namespace=<DC_NAME>
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   3          5m

```

Let's check if cassandra is running...

```
$ kubectl log cassandra-0 --namespace=dc1
W1018 13:40:36.927035   10991 cmd.go:258] log is DEPRECATED and will be removed in a future version. Use logs instead.
INFO  13:39:55 Node configuration:[authenticator=AllowAllAuthenticator; authorizer=AllowAllAuthorizer; auto_bootstrap=true; ...(truncated)
INFO  13:39:55 DiskAccessMode 'auto' determined to be mmap, indexAccessMode is mmap
INFO  13:39:55 Global memtable on-heap threshold is enabled at 507MB
INFO  13:39:55 Global memtable off-heap threshold is enabled at 507MB
INFO  13:39:56 Loaded cassandra-topology.properties for compatibility
INFO  13:40:01 Updating topology for all endpoints that have changed
WARN  13:40:16 Seed provider couldn't lookup host cassandra-0.cassandra
WARN  13:40:36 Seed provider couldn't lookup host cassandra-1.cassandra
```

### Scale Cassandra to N nodes

We are going to scale to 3 nodes. First let's scale to 2 and see if joins the cluster.

```
kubectl --namespace=<DC_NAME> patch petset cassandra -p '{"spec":{"replicas":2}}'
```

Creating pod...
```
$ kubectl get pods --namespace=<DC_NAME>
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          8m
cassandra-1   1/1       Running   0          7m
```

And the logs...
```
kubectl log cassandra-1 --namespace=<DC_NAME>
```

First let's scale to 3 and see if joins the cluster.

```
kubectl --namespace=<DC_NAME> patch petset cassandra -p '{"spec":{"replicas":3}}'
```

Creating pod...
```
$ kubectl get pods --namespace=<DC_NAME>
NAME          READY     STATUS    RESTARTS   AGE
cassandra-0   1/1       Running   0          8m
cassandra-1   1/1       Running   0          7m   
cassandra-2   1/1       Running   0          5m
```

And the logs...
```
kubectl log cassandra-2 --namespace=<DC_NAME>
```

### Cassandra service accessible to other members and nodes

Cassandra listens in port 9042, and it's accesible through the name 'cassandra' to other members of the namespace and accesible through cassandra-lb.

```
$ kubectl get services --namespace=<DC_NAME>
NAME           CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
cassandra      None         <none>        9042/TCP   14m
cassandra-lb   10.0.0.81    <pending>     9042/TCP   14m
```

To access from outside the kubernetes cluster, the service is accesible through a node port:

```
kubectl describe service cassandra-lb --namespace=<DC_NAME>
Name:                   cassandra-lb
Namespace:              <DC_NAME>
Labels:                 app=cassandra-lb
Selector:               app=cassandra-data
Type:                   LoadBalancer
IP:                     10.0.0.81
Port:                   <unset> 9042/TCP
NodePort:               <unset> 31572/TCP
Endpoints:              10.1.51.2:9042,10.1.71.2:9042,10.1.72.2:9042
Session Affinity:       None
No events.
```

## Kong containers

### Set up Kong replicate set

```
./start-kong.sh <DC_NAME>
```

We just launch one pod. We have to wait for the Kong server to start AND CONFIGURE CASSANDRA before launching more replicas.

Let's scale to 3 pods.

```
kubectl --namespace=<DC_NAME> scale rc kong-app --replicas=3
```

The Service is load balanced, and the access described as follows:

```
kubectl describe service kong-app --namespace=master
Name:                   kong-app
Namespace:              <DC_NAME>
Labels:                 name=kong
Selector:               name=kong
Type:                   LoadBalancer
IP:                     10.0.0.188
Port:                   http    8000/TCP
NodePort:               http    32628/TCP
Endpoints:              10.1.30.3:8000,10.1.5.3:8000,10.1.58.5:8000
Port:                   https   8443/TCP
NodePort:               https   31744/TCP
Endpoints:              10.1.30.3:8443,10.1.5.3:8443,10.1.58.5:8443
Port:                   admin   8001/TCP
NodePort:               admin   32075/TCP
Endpoints:              10.1.30.3:8001,10.1.5.3:8001,10.1.58.5:8001
Session Affinity:       None
No events.
```


