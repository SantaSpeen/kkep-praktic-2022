en
	er s
	del vlan.dat

	conf t

		vl 22 
			na "Native VLAN"
		vl 44
			na "Managment VLAN"

		vl 220
			na "VLAN1 Gay"
		vl 221
			na "VLAN2 Gay"
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
			sw trank native vl 22
			channel-group 2 mode on
			exit

		h gay-sw-main
		ip domain n gay-sw-main
		ena s cisco
		ser p 
		ba m "Hello from gay-sw-main!"

		cr k g r
		1024

		ip s v 2
		u admin s admin

		do wr
		do rel

