# Docker Workflow with Wordpress

## Workflow

Basically, this workflow performs the basic operations to manage your Wordpress application using Git as SCM. You just have to copy these files in the root folder of your Wordpress project, and the workflow will be available.

The actions you can do with this workflow are:

- Execute `run-docker.sh` to start a container on `port 80`.
- Execute `publish.sh [all|staging|production]` to publish to your live environments.

How do we publish to the live environments? Using [git-ftp](https://github.com/git-ftp/git-ftp), which is super cool for dealing with traditional, old-school operations on hosting servers using FTP. With this tool we can use Git to send only the required files by FTP, not all-or-nothing.

The workflow has to configure two remote sites with `git-ftp`, with names `staging` and `production`. Please read about how to configure them at project's repository.

To set up your workflow, **it's mandatory** to write down your custom values in a `.workflow.properties` file at the root directory of your Wordpress project.

    There is a sample file for this configuration, named `.workflow-sample.properties`.

## Git Branches

It's **mandatory** to have these three local branches to use this workflow:

- `dev`: where you create new features.
- `staging`: this branch will be pushed to your Staging environment.
- `master`: this branch will be pushed to your Production environment.

The workflow will move commits from `dev` to `staging` and to `master`, respectively when publishing to the proper environment.

    A git tag will be created when publishing to production, using as tag name the value defined in the file blog-version.txt. So keep that file up-to-date!

## Environments

It's **mandatory** to have three environments:

 - `Local`: a dockerised environment for testing locally. It will package the Wordpress application into a Docker container, following the LAMP stack. You can find the Docker image representing this environment [here](https://hub.docker.com/r/mdelapenya/lamp). You can find the code [here](https://github.com/mdelapenya/lamp).
 - `Staging`: a live environment for testing the Wordpress application before publishing to production. You can push your code here and review your changes. This workflow uses `dev` as subdomain.
 - `Production`: the live environment for the Wordpress application.

I.e.:

- local: http://localhost
- staging: http://dev.my-wordpress.com
- production: http://www.my-wordpress.com

## Files

### Versioning your project

Set the version of your Wordpress application in the `blog-version.txt` file. It will be used to create `git tags` for your project.

### Configuring Database (mysql-setup)

    This script is executed on build time of the Docker image.

This script initialises the database in the MySQL server that is bundled into the LAMP image.

You have to configure it with your database name, your database user, and its password.

### Updating Wordpress URLs (change-wp-url)

    This script is executed on build time of the Docker image.

As Wordpress hardcodes its URL in the database (WTF!), this script replaces all those ocurrences and applies the DNS name of the Wordpress environment.

It accepts one parameter, representing the environment where to apply the DNS name.

- `local`: it will apply `localhost` as URL for the environment, so it can be executed inside the Docker container.
- `staging`: it will prepend the `dev.` subdomain to the DNS, so it's important to understand that it's mandatory to have th
- `Any other value`: it will use the real DNS name, so all URL will be replaced with the real ones.

You have to configure it with your database name, and the DNS name of your Wordpress, without `www`, i.e. `mdelapenya.org`.

NOTE: please make sure that the real paths for the environments match with your hosting provider, including subdomains. In my case, I use [Interdominios](www.interdominios.com), which uses `/var/www/vhosts/mdelapenya.org\` for environments, and `` for subdomains.

### Running Docker container (run-docker)

    This script is executed every time we want to recreate the container.

It builds the image based on the current Dockerfile, copying your Wordpress installation to the Docker image. Then it `removes` the already existing container (`Cattle, not Pets`), and runs a new instance of the image, applying one volume for the `wp-content` folder.

    You have to configure it with your DockerHub user, the name of the Docker image, the name of the Docker container you want to use, and the name of the Wordpress theme you are using, just in case you need it. Please see the .workflow-sample.properties file.

## Publishing (publish)

This script publish your Wordpress to the environment you specify.

It accepts only one parameter, with following values:

- `all`: push your Wordpress to both staging and production
- `stating`: push your Wordpress to staging
- `production`: push your Wordpress to production