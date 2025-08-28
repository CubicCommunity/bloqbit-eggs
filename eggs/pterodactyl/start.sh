if [[ -d .git ]] && [[ ${AUTO_UPDATE} == "1" ]]; then git pull; fi;
if [ -f /home/container/package.json ]; then /usr/local/bin/npm install; fi;
/usr/local/bin/npm start;