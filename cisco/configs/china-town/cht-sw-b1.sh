en
	conf t

		vl 22 
			na "Native VLAN"
		vl 44
			na "Managment VLAN"
			ip addr 172.18.72.2 255.255.255.0
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

		int r fa0/2-3
			channel-group 1 mode on

		int p 1
			sw m t

		int r fa0/1-4
			no sh
			sw m t
			exit

		h cht-sw-b1
		ip domain n cht-sw-b1
		ena s cisco
		ser p 
		ba m "Hello from cht-sw-b1!"

		cr k g r
		1024

		ip s v 2
		u admin s admin

		do wr
		do rel

