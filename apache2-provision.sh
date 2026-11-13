#!/bin/bash
set -ex

# Copiar ficheros de configuración de apache2 que incluyen:
#
# - apache2.conf,(lo ignoramos)
# - apolo.olimpo.test.conf
# - atenea.olimpo.test.conf
#
cp /vagrant/files/apolo.olimpo.test/apolo.olimpo.test.conf /etc/apache2/sites-available/
cp /vagrant/files/atenea.olimpo.test/atenea.olimpo.test.conf /etc/apache2/sites-available/
#
# Habilitar los servidores virtuales
#
a2ensite apolo.olimpo.test.conf
a2ensite atenea.olimpo.test.conf
#
# Reiniciar el servicio 
#
systemctl restart apache2
