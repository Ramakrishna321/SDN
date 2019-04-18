h1 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.40 -p 80 --max-time 5
h3 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.41 -p 80 --max-time 5
insp curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.42 -p 80 --max-time 5

h1 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.40:80 --max-time 5
h3 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.41:80 --max-time 5
insp curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.42:80 --max-time 5