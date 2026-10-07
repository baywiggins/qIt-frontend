#!/usr/bin/env python3
"""Local SPA server with deep-link fallback. Serve build/web on port 8081."""
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--port',type=int,default=8081);args=parser.parse_args()
root=Path(__file__).resolve().parents[1]/'build/web'
class Handler(SimpleHTTPRequestHandler):
 def __init__(self,*a,**kw):super().__init__(*a,directory=str(root),**kw)
 def do_GET(self):
  path=urlparse(self.path).path
  if not (root/path.lstrip('/')).exists() and '.' not in Path(path).name:self.path='/index.html'
  super().do_GET()
 def end_headers(self):
  self.send_header('Cache-Control','no-cache');self.send_header('X-Content-Type-Options','nosniff');super().end_headers()
ThreadingHTTPServer(('127.0.0.1',args.port),Handler).serve_forever()
