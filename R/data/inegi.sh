#!/bin/bash
curl 'http://www3.inegi.org.mx/lib/exporta/Exporta.aspx' -H 'Pragma: no-cache' -H 'Origin: http://www.inegi.org.mx' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.8,es-419;q=0.6,es;q=0.4' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/27.0.1453.94 Safari/537.36' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Cache-Control: no-cache' -H 'Referer: http://www.inegi.org.mx/lib/olap/consulta/general_ver4/MDXQueryDatos.asp?' -H 'Cookie: ASP.NET_SessionId=3j2rinffb4rbcxzr4ze2xeqj; Estados_cuadro=; LBSesID=ffffffff09911c0d45525d5f4f58455e445a4a423660' -H 'Connection: keep-alive' -H 'Save-Data: on' --data 'nomdimfila=A%F1o+de+registro%7CEnt+y+mun+de+ocurrencia&to_display=&cube=Mortalidad+por+homicidios&cubeName=Mortalidad+por+homicidios&nomdimColumna=Mes+de+registro&Lc_tituloFiltro=Consulta+de%3A+Defunciones+por+homicidio+%A0+Por%3A+A%F1o+de+registro+y+Ent+y+mun+de+ocurrencia+%A0+Seg%FAn%3A+Mes+de+registro&Lc_encabeza=%5C%5CTotal%5CEnero%5CFebrero%5CMarzo%5CAbril%5CMayo%5CJunio%5CJulio%5CAgosto%5CSeptiembre%5COctubre%5CNoviembre%5CDiciembre%5C&Lc_unidadmedida=&Lc_sql=select+NON+EMPTY+ToggleDrillState%28%7B%5BMes+de+registro%5D.%5BMes+de+registro%5D.%5BTotal%5D%7D%2C%7B%5BMes+de+registro%5D.%5BMes+de+registro%5D.%5BTotal%5D%7D%29+on+columns%2C+NON+EMPTY+ToggleDrillState%28crossjoin%28%7B%5BA%F1o+de+registro%5D.levels%280%29.allmembers%7D%2C+%7B%5BEnt+y+mun+de+ocurrencia%5D.%5BEnt+y+mun+de+ocurrencia%5D.%5BTotal%5D%7D%29%2C%7B%5BEnt+y+mun+de+ocurrencia%5D.%5BEnt+y+mun+de+ocurrencia%5D.%5BTotal%5D%7D%29+on+rows+from+%5BMortalidad+por+homicidios%5D+where+%28%5BMeasures%5D.%5BDefunciones+por+homicidio%5D%29&Lc_conexion=provider%3DMSOLAP.3%3BMDX+Compatibility%3D2%3Bdata+source%3D10.1.36.12%3BConnect+timeout%3D120%3BInitial+catalog%3DMORTALIDAD_GENERAL&Lc_titulo=Defunciones+por+homicidios%7C&Lc_piepagina=FUENTE%3A+INEGI.+Estad%EDsticas+de+mortalidad.&Lc_salida=0&Lc_StrConexion=1&Lc_formato=Texto+separado+por+comas%28.csv%29&Lc_sql_allmembers=select+NON+EMPTY+ToggleDrillState%28%7B%5BMes+de+registro%5D.%5BMes+de+registro%5D.%5BTotal%5D%7D%2C%7B%5BMes+de+registro%5D.%5BMes+de+registro%5D.%5BTotal%5D%7D%29+on+columns%2C+NON+EMPTY+ToggleDrillState%28crossjoin%28%7B%5BA%F1o+de+registro%5D.levels%280%29.allmembers%7D%2C+%7B%5BEnt+y+mun+de+ocurrencia%5D.%5BEnt+y+mun+de+ocurrencia%5D.%5BTotal%5D%7D%29%2C%7B%5BEnt+y+mun+de+ocurrencia%5D.%5BEnt+y+mun+de+ocurrencia%5D.%5BTotal%5D%7D%29+on+rows+from+%5BMortalidad+por+homicidios%5D+where+%28%5BMeasures%5D.%5BDefunciones+por+homicidio%5D%29&Lc_ValidaDimGeo=0&completo=completo&Cant_Col=13&Cant_Fil=881' --compressed>INEGI_exporta.csv
