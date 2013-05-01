#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# 2013 - Autor Luis Carlos Otte Junior
#
# Simples exemplo de monitoramento de um roteador dlink, onde conecto 
# com a biblioteca requests e rodo um parser no html procurando macs 
# diferentes e aviso na barra de notificacao do SO Linux
#
# Requiriments:
# requests, BeatifulSoup e pynotify
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

import requests
from BeautifulSoup import BeautifulSoup
import sys
import pynotify


meumac = "0C-60-76-2F-34-B7"
host = "http://192.168.2.1/wlcl.htm"
username = "admin"
password = "blablabla"

r = requests.get(host, auth=(username,password))
parse = r.text
soup = BeautifulSoup(parse)
tabela = soup.form.table

linha = 0

if __name__ == "__main__":
    if not pynotify.init("icon-summary-body"):
        sys.exit(1)

for row in tabela.findAll('tr'):
        if linha > 0:
                dados = row.findAll('td')
                data = dados[0].text
                mac = dados[1].text
                if (meumac != mac):
                        n = pynotify.Notification("Desconhecido conectando ...", data + " " + mac)
                        n.show()
        linha += 1
