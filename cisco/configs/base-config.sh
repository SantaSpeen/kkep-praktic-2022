en
	conf t
		hostname <name>
		ip domain name <name>
		en secret cisco

		line con 0
			no sh
			exec-timeout 0 0
			password pass
			login
			transport input ssh 
			exit

		line vty 0 15
			no sh
			exec-timeout 0 0
			password cisco
			login local
			transport input ssh
			exit

		service password-encryption
		banner motd <motd>

		crypto key generate rsa
		1024

		ip ssh ver 2
		username admin secret admin

		exit
	exit

write
exit
