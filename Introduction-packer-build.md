# Packer Linux Overview
<pre>
  Introduction
In this short post, you will learn:

What a virtual machine image is and when you would use a machine image

Packer vs Docker

Learn how to build a virtual machine image using Packer.

Prerequisites
Install Packer if you want to follow along with the examples. You can see instructions on how to do that here .

Install Docker and create an account on Docker hub if you want to push the final built image to your Docker registry repository.

What is a machine image
A virtual machine image is a template for creating virtual machine instances. This is useful when you want to automate the building of identical machine images that will run across multiple platforms.

Packer vs Docker
Packer is an automated build system for building images for containers and virtual machines. An image created using Packer can be used to run instances on multiple platforms including DigitalOcean Docker and Amazon EC2. Packer uses system configuration tools called "Provisioners" which gives more flexibility to customise the image.

Docker is a system for building Docker images, shipping and run Docker containers. Docker images are built in layers that can be cached. Layer caching makes for faster builds. Packer does not have this feature.

Building an image using Packer
Packer uses builders, provisioners and post-processors as the main configuration attributes or blocks which are defined in a Packer template. Let's go through a practical example to explain the concepts.

An example of a Packer template -  docker-ubuntu.pkr.hcl 

text

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "ubuntu" {
  image  = "ubuntu:xenial"
  commit = true
}

build {
  name    = "docker-example"
  sources = [
    "source.docker.ubuntu"
  ],
  provisioner "shell" {
    environment_vars = [
      "FOO=hello world",
    ]
    inline = [
      "echo Installing Redis",
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y redis-server",
      "echo \"FOO is $FOO\" > example.txt",
    ]
  }

   post-processors {
    post-processor "docker-tag" {
        repository =  "your-repo/demo"
        tag = ["0.6"]
      }
    post-processor "docker-push" {}
  }
}
Notes

The  packer  block contains Packer settings, including in this case the required plugin for this image.

The  source  block defines the builder plugin i.e.  "ubuntu:zenial"  which will be invoked by the build block. You will notice that this block includes two labels, the builder type docker and builder name ubuntu.

Finally the  build  block defines the tasks that eventually produces an image. The build block

 sources  -references the  source.docker.ubuntu  source defined earlier within the sources block. During build time, Packer will pull the ubuntu:xenial image from the docker registry.

 provisioner  - a provisioner is used to automate the modification of the image . Provisioners are run against an instance of the image. In this case, a Docker container (an instance) will be started and the provisioner will install the redis-server and create a file called example.txt.

 post-processors  - post-processors only run after the instance has been saved as an image. In this example, the post-processors will be run sequentially to tag the image and push it to a repository. Post-processors are varied in their function and can for example be used to compress an artefact or push it to the cloud.

In addition to the above, Packer supports parallel builds and the use of variables.

Parallel builds is a powerful feature that allows for the creation multiple images in parallel.

Input variables enable use input variables to serve as parameters for a Packer build.

Try it out
Check the prerequisites section for the requirements.

Run Packer to build and push your Docker image to the registry.

text

$ packer init .
$ packer build .

>>output
packer-advantch-demo.docker.ubuntu: output will be in this color.

==> packer-advantch-demo.docker.ubuntu: Creating a temporary directory for sharing data...
==> packer-advantch-demo.docker.ubuntu: Pulling Docker image: ubuntu:xenial
    packer-advantch-demo.docker.ubuntu: xenial: Pulling from library/ubuntu
    packer-advantch-demo.docker.ubuntu: Digest: sha256:454054f5bbd571b088db25b662099c6c7b3f0cb78536a2077d54adc48f00cd68
Notes

 packer init  - initialize your configuration.

 packer build  - build the container and push it to the registry

Conclusion
In this post, you learnt how to leverage Packer to automate the building of machine & container images across multiple environments.
</pre>
