h1 curl -X POST -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -X POST -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15

h1 curl -X PUT -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -X PUT -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15

h1 curl -X PUT -d "bat /etc/passwd" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -X PUT -d "UPGRADE" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
