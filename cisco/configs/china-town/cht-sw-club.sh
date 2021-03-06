en
	conf t
		vl 22 
			na "Native VLAN"
		vl 44
			na "Managment VLAN"
			ip addr 172.18.72.1 255.255.255.0
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
				
		int r f0/10-11
			no sh 
			sw m a
			sw a vl 220

		int r fa0/12-13
			no sh 
			sw m a
			sw a vl 221

		int r fa0/1-2
			no sh
			sw m trank
			channel-group 2 mode on
			exit

		h cht-sw-club
		ip domain n cht-sw-club
		ena s cisco
		ser p 
		ba m "Hello from cht-sw-club!"

		cr k g r
		1024

		ip s v 2
		u admin s admin

		ip def 

		do wr
		do rel

