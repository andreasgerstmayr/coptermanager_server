#!/usr/bin/env python

import serial
import time
import sys


def send_command(ser, copterid, command, value):
  data = bytearray([copterid, command, value])
  ser.write(data)

def read_response(ser):
  return ser.read(size=1)[0]

def main_loop(ser):
  while True:
    input_line = sys.stdin.readline()

    if not input_line:
      break

    parts = input_line.split(' ')
    if len(parts) >= 3:
      copterid = int(parts[0])
      command = int(parts[1])
      value = int(parts[2])

      if copterid == 0xFF and command == 0xFF and value == 0xFF:
        break

      send_command(ser, copterid, command, value)
      result = read_response(ser)

      sys.stdout.write(str(ord(result)) + '\n')
      sys.stdout.flush()


if __name__ == '__main__':
  if len(sys.argv) != 3:
    sys.stdout.write("usage: sendserialcmd.py <serialport> <baudrate>\n")
    sys.exit(1)

  serial_port, baudrate = sys.argv[1:]
  ser = serial.Serial(serial_port, int(baudrate))
  
  sys.stdout.write("ok\n")
  sys.stdout.flush()
  main_loop(ser)
  ser.close()
