h1 curl -w '%{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.40 -p 80 --max-time 5
h3 curl -w '%{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.41 -p 80 --max-time 5
insp curl -w '%{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.42 -p 80 --max-time 5