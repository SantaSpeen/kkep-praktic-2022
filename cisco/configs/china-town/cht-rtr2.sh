en
	er s
	del vlan.dat

	conf t

		ip cef
		no ipv6 cef

		vl 22 
			na "Native VLAN"
		vl 44
			na "Managment VLAN"
		vl 220
			na "VLAN1 China town"
		vl 221
			na "VLAN2 China town"

		lin c 0
			exe 0 0
			pass pass
			login

		lin v 0 15
			exe 0 0
			pass cisco
			login local
			t i s

		int gi0/0
			ip addr 172.18.79.5 255.255.255.252

		int r gi0/0-1
			no sh
			sw m t
			exit
			
		h cht-rtr2
		ip domain n cht-rtr2
		ena s cisco
		ser p 
		ba m "Hello from cht-rtr2!"

		cr k g r
		1024

		ip s v 2
		u admin s admin

		do wr
		do rel

