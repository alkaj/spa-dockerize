# Description
  This package creates an NGINX based Docker container serving a SPA App with prerendering powered by the public RENDERTRON server(you can change that of course) and some basic caching settings.
    
    
# How to use ?

### 1. Install
You can use npm  
  
``` npm install spa-dockerizer ```  
  
Doing so should create a `Dockerfile` and a `.dockerignore` at the root of your project, feel free to edit the ```.dockerignore``` to fit the Docker context you want to send, the NGINX server has some basic caching settings and the public Rendertron server as prerenderer but you can also edit the ```Dockerfile``` to fine-tune them.
  
If you don't feel like using npm, just download the zip tarball from this page, unzip it and copy the ```Dockerfile``` and ```.dockerignore``` into the root of your project, then edit them at your convenience.  
  
### 2. Build the image
build the docker image  
  
``` docker build -t my-spa-app-image --build-arg BUILD_OUTPUT=/path/to/build/output . ```  
  
### 3. Run it locally  
Run the image locally to test your site  
  
``` docker run -p 8080:80 -d  my-spa-app-image ```  
  
Then visit ``` localhost:8080 ``` from your browser to make sure it works.  

### 4. Push  
Push it to any registry for deployment  
  
### 5. Notes
  
* The container exposes port ``` 80 ```  
* You can change the prerenderer by editing the Dockerfile and providing another **Rendertron** instance url.
