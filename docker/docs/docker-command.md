```
docker tag local-image:tagname new-repo:tagname
docker push new-repo:tagname
```

Docker commands
To push a new tag to this repository,
```
docker push cmajda/trask-k8s:tagname
```

spustit kontainer
-ti - interaktivně 
```
docker run -ti ubuntu bash
```
docker vytvoření image:
```
docker build -t docker-simple:1.0.1 .
```

 Docker Login command
```
docker login --username cmajda
```

scan
Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them
```
docker scan docker-simple:1.0.1
```
seznam images 
```
docker images
```

docker spustení image:
```
docker run -ti -p 8800:80 docker-simple:1.0.1
```
kontrola na adrese
http://localhost:8800/

s pojmenováním kontejneru
```
docker run --name docker-simple -ti -p 8800:80 docker-simple:1.0.1
```

```
docker -ps zobrazí bežící kontejnery
docker -ps -a zobrazí všechny kontejnery
docker rm docker-simple - CONTAINER ID nebo NAMES
docker ps --filter name=docker
```

--rm odstraní kontejner po jeho ukončení
```
docker run --name docker-simple -ti --rm -p 8800:80 docker-simple:1.0.1
```
docker spustení image na pozadí:
```
docker run --name docker-simple -ti --rm -d  -p 8800:80 docker-simple:1.0.1
```

logy
```
docker logs -f docker-simple
```

prozkoumání kontejneru
```
docker exec -ti docker-simple sh
```
pokusy
```
hostname
 cd /usr/share/nginx/html/
 ls -l
 cat index.html
 ps
 ls -la /
 uname -a
 cat /etc/*release
 ```

 .dockerignore
 pro muj případ. Soubor na stejné urovni jako Dockerfile
 ```
  *.sh
  Dockerfile
  ```
  nebo příklad
 ```
 .git
.cache
**/*.class
*.md
!README.md
*.sh
Dockerfile
 ```
 znovu build
```
 docker build -t docker-simple:1.0.2 .
 ```
 ```
docker run --name docker-simple -ti --rm -d  -p 8800:80 docker-simple:1.0.2
docker exec -ti docker-simple sh
 ```
 ```
cd /usr/share/nginx/html/
ls
 ```
vysledek
 ```
50x.html    index.html
 ```
http://localhost:8800/

[Example article](https://medium.com/myriatek/using-docker-to-run-a-simple-nginx-server-75a48d74500b)

11:40

*hledaní*  
`docker images|grep simple`
```
docker-simple       1.0.2          9760c85251fb   11 hours ago   22.8MB
docker-simple       1.0.1          7e956e990bb5   12 hours ago   22.8MB
```
pročištění images s tagem <none> 
```
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
```
# Build a vrstvy