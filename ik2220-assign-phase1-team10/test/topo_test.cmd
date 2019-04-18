h4 nc -u -w 2 -zv 100.0.0.20 80 53 443 42 69 22 179 636 161 989
h4 nc -w 2 -zv 100.0.0.20 80 53 443 42 69 22 179 636 161 989

h2 nc -u -w 2 -zv 100.0.0.21 80 53 443 42 69 22 179 636 161 989
h2 nc -w 2 -zv 100.0.0.21 80 53 443 42 69 22 179 636 161 989

insp nc -u -w 2 -zv 100.0.0.22 80 53 443 42 69 22 179 636 161 989
insp nc -w 2 -zv 100.0.0.22 80 53 443 42 69 22 179 636 161 989

h1 dig ws1.ik2220.com @100.0.0.20
h3 dig ws2.ik2220.com @100.0.0.21
insp dig ws3.ik2220.com @100.0.0.22

h1 dig ws1.ik2220.com @100.0.0.20 -p 69
h3 dig ws2.ik2220.com @100.0.0.21 -p 69
insp dig ws3.ik2220.com @100.0.0.22 -p 69

h1 curl 100.0.0.40 -p 80 --max-time 5
h3 curl 100.0.0.41 -p 80 --max-time 5
insp curl 100.0.0.42 -p 80 --max-time 5

h1 curl 100.0.0.40:80 --max-time 5
h3 curl 100.0.0.41:80 --max-time 5
insp curl 100.0.0.42:80 --max-time 5

h2 curl 100.0.0.40:69 --max-time 5
h4 curl 100.0.0.41:69 --max-time 5
insp curl 100.0.0.42:69 --max-time 5

pingall