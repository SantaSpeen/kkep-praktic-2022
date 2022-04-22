en
	conf t
		hostname <name>
		en secret cisco
		ip domain name sex-sw-<№>

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
			login
			transport input ssh
			exit

		service password-encryption
		banner motd "Sexshop <№> switch"

		crypto key generate rsa

		<input 1024>

		ip ssh ver 2
		username admin secret line

		exit
	exit

write
exit
