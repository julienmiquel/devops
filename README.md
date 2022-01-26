# devops
Terraform script to create a simple devops environment  

# init
install cluster on multiple project all components and recreate them

Change following with the name of your projects in build.sh

```
array=( projet-1 projet-2 projet-3 ) 
```

launch to install cluster in your projects
```
./build.sh
```


# Destroy resources
Change following with the name of your projects in shutdown.sh

```
array=( projet-1 projet-2 projet-3 ) 
```

launch to destroy cluster in your projects
```
./shutdown.sh
```