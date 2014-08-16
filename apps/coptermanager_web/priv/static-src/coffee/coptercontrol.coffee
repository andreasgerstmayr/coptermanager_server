coptermanager = require 'coptermanager'

KeyCodes =
  Up: 38
  Down: 40
  Left: 37
  Right: 39
  W: 87
  S: 83
  A: 65
  D: 68

class CopterControl

  constructor: ->
    @client = coptermanager.createRemoteClient(endpoint: API_ENDPOINT, copterid: COPTERID)

    @throttle = 0
    @rudder = 0x7F
    @aileron = 0x7F
    @elevator = 0x7F

    $(document).on 'keydown', @keyDown

  keyDown: (e) =>
    switch e.keyCode
      when KeyCodes.W
        @throttle += 30
        @throttle = 0xFF if @throttle > 0xFF
        @client.throttle @throttle
      when KeyCodes.S
        @throttle -= 30
        @throttle = 0 if @throttle < 0
        @client.throttle @throttle

      when KeyCodes.A
        @rudder -= 10
        @rudder = 0x34 if @rudder < 0x34
        @client.rudder @rudder
      when KeyCodes.D
        @rudder += 10
        @rudder = 0xCC if @rudder > 0xCC
        @client.rudder @rudder

      when KeyCodes.Up
        @elevator += 10
        @elevator = 0xBC if @elevator > 0xBC
        @client.elevator @elevator
      when KeyCodes.Down
        @elevator -= 10
        @elevator = 0x3E if @elevator < 0x3E
        @client.elevator @elevator

      when KeyCodes.Left
        @aileron -= 10
        @aileron = 0x45 if @aileron < 0x45
        @client.aileron @aileron
      when KeyCodes.Right
        @aileron += 10
        @aileron = 0xC3 if @aileron > 0xC3
        @client.aileron @aileron

$(document).ready ->
  new CopterControl
