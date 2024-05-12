import http.server
import socketserver

# Define the port you want to use
PORT = 8000
# Define the IP address
IP_ADDRESS = "127.0.0.1"

# Define the handler for the server
class MyHttpRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        super().end_headers()

    def do_GET(self):
        super().do_GET()

# Create a custom HTTP server class by mixing in ThreadingMixIn
class ThreadedHTTPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass

# Set up the server
with ThreadedHTTPServer((IP_ADDRESS, PORT), MyHttpRequestHandler) as httpd:
    print("Serving at address", IP_ADDRESS, "and port", PORT)
    # Start the server
    httpd.serve_forever()
