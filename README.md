# SDNThrowDown2016
GITHUB RELEASE

Version 1.0 alpha (one-week dev)
* Juniper Northstar REST API Topological Interpreter
* Cytoscape.js Visualization with CoLa.js
* Redis Telemetric Information fetching (clunky!)
* "Flattened" network information datastructures for jQuery attribute calls
* Ruby FSM has link failure detection with visual representation
* MISSING: Physical link LSP repair using CSPF on topographic info

# Background
This project is designed to excel participants into the world of Traffic Engineering. A "live' network topology was created to simulate a core provider network with volitile infrastructure. The ultimate goal was to use all the tools avalible to visualize and repair the network with the shortest LSP downtime.

# Architecture
Our system is designed to provide the network administrator / traffic engineer with a live visual representation of the network with as near real-time rendering as we could achieve. Our goal is to preform the CSPF calculations in Javascript before updating the ERO of the LSP in the controller. We believe this would utilize the core of the SDN concept as the Network Admins browser on their system would be doing the calculation live as it was accessed and have great scalability.
