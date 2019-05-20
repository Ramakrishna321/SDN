h1 curl -X HEAD -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h1 curl -X PUT -d "cat /etc/passwd" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -X PUT -d "cat /var/log" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h1 curl -X PUT -d "INSERT" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h2 curl -X PUT -d "UPDATE" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
h1 curl -X PUT -d "DELETE" -w '\n %{local_ip} to %{remote_ip} : %{remote_port}\n' 100.0.0.45 -p 80 --max-time 15
