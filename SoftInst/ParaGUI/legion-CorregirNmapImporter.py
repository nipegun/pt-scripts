#!/usr/bin/env python3

import sys

def main(file_path):
  with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

  old_block = '''for scr in p.getScripts():
  db_script = session.query(l1ScriptObj).filter_by(scriptId=scr.scriptId) \\
                 .filter_by(portId=db_port.id).first()

  if not scr.output == '' and scr.output != None:
    db_script.output = scr.output

  session.add(db_script)
  session.commit()'''

  new_block = '''for scr in p.getScripts():
  db_script = session.query(l1ScriptObj).filter_by(scriptId=scr.scriptId) \\
                 .filter_by(portId=db_port.id).first()
  if db_script:
    if scr.output not in ('', None):
      db_script.output = scr.output
    session.add(db_script)
    session.commit()
  else:
    t_l1ScriptObj = l1ScriptObj(scr.scriptId, scr.output, db_port.id, db_host.id)
    session.add(t_l1ScriptObj)
    session.commit()'''

  if old_block in content:
    new_content = content.replace(old_block, new_block)
    with open(file_path, 'w', encoding='utf-8') as f:
      f.write(new_content)
    print("Reemplazo realizado correctamente.")
  else:
    print("No se encontró el bloque en el archivo.")

if __name__ == '__main__':
  if len(sys.argv) != 2:
    print("Uso: python replace_script.py <ruta_al_archivo>")
    sys.exit(1)
  main(sys.argv[1])
