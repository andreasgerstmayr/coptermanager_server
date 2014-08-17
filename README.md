# Coptermanager

A set of applications to program your quadrocopters. Contains code for the transmitter station (arduino board with A7105 chip), a server application to control your drones in the browser and execute custom code using a JavaScript API, and a node.js package for connecting to a local or remote transmitter station.

## Overview

  * [coptermanager-arduino](https://github.com/andihit/coptermanager-arduino): arduino application which communicates with the quadrocopters
  * [coptermanager_server](https://github.com/andihit/coptermanager_server): web interface and HTTP API for controlling multiple quadrocopters
  * [coptermanager-client](https://github.com/andihit/coptermanager-client): client library to control quadrocopters with javascript (node.js)

## Possible setups

### Variant 1: full stack solution

This setup is recommended. It allows you to control multiple quadrocopters with just a single arduino board and transmitter chip. You can open the webinterface and start programming right away, inside the browser. Furthermore you can connect other apps to the HTTP API (e.g. apps for mobile devices).

### Variant 2: coptermanager-arduino and coptermanager-client

It is also possible to talk directly from the client to the arduino board. The JavaScript API is identical to variant 1.

## Requirements

  * [coptermanager-arduino](https://github.com/andihit/coptermanager-arduino) is required, please follow the instructions for setting up coptermanager-arduino.
  * [Elixir](http://elixir-lang.org) 0.15.0+
  * [Python](https://www.python.org) tested with 2.7
  * [pyserial](http://pyserial.sourceforge.net)
  * [node.js](http://nodejs.org)
  * [gulp](http://gulpjs.com)
  * [bower](http://bower.io)

## Setup instructions

1. Clone the source code of this repository
2. Review and customize config file: `apps/coptermanager_core/config/config.exs`
3. Navigate to `apps/coptermanager_web` and execute `npm install`, `bower install`, `gulp build`
4. Review and customize config file: `apps/coptermanager_web/config/config.exs`
5. Navigate to `coptermanager_server` and execute `mix deps.get`

## Start instructions

1. Navigate to `coptermanager_server` and execute `iex -S mix`
