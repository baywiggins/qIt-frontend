"""Generate immutable Dart DTOs and methods from qIt's OpenAPI subset (stdlib only)."""
import json,sys,re,hashlib
from pathlib import Path
source=Path(sys.argv[1]);target=Path(sys.argv[2]);spec=json.loads(source.read_text());schemas=spec['components']['schemas']
def camel(s): return re.sub(r'_([a-z])',lambda m:m[1].upper(),s)
def normalize(s):
 if "anyOf" in s and any(t.get("type")=="null" for t in s["anyOf"]): return {**next(t for t in s["anyOf"] if t.get("type")!="null"), "nullable":True}
 return s
def dtype(s):
 s=normalize(s)
 if '$ref' in s:t=s['$ref'].split('/')[-1]
 elif s['type']=='array':t='List<'+dtype(s['items'])+'>'
 else:t={'string':'String','integer':'int','boolean':'bool','number':'double','object':'Map<String, dynamic>'}[s['type']]
 return t+('?' if s.get('nullable') else '')
def parse(s,v):
 s=normalize(s)
 base={k:x for k,x in s.items() if k!='nullable'}
 if s.get('nullable'):return f'{v} == null ? null : {parse(base,v)}'
 if '$ref' in s:
  name=s['$ref'].split('/')[-1]
  return f'{name}.fromJson({v} as Map<String, dynamic>)' if schemas[name]['type']=='object' else f"({v} as String? ?? '')"
 if s['type']=='array':return f"(({v} as List?) ?? []).map((v) => {parse(s['items'],'v')}).toList()"
 if s['type']=='string':return f"({v} as String? ?? '')"
 if s['type']=='integer':return f"({v} as num?)?.toInt() ?? {s.get('default',0)}"
 if s['type']=='number':return f"({v} as num?)?.toDouble() ?? 0"
 if s['type']=='boolean':return f"({v} as bool? ?? false)"
 raise ValueError(s)
def serialize(s,v):
 s=normalize(s)
 if '$ref' in s and schemas[s['$ref'].split('/')[-1]]['type']=='object':return v+('?' if s.get('nullable') else '')+'.toJson()'
 if s.get('type')=='array':return f'{v}.map((v) => {serialize(s["items"],"v")}).toList()'
 return v
out=['// GENERATED from OpenAPI. Run tool/generate_api.py; do not edit.',f'// Contract SHA256: {hashlib.sha256(source.read_bytes()).hexdigest()}',"typedef RequestFn = Future<dynamic> Function(String method, String path, {Map<String, dynamic>? body, Map<String, String>? query});",'']
for name,s in schemas.items():
 if s['type']!='object':out.extend([f'typedef {name} = {dtype(s)};', '']);continue
 fields={k:normalize(v) for k,v in s['properties'].items()};required=s.get('required',[])
 out.append(f'class {name} {{')
 for field,t in fields.items():out.append(f'  final {dtype(t)} {camel(field)};')
 args=[]
 for field,t in fields.items():
  if t.get('nullable'):arg=f'this.{camel(field)}'
  elif field in required:arg=f'required this.{camel(field)}'
  else:arg=f'this.{camel(field)} = '+json.dumps(t.get('default',{'string':'','integer':0,'boolean':False}.get(t.get('type'))))
  args.append(arg)
 out.append(f'  const {name}({{{", ".join(args)}}});')
 out.append(f'  factory {name}.fromJson(Map<String, dynamic> json) => {name}(')
 for field,t in fields.items():out.append(f"    {camel(field)}: {parse(t, 'json['+repr(field)+']')},")
 out.append('  );');out.append('  Map<String, dynamic> toJson() => {')
 for field,t in fields.items():out.append(f"    {'if ('+camel(field)+' != null) ' if t.get('nullable') else ''}'{field}': {serialize(t,camel(field))},")
 out.extend(['  };','}', ''])
out.extend(['class QitApi {','  final RequestFn request;','  const QitApi(this.request);'])
for path,methods in spec['paths'].items():
 for method,op in methods.items():
  if op.get('x-no-client'):continue
  params=op.get('parameters',[]);args=[f"required String {camel(p['name'])}" for p in params]
  body=op.get('requestBody');bodytype=body['content']['application/json']['schema']['$ref'].split('/')[-1] if body else None
  if body:args.append(f'required {bodytype} body')
  resp=next(v['content']['application/json']['schema'] for k,v in op['responses'].items() if k.startswith('2'))
  pathstr=re.sub(r'\{([^}]+)\}',lambda m:'${Uri.encodeComponent('+camel(m[1])+')}',path)
  query=[p for p in params if p['in']=='query']
  extra=(', body: body.toJson()' if body else '')+(', query: {'+', '.join(repr(p['name'])+': '+camel(p['name']) for p in query)+'}' if query else '')
  out.extend([f"  Future<{dtype(resp)}> {op['operationId']}({('{'+', '.join(args)+'}') if args else ''}) async {{",f"    final value = await request('{method.upper()}', '{pathstr}'{extra});",f"    return {parse(resp,'value')};",'  }'])
out.extend(['}', '']);target.parent.mkdir(parents=True,exist_ok=True);target.write_text('\n'.join(out))
