''' IK2220 SDN Phase 1 Web Server '''

from SimpleHTTPServer import SimpleHTTPRequestHandler
import SocketServer
import os

# Change service root
os.chdir("services/web")

# Start web server at port 80
PORT = 80
Handler = SimpleHTTPRequestHandler
httpd = SocketServer.TCPServer(("", PORT), Handler)
print("serving at port", PORT)
httpd.serve_forever()
