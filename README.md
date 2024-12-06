# NYU Go Server
A Dockerized go server for serving eBook web pub manifests.  
Based on the Readium go-toolkit.  
Served from AWS EC2.  

## Test the NYU-Go-Server Locally
Here are the steps to test the go-server to make sure it is working correctly before adding it to a Docker container.

Clone nyu-go-server from GitHub  
Add books for testing to the nyu-go-server/test directory  
'Make' the project and 'install' it for local execution.

```
git clone https://github.com/BluefireProductions/nyu-go-server.git --recursive
cd nyu-go-server
go mod tidy
make install

//build the binary in the local 'go/bin' directory
cd cmd/rwp
go install 
cd ../..
rwp serve test

//test in a local web browser
http://localhost:15080/list.json
http://localhost:15080/OTc4MTQ3OTgxOTQ5Mi5lcHVi/manifest.json
http://localhost:9000/OTc4MTQ3OTgxOTQ1NC5lcHVi/manifest.json
```

## Test Dockerfile Locally
Add links to eBooks to include in the Docker container.
Dockerfile:

```
ADD --chown=nonroot:nonroot https://bluefireproductions.github.io/jisu-epubs/9781479819454.epub /srv/publications/
ADD --chown=nonroot:nonroot https://bluefireproductions.github.io/jisu-epubs/9781479819492.epub /srv/publications/
```

Test that docker is installed, build and run locally.
From the nyu-go-server directory:

```
docker info
docker build -t nyu-go-server:latest .
docker run -e PORT=15080 -p 9000:15080 nyu-go-server:latest
http://localhost:9000/list.json
http://localhost:9000/OTc4MTQ3OTgxOTQ5Mi5lcHVi/manifest.json
http://localhost:9000/OTc4MTQ3OTgxOTQ1NC5lcHVi/manifest.json
```

## SSH into NYU JISU EC2 Server

```
ssh -i ~/dlts-aws-jisu.pem ec2-user@18.205.45.14
```

## Build the Docker image on EC2
Clone the nyu-go-server, build and run it

```
git clone https://github.com/BluefireProductions/nyu-go-server.git --recursive
cd nyu-go-server

//build the image
cd nyu-go-server
docker build -t jisu:latest .

//run the server
docker run -e PORT=15080 -d -p 8080:15080 jisu:latest

//test the server
http://18.205.45.14:8080/list.json
http://18.205.45.14:8080/OTc4MTQ3OTgxOTQ1NC5lcHVi/manifest.json
```

## Login, Push and Pull from ECR

```
//list the images
docker image list

//tag the image
docker tag jisu:latest 395362471827.dkr.ecr.us-east-1.amazonaws.com/jisu:latest

//login to ecr
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 395362471827.dkr.ecr.us-east-1.amazonaws.com 

//push the image to ECR
docker push 395362471827.dkr.ecr.us-east-1.amazonaws.com/jisu:latest
```

## Other Docker Commands

```
//show running containers
docker ps -a

//stop a running container
docker stop id_or_name

//delete a container
docker rm id_or_name

//list images
docker image list
docker images

//delete an image
docker rmi -f id_or_tag
```


