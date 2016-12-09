#!/bin/python
import os, rtslib
config = rtslib.Config()
config.load('/etc/target/scsi_target.lio', allow_new_attrs=True)
list(config.apply())
