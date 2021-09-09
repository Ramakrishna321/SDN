# IK2220 Phase 1.

**Authors : Roland Kovacs, Venkata Ramakrishna Chivukula**

Description: This is the Phase 1 of the project in the
course IK2220 Software Defined Networking (SDN) and Network
Functions Virtualization (NFV).

## Run the POX controller
```
make app
```

## Run Mininet topology
```
make topo
```
Require the controller to be started separately.

## Clean up runtime artifacts
```
make clean
```

## Start test suite
```
make test
```
The command does a pre- and pos-cleanup session, then start the tests.
No additional setup is needed. When finished populates the `results/` directory.
