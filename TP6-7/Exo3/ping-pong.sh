#!/bin/bash

function ping(){
  echo 'ping'
  kill -12 $$
}

function pong(){
  echo 'pong'
  kill -10 $$
}

trap "ping" 10
trap "pong" 12
kill -10 $$
read