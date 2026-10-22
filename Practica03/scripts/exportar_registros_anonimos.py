import pathlib,subprocess,json,datetime,re,collections,os
root=pathlib.Path(__file__).resolve().parents[2]
site=root/'Practica03/diccionario'
dataset=json.loads((site/'data.js').read_text(encoding='utf-8').removeprefix('window.DICTIONARY = ').rstrip(';\n'))
mysql=r'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
args=[mysql,'-h','127.0.0.1','-P','40480','-u','Jose.Luis','--connect-timeout=10','--default-character-set=utf8mb4','--batch','--raw','--skip-column-names','--database=db_test']
def execute(sql):
    p=subprocess.run(args+['--execute',sql],capture_output=True,text=True,encoding='utf-8')
    if p.returncode:raise SystemExit('No se pudo consultar MySQL: '+p.stderr.strip())
    return [json.loads(l) for l in p.stdout.splitlines() if l.strip()]
schema=execute("SELECT JSON_OBJECT('table',c.TABLE_NAME,'column',c.COLUMN_NAME,'type',c.DATA_TYPE) FROM information_schema.COLUMNS c JOIN information_schema.TABLES t ON t.TABLE_SCHEMA=c.TABLE_SCHEMA AND t.TABLE_NAME=c.TABLE_NAME WHERE c.TABLE_SCHEMA='db_test' AND t.TABLE_TYPE='BASE TABLE' ORDER BY c.TABLE_NAME,c.ORDINAL_POSITION")
expected={(f['table'],f['name']) for f in dataset['fields']}
assert {(c['table'],c['column']) for c in schema}==expected,'El esquema cambio. Revisar columnas antes de publicar registros.'
mask={
 'tb_users':{'email','nickname','password'},
 'tb_people':{'first_name','last_name','second_last_name','birth_date','gender','phone','nationality'},
 'tb_user_addresses':{'address_label','recipient_name','recipient_phone','delivery_instructions','latitude','longitude'},
 'tbd_address_components':{'value'},
 'tbd_user_payment_methods':{'provider_method_ref','label','last_four'},
 'tb_logs':{'db_user','description'},
}
def quoted(name):
    assert re.fullmatch(r'[A-Za-z_][A-Za-z_0-9]*',name)
    return '`'+name+'`'
def value(c):
    table,column,kind=c['table'],c['column'],c['type'];q=quoted(column)
    if column in mask.get(table,set()):
        if table=='tb_users' and column=='email':replacement="CONCAT('usuario-',id,'@ejemplo.invalid')"
        elif table=='tb_users' and column=='nickname':replacement="CONCAT('usuario-',id)"
        elif column=='password':replacement="'[OCULTO]'"
        else:replacement="'[ANONIMIZADO]'"
        return f'CASE WHEN {q} IS NULL THEN NULL ELSE {replacement} END'
    if kind=='bit':return f'CAST({q} AS UNSIGNED)'
    if kind in ['decimal','bigint']:return f'CAST({q} AS CHAR)'
    return q
queries=['SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ','START TRANSACTION WITH CONSISTENT SNAPSHOT, READ ONLY']
for t in dataset['tables']:
    name=t['name'];columns=[c for c in schema if c['table']==name]
    queries.append(f"SELECT JSON_OBJECT('kind','count','table','{name}','total',COUNT(*)) FROM {quoted(name)}")
    entries=','.join("'"+c['column']+"',"+value(c) for c in columns)
    pk=sorted([i for i in t['indexes'] if i['name']=='PRIMARY'],key=lambda i:i['position'])
    order=','.join(quoted(i['column']) for i in pk)
    queries.append(f"SELECT JSON_OBJECT('kind','row','table','{name}','record',JSON_OBJECT({entries})) FROM {quoted(name)} ORDER BY {order}")
queries.append('COMMIT')
output=execute(';'.join(queries)+';')
rows=collections.defaultdict(list);counts={}
for r in output:
    if r['kind']=='count':counts[r['table']]=r['total']
    else:rows[r['table']].append(r['record'])
assert len(counts)==16
snapshot=datetime.datetime.now(datetime.timezone.utc).astimezone(datetime.timezone(datetime.timedelta(hours=-6))).isoformat(timespec='seconds')
folder=site/'registros';folder.mkdir(exist_ok=True)
manifest={'schemaVersion':1,'database':'db_test','capturedAt':snapshot,'source':'MySQL · copia anonimizada de todos los registros','totalRows':sum(counts.values()),'tables':[]}
for t in dataset['tables']:
    name=t['name'];assert len(rows[name])==counts[name]
    columns=[c['column'] for c in schema if c['table']==name]
    masked=sorted(mask.get(name,set()))
    for row in rows[name]:
        for col in masked:
            v=row[col]
            if v is None:continue
            if col=='email':assert v==f"usuario-{row['id']}@ejemplo.invalid"
            elif col=='nickname':assert v==f"usuario-{row['id']}"
            elif col=='password':assert v=='[OCULTO]'
            else:assert v=='[ANONIMIZADO]'
    document={'table':name,'columns':columns,'maskedColumns':masked,'capturedAt':snapshot,'rows':rows[name]}
    (folder/(name+'.json')).write_text(json.dumps(document,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
    manifest['tables'].append({'name':name,'totalRows':counts[name],'maskedColumns':masked,'file':name+'.json'})
(folder/'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'tablas':len(counts),'registros':sum(counts.values()),'por_tabla':counts,'captura':snapshot},ensure_ascii=True))
