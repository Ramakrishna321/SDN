from SimpleHTTPServer import SimpleHTTPRequestHandler
import SocketServer

PORT = 80
Handler = SimpleHTTPRequestHandler
httpd = SocketServer.TCPServer(("", PORT), Handler)
print("serving at port", PORT)
httpd.serve_forever()
