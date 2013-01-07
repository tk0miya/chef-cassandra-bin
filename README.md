Description
===========

Installs cassandra using binary of apache.org 

Requirements
============

* Linux (I'd tested on CentOS 5.7)

Attributes
==========

* `node['cassandra-bin']['url']` - distributed URL of cassandra (default: http://archive.apache.org/dist/cassandra)
* `node['cassandra-bin']['version']` - Version of cassandra

Usage
=====

Simply include the `cassandra-bin` and the Cassandra will be installed to your system.
