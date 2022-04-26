en
	conf t

		vl 22 
			na "Native VLAN"
		vl 44
			na "Managment VLAN"

		vl 220
			na "VLAN1 China town"
		vl 221
			na "VLAN2 China town"
		vl 222
			na "VLAN3 Imsit"
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

		lin c 0
			exe 0 0
			pass pass
			login

		lin v 0 15
			exe 0 0
			pass cisco
			login local
			t i s

		int se0/3/0
			ip addr 172.18.79.9 255.255.255.252

		int se0/3/1
			ip addr 172.18.79.30 255.255.255.252

		int r se0/3/0

		int gi0/0
			ip addr 172.18.79.6 255.255.255.252

		int gi0/1
			ip addr 172.17.79.2 255.255.255.252

		int r gi0/0-1
			no sh
			sw m t
			sw t n vl 22
			exit

		h cht-rtr
		ip domain n cht-rtr
		ena s cisco
		ser p 
		ba m "Hello from cht-isp!"

		cr k g r
		1024

		ip s v 2
		u admin s admin

		do wr
		do rel

