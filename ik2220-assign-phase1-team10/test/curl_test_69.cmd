h2 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.40:69 --max-time 5
h4 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.41:69 --max-time 5
insp curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.42:69 --max-time 5

h2 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.40:69 --max-time 5
h4 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.41:69 --max-time 5
insp curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.42:69 --max-time 5