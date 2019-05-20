h1 curl -X HEAD -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
insp curl -X HEAD -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15

h1 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
insp curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
