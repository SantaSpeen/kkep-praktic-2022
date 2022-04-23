en
	er s							# erase startup-config
	del vlan.dat					# delete vlan.dat
	conf t							# configure terminal

		vl 22 						# vlan <vl№>
			na "Native VLAN"		# name <name>
		vl 44
			na "Managment VLAN"

		vl 220
			na "VLAN1 China town"
		vl 221
			na "VLAN2 China town"
		vl 222
			na "VLAN3 Sexshop"
		vl 223
			na "VLAN4 Bezruk steet"
		vl 224
			na "VLAN5 Bezruk steet"
		vl 225
			na "VLAN6 Kazahstan"
		vl 226
			na "VLAN7 Kazahstan"
		vl 227
			na "VLAN8 Kazahstan"
		vl 228
			na "VLAN9 Sysadmin central"
		vl 229
			na "VLAN10 Sysadmin central"

		lin c 0						# line console 0
			exe 0 0					# exec-timeout 0 0
			pass pass				# password <passwd>
			login

		lin v 0 15					# line vty 0 15
			exe 0 0					# exec-timeout 0 0
			pass cisco				# password <passwd>
			login local				# login local
			t i s					# transport input ssh
			exit

		h <name>					# hostname <name>
		ip domain n <name>			# ip domain name <name>
		ena s cisco					# enable secret <password>

		ser p 						# service password-encryption
		ba m <MOTD>					# banner motd <MOTD>

		cr k g r					# crypto key generate rsa
		1024

		ip s v 2					# ip ssh version 2
		u admin s admin				# username admin secret admin

		do wr						# do write
		do rel						# do reload

