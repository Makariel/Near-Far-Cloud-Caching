const Role <- class Role

      export operation startRole
      end startRole

      export operation createCache
      end createCache

      export operation setPointer[pointer: Role]
      end setPointer

      export operation getCache -> [ret: Cache]
      end getCache

      export operation expandVertex[location: Node, targetVertex: Vertex, mode: String] -> [ret: Vertex]
      end expandVertex


end Role

const Run <- object Run
   
    % Polymorphism or typeobjects?

    var p: Role <- NIL 
    var c: Role <- NIL
    var dc: Role <- NIL 

    var serverLocation: Node <-  (locate self) 
    var clientLocation: Node <- NIL
    var proxyLocation: Node <-  NIL

   	var there: Node
   	var all: NodeList 
   	var maxNodes: Integer

	process
         
	  all <- serverLocation.getActiveNodes
 
    p <- Proxy.create
    c <- Client.create

    dc <- DataCenter.create

    maxNodes <- (all.upperBound + 1)	

	   for index: Integer <- 1 while (index < maxNodes) by index <- index + 1  
		  	        there <- all[index]$theNode    						                     
	   end for
           
             fix c at all[1]$theNode

             fix p at all[2]$theNode
              	      					
             clientLocation <- (locate c)                     
             proxyLocation <- (locate p)

          
              dc.startRole  
              p.setPointer[dc]
              p.startRole 
              c.setPointer[p]
              c.startRole

	        loop
                   	          
          end loop
	         
	end process

end Run