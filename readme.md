How to run on local computer
--------------------------------------------------------------------------------------------------------------------------------------

1. Open three bash terminals in Linux.
2. Name them according to the roles of the system: Client, Proxy and Data Center.
3. Compile our source code by the calling our python script -> "python compile.py". This will generate our final codebase "fullcode.m".
4. Call "Emx -R" on the Client terminal. This should also give you a port number on the screen.
5. Call "Emx -R[hostname][Client Port Number]" on the Proxy terminal.
6. Call "Emx -R[hostname][Client Port Number] fullcode.x" on the Data Center terminal.
7. Interact with shell according to menu. Note that you have to restart the program per iteration.



How to run distributed on Planetlab
--------------------------------------------------------------------------------------------------------------------------------------
1. Open three bash terminals in Linux. 
2. Name them according to the roles of the system: Client, Proxy and Data Center.
3. Connect each terminal to Planetlab by the use of "ssh -l [slice name] [Planetlab node address]".
4. Compile our source code by the calling our python script -> "python compile.py". This will generate our final codebase "fullcode.m".
5. Call "Emx -U -R" on the Client terminal. This should also give you a port number on the screen.
6. Call "Emx -U -R[hostname][Client Port Number]" on the Proxy terminal.
7. Call "Emx -U -R[hostname][Client Port Number] fullcode.x" on the Data Center terminal.
8. Interact with shell according to menu. Note that you have to restart the program per iteration.

Note that on the client-server caching option, the proxy terminal should be connected to the distant node, as there are only two active nodes.
