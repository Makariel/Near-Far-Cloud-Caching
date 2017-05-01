import os

p = os.path.abspath("")
processedFile = 'fullcode.m'
filenames = ['client.m', 'proxy.m', 'datacenter.m', 'edge.m', 'graph.m', 'run.m', 'vertex.m', 'cache.m', 'experiments.m']

print '\n - - - - |Concatinating files| - - - - \n'

with open(p + '/' + processedFile, 'w') as outfile:
    for fname in filenames:
      
        with open(fname) as infile:
	  
	    lines = infile.readlines()
	    last = lines[-1]
	    
	    for line in lines:
	      
	    # Last line 
	      if line is last:
		  outfile.write(line + '\n\n')
		 
            # Other lines
	      else:
		   outfile.write(line) 
		   
command = 'ec ' + processedFile  
os.system(command)

print '\n Code has been succesfully compiled \n'
