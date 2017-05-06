How to run
------------------------------------

1. Open three bash terminals in Linux
2. Connect each terminal to Planetlab by the use of "ssh -l [slice name] [Planetlab node address]"
3. Compile our code by invoking the python script "compile.py" -> "python compile.py"
4. Start the Planetlab nodes and rename the terminal according to the role being described on the left side of |:
   ----------------------------------------------------------------------
   Client|emx -R
   Proxy|emx -R[hostname]:[port number]
   DataCenter|emx -R[hostname]:[port number] [executable emerald program]
   ----------------------------------------------------------------------
5. Choose a number between 1 and 7 as being instructed in the menu of the data center role node.