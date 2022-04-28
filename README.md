# k3s with footloose

K8s cluster of 3 nodes (2 workers, 1 master)

## Instructions

- Install footloose from: <https://github.com/weaveworks/footloose>
- Run `bootstrap.sh` script to setup k3s cluster with 3 nodes.

```sh
./bootstrap.sh
```

## How to access nodes

```sh
footloose ssh root@node0       # to access master node0
footloose ssh root@node1       # to access worker node1
footloose ssh root@node2       # to access worker node2
```

## How to stop the cluster

```sh
footloose stop
```

## How to delete the cluster

```sh
footloose delete
```
