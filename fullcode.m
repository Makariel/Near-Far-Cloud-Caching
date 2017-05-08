const Client <- Class Client(Role)

  var activated: Boolean <- false
  var flagType: String
  var proxyConnection: Proxy <- NIL
  var proxyLocation: Node <- NIL
  var localCache: Cache <- NIL

  process
                  

                  loop
                           exit when activated
                  end loop

                  (locate self)$stdout.putString["\n\n [NODE ONLINE]             CLIENT            [NODE ONLINE] \n\n"]

                  loop
                            (locate self)$stdout.putString["\n [Proxy is currently building its cache: Patience is a virtue] \n"]
                            exit when (proxyConnection.proxy_isCacheReady == true)
                  end loop

                 (locate self)$stdout.putString["\n * * * * Cache has been successfully constructed at the node [" || (locate proxyConnection)$name || "] * * * * \n"]

                 self.createCache[25]            

  end process

  export operation startRole[flag: String]
         activated <- true
         flagType <- flag
  end startRole

  export operation createCache[size: Integer]

         var clientCachingAlgorithm: CacheAlgorithm <- DFSCaching.create
         localCache <- Cache.create[size, clientCachingAlgorithm, proxyConnection]
         localCache.cache_commenceCaching

         localCache.cache_getData.graph_resetRecursionVariables       
         var proxyCounter: Integer <- proxyConnection.proxy_getProxyInvocations
         var dataCenterCounter: Integer <- proxyConnection.proxy_getDataCenterInvocations
         
  end createCache

  export operation getCache -> [ret: Cache]
         ret <- localCache
  end getCache

  export operation expandVertex[location: Node, targetVertex: Vertex, mode: String] -> [ret: Vertex]
         ret <- NIL
  end expandVertex

  export operation setPointer[pointer: Role]
         var widenedObject: Proxy <- view pointer as Proxy
         proxyConnection <- widenedObject
  end setPointer

  export function client_getProxyConnection -> [ret: Proxy]
         ret <- proxyConnection 
  end client_getProxyConnection

  export function client_getProxyLocation -> [ret: Node]
         ret <- proxyLocation
  end client_getProxyLocation

end Client


const Proxy <- Class Proxy(Role)
       
    var serverConnection: DataCenter <- NIL
    var activated: Boolean <- false
    var cacheReady: Boolean <- false
    var clientLocation: Node <- NIL
    var serverLocation: Node <- NIL
    var localCache: Cache <- NIL
    var flagType: String 

    var dataCenterInvocations: Integer <- 0
    var proxyInvocations: Integer <- 0


     process
                 

                  loop
                           exit when activated
                  end loop

                  (locate self)$stdout.putString["\n\n [NODE ONLINE]             PROXY            [NODE ONLINE] \n\n"]

                  if(flagType = "CS") then
                  	       self.createCache[5000]
                  else 

                  loop
                           (locate self)$stdout.putString["\n [Data Center is currently building its cache: Patience is a virtue] \n"]
                           exit when (serverConnection.server_isCacheReady == true)
                  end loop

                  (locate self)$stdout.putString["\n * * * * Cache has been successfully constructed at the node [" || (locate serverConnection)$name || "] * * * * \n"]

                  self.createCache[2500]

                  end if
                 
  end process 

  export operation startRole[flag: String] 
         activated <- true
         flagType <- flag
  end startRole

  export operation createCache[size: Integer]
         var proxyCachingAlgorithm: CacheAlgorithm <- DFSCaching.create
         localCache <- Cache.create[size, proxyCachingAlgorithm, serverConnection] 
         cacheReady <- true
  end createCache

  export operation getCache -> [ret: Cache]
         ret <- localCache
  end getCache

  export operation setPointer[pointer: Role]
         var widenedObject: DataCenter <- view pointer as DataCenter
         serverConnection <- widenedObject
  end setPointer 

  export operation expandVertex[location: Node, targetVertex: Vertex, mode: String] -> [ret: Vertex]

           if(targetVertex == NIL) then 
           	       (locate self)$stdout.putString["\n |||NIL DETECTED @ targetVertex||| \n"]
                   assert false
           end if

           var identifiedVertex: Vertex <- localCache.cache_getData.graph_recursiveDFS[localCache.cache_getData.graph_getRoot, targetVertex.vertex_getID, "DFS", NIL, NIL] 

           localCache.cache_getData.graph_resetRecursionVariables

           if(identifiedVertex == NIL or identifiedVertex.vertex_getID = -666) then
 
 							   (locate self)$stdout.putString["\n * * * * Client cache has outgrown that of Proxy cache * * * * \n"]
                               assert false  
                             
           else
                             

                         	 if(flagType = "CS") then

                         	 	  dataCenterInvocations <- dataCenterInvocations + 1

                         	 	  var newVertex: Vertex <- localCache.cache_getData.graph_expandVertex[identifiedVertex, "PARTIAL"]

                         	 	  if(newVertex == NIL) then 
                         	 	  	 ret <- NIL
                         	 	  	 return
                         	 	  else 
                         	 	  	     move newVertex to location
                                         ret <- newVertex  
                         	 	  end if


                         	 else 

                         	 	   proxyInvocations <- proxyInvocations + 1  
                                   var newVertex:Vertex <- localCache.cache_getData.graph_expandVertex[identifiedVertex, "FULL"]

                              	   if(newVertex == NIL)

                                then       
                                 
                                     dataCenterInvocations <- dataCenterInvocations + 1
                                                    
                                     var nextLevelVertex1: Vertex <- localCache.cache_getNextLevelCache.expandVertex[(locate self), targetVertex, "FULL"]
                                     var nextLevelVertex2: Vertex <- localCache.cache_getNextLevelCache.expandVertex[(locate self), targetVertex, "FULL"]

                                     if(nextLevelVertex2 == NIL or nextLevelVertex1 == NIL) then
                                     
                                       ret <- NIL
                                       return

                                     else  

                                                      localCache.cache_getData.graph_increaseSize[nextLevelVertex2.vertex_getAmountEdges]
                                                      nextLevelVertex2.vertex_setGraph[localCache.cache_getData]
                                                      nextLevelVertex2.vertex_setGraphChildren[localCache.cache_getData]
                                               
                                                      if(identifiedVertex.vertex_getParent !== NIL) then   
  
                                                         identifiedVertex.vertex_getParent.vertex_swapVertex[nextLevelVertex2]                                                      
                                                      end if                                                 
                                                     
                                                    move nextLevelVertex1 to location                                               
                                                    ret <- nextLevelVertex1
                                     end if                                 
                            else 

                                   move newVertex to location
                                   ret <- newVertex          
                            
                            end if  	

                        end if

                                       
                    end if
                  
  end expandVertex

    export function proxy_getServerConnection -> [ret: DataCenter]
           ret <- serverConnection
    end proxy_getServerConnection

    export function proxy_isCacheReady -> [ret: Boolean]  
           ret <- cacheReady
    end proxy_isCacheReady

    export function proxy_getDataCenterInvocations -> [ret: Integer]
           ret <- dataCenterInvocations
    end proxy_getDataCenterInvocations

    export function proxy_getProxyInvocations -> [ret: Integer]
           ret <- proxyInvocations
    end proxy_getProxyInvocations

end Proxy


const DataCenter <- Class DataCenter(Role)

    var activated: Boolean <- false
    var cacheReady: Boolean <- false
    var flagType: String
    var output: OutStream <- NIL
    var localCache: Cache <- NIL
    var proxyConnection: Proxy

    process

                 loop
                          exit when activated
                 end loop

                 (locate self)$stdout.putString["\n\n [NODE ONLINE]             DATA CENTER            [NODE ONLINE] \n\n"]

                 self.createCache[5000]
                
     end process

     export operation startRole[flag: String]
            activated <- true
            flagType <- flag
     end startRole

     export operation createCache[size: Integer]

            var datacenterCachingAlgorithm: CacheAlgorithm <- DFSCaching.create
            localCache <- Cache.create[size, datacenterCachingAlgorithm, NIL]
            cacheReady <- true
            localCache.cache_getData.graph_resetRecursionVariables
            
     end createCache

     export operation getCache -> [ret: Cache]
            ret <- localCache
     end getCache

     export operation setPointer[pointer: Role] 
            var widenedObject: Proxy <- view pointer as Proxy
            proxyConnection <- widenedObject
     end setPointer

     export operation expandVertex[location: Node, targetVertex: Vertex, mode: String] -> [ret: Vertex] 

            var identifiedVertex: Vertex <- localCache.cache_getData.graph_recursiveDFS[localCache.cache_getData.graph_getRoot, targetVertex.vertex_getID, "DFS", NIL, NIL]
            localCache.cache_getData.graph_resetRecursionVariables

            if(identifiedVertex.vertex_getID = -666) then  
                                            
                                ret <- NIL
                                return
            end if

         var newVertex: Vertex <- localCache.cache_getData.graph_expandVertex[identifiedVertex, mode]   

          if(newVertex == NIL)
                                          then                                                                           
                                               ret <- NIL
                                               return                        
                    else 
                                             

                           move newVertex to location                      
                           ret <- newVertex             

                    end if 
            
    end expandVertex

    export function server_isCacheReady -> [ret: Boolean]  
           ret <- cacheReady 
    end server_isCacheReady

end DataCenter

const Edge <- class Edge[s: Vertex, d: Vertex]

      attached var destination: Vertex <- d
      attached var source: Vertex <- s

    export operation edge_setDestination[targetVertex: Vertex]    
           destination <- targetVertex    
    end edge_setDestination

    export operation edge_getDestination -> [ret:Vertex]
           ret <- destination
    end edge_getDestination

    export operation edge_setSource[newSource: Vertex]
           source <- newSource
    end edge_setSource

    export operation edge_getSource -> [ret: Vertex]
           ret <- source
    end edge_getSource
                                       
end Edge

const Graph <- Class Graph
       
       var maxRadius: Integer <- 0
       var graphSize: Integer <- 0
       var originalGraphSize: Integer <- 0
       var rootVertex: Vertex <- NIL   
       var finished: Boolean <- false
       var visitedCounter: Integer <- 0
       var clientPointer: Client <- NIL
       var out: OutStream <- NIL 

    export operation graph_incrementSize
           graphSize <- graphSize + 1
    end graph_incrementSize

    export operation graph_increaseSize[n: Integer]
           graphSize <- graphSize + n
    end graph_increaseSize

    export operation graph_setRoot[v: Vertex]
           rootVertex <- v
    end graph_setRoot

    export operation graph_setRadius[newRadius: Integer]
           maxRadius <- newRadius
    end graph_setRadius

    export operation graph_setOriginalGraphSize[n: Integer]
           originalGraphSize <- n
    end graph_setOriginalGraphSize

    export operation graph_setClientPointer[c : Client]
           clientPointer <- c
    end graph_setClientPointer

    export operation graph_initializeOutStream
           out <- OutStream.toUnix["cache_hit_time_spain.dat", "w"]
    end graph_initializeOutStream

    export operation graph_closeOutStream
           out.close
    end graph_closeOutStream

    export function graph_getSize -> [ret: Integer]   
           ret <- graphSize
    end graph_getSize

    export function graph_getRoot -> [ret: Vertex]    
           ret <- rootVertex
    end graph_getRoot

    export function graph_getOriginalGraphSize -> [ret: Integer]
           ret <- originalGraphSize
    end graph_getOriginalGraphSize

    export function graph_getRadius -> [ret: Integer]
           ret <- maxRadius
    end graph_getRadius

     export operation graph_resetRecursionVariables
            visitedCounter <- 0
            finished <- false
     end graph_resetRecursionVariables


export operation graph_bindEdges[root: Vertex, targetID: Integer, edges: Array.of[Edge]]

        if(root.vertex_getPaths == NIL or ( (root.vertex_getPaths.upperBound + 1) < 1) ) then              
                         root.vertex_edgesToArray
          end if
         
          if(root.vertex_getID = targetID)
                                                        then 
                                                                     
                                                                                                                                                                                                                                      
                                                                      for e in edges

                                                                                     root.vertex_addPath[e]
                                                                                     e.edge_getDestination.vertex_setParent[e.edge_getSource]                                                                                   
                                                                                                                                                                                                                            
                                                                      end for            

                                                                      finished <- true                                            
          else 
                                                      
                                                           root.vertex_visitVertex
                                                          
                                                         for e in root.vertex_getPaths

                                                                var destination: Vertex <- e.edge_getDestination

                                                                if(destination.vertex_isVisited = false) then

                                                                               self.graph_bindEdges[destination, targetID, edges]                                                                  
                                                                               destination.vertex_unvisitVertex
                                                                             
                                                                               if(finished = true) then
                                                                                  return
                                                                               end if           
                                                                   end if

                                                         end for                                                 
          end if

end graph_bindEdges


export operation graph_recursiveDFS[root: Vertex, targetID: Integer, mode: String, arr: Array.of[Edge], newVertex: Vertex] -> [ret : Vertex]
                                        
          if(root.vertex_getPaths == NIL or ( (root.vertex_getPaths.upperBound + 1) < 1) ) then              
                         root.vertex_edgesToArray
          end if
         
          if(root.vertex_getID = targetID)
                                            then 
                                            
                                                   if(mode = "DFS")

                                                                    then 

                                                                                                                                                                                                              
                                                                       finished <- true
                                                                       ret <- root
                                                                 
                                                   elseif (mode = "ADD")

                                                                         then 

                                                                              
                                                                   
                                                                      for e in arr
                                                                                     root.vertex_addPath[e]
                                                                                     graphSize <- graphSize + 1                                                                                       
                                                                                                                                                                                                                                     
                                                                      end for

                                                                     
                                                                      finished <- true
                                                                      ret <- root

                                                  elseif (mode = "REPLACE")

                                                                             then                                                                     
                                                                                        
            
                                                                                         graphSize <- graphSize + newVertex.vertex_getAmountEdges

                                                                                         newVertex.vertex_setDepth[root.vertex_getDepth]
                                                                                         newVertex.vertex_setGraph[self]
                                                                                         newVertex.vertex_setGraphChildren[self]
                                                                                         
                                                                                         if(root.vertex_getParent !== NIL) then   
                                                                                            root.vertex_getParent.vertex_swapVertex[newVertex]  
                                                                                         end if
                                                                                                                                                                             

                                                                                         finished <- true
                                                                                         ret <- root                            
                                                  end if

          elseif ( (visitedCounter + 1) = graphSize)

                                                     then  
                                                                                     
                                                           ret <- Vertex.create[-666]
                                                           finished <- true        
          else 
                                                      
                                                           root.vertex_visitVertex
                                                           visitedCounter <- visitedCounter + 1
                                                
                                                         for e in root.vertex_getPaths

                                                                var destination: Vertex <- e.edge_getDestination

                                                                if(destination.vertex_isVisited = false) then

                                                                               ret <- self.graph_recursiveDFS[destination, targetID, mode, arr, newVertex]                                                                  
                                                                               destination.vertex_unvisitVertex
                                                                             
                                                                               if(finished = true) then
                                                                                  return
                                                                               else 
                                                                         

                                                                               end if           
                                                                   end if

                                                         end for                                                 
          end if



  end graph_recursiveDFS
    
  export operation graph_generateGraph[size: Integer, children: Integer] -> [ret: Graph]

         var newGraph: Graph <- Graph.create
         var originID: Integer <- 1
         var destinationID: Integer <- 2

         var currentOrigin: Vertex <- NIL
         var currentDestination: Vertex <- NIL
         var amountChildren: Integer <- 0

         var searchResults: Vertex <- NIL
 
         loop   
                  exit when (newGraph.graph_getSize >= size)

                  if(newGraph.graph_getRoot == NIL) then 
                         
                         searchResults <- NIL
                  else                  
                         searchResults <- newGraph.graph_recursiveDFS[newGraph.graph_getRoot, originID, "DFS", NIL, NIL]
                         newGraph.graph_resetRecursionVariables
                  end if

                 if (searchResults == NIL or (searchResults !== NIL and searchResults.vertex_getID = -666)) then
                                                                                              
                                                   currentOrigin <- Vertex.create[originID]
                                                   currentOrigin.vertex_setChildren                                 
                  else 
                      
                           currentOrigin <- searchResults
                           currentOrigin.vertex_setGraph[newGraph]
                           currentOrigin.vertex_setChildren
                  end if    

                  var edges: array.of[Edge] <- Array.of[Edge].create[0]

                  loop

                        if (amountChildren = children) then 
                                         
                                             amountChildren <- 0
                                             exit
                        end if

                        currentDestination <- Vertex.create[destinationID]
                        currentDestination.vertex_setParent[currentOrigin]
                        currentDestination.vertex_setDepth[(currentOrigin.vertex_getDepth + 1)]
                        currentDestination.vertex_setGraph[newGraph]
                        var newEdge: Edge <- Edge.create[currentOrigin, currentDestination]  
   
                        edges.addUpper[newEdge]
                        amountChildren <- amountChildren + 1
                        destinationID <- destinationID + 1

                  end loop

                        if (searchResults == NIL or (searchResults !== NIL and searchResults.vertex_getID = -666)) then
                     
                               if(newGraph.graph_getSize = 0) then   

                                      currentOrigin.vertex_setGraph[newGraph]

                                      for e in edges
                                               currentOrigin.vertex_addPath[e]
                                               newGraph.graph_incrementSize
                                      end for 

                                      newGraph.graph_setRoot[currentOrigin]
                                      newGraph.graph_incrementSize                                                                                 
                            end if

                        else
                                                                                                              
                              var res: Vertex <- newGraph.graph_recursiveDFS[newGraph.graph_getRoot, originID, "ADD", edges, NIL]
                              newGraph.graph_resetRecursionVariables                          
                             
                        end if

                  edges <- NIL
                  currentOrigin <- NIL
                  currentDestination <- NIL
                  originID <- originID + 1

         end loop 

                 (locate self)$stdout.putString["\n Graph of size [" || newGraph.graph_getSize.asString || "] has been succesfully constructed \n\n\n\n"]
                 newGraph.graph_setOriginalGraphSize[newGraph.graph_getSize]

                 ret <- newGraph

  end graph_generateGraph


export operation graph_expandVertex[originalVertex: Vertex, mode: String] -> [ret: Vertex]

        if( (originalVertex.vertex_getAmountEdges) < 1) then          
                ret <- NIL
                return    
        end if

        var expandedVertex: Vertex <- NIL

        if(mode = "PARTIAL") 
                                  then
                                            (locate self)$stdout.putString["\n * * * * [PARTIAL EXPANSION] * * * * \n"]
                                            ret <- self.graph_partialExpansion[originalVertex] 
        elseif(mode = "FULL") 
                                  then

                                            (locate self)$stdout.putString["\n * * * * [FULL EXPANSION] * * * * \n"]                                        
                                            ret <- self.graph_fullExpansion[originalVertex]
        end if
                                	 		 
end graph_expandVertex


export operation graph_partialExpansion[originalVertex: Vertex] -> [ret: Vertex]
                                     

                                            var expandedVertex: Vertex <- Vertex.create[originalVertex.vertex_getID] 
                                            expandedVertex.vertex_setDepth[originalVertex.vertex_getDepth]
                                            expandedVertex.vertex_setChildren

                                            var edges: Array.of[Edge] <- originalVertex.vertex_getEdges

                                            for e in edges
                                              
                                                           var newVertex: Vertex <- Vertex.create[e.edge_getDestination.vertex_getID]

                                                           newVertex.vertex_setParent[expandedVertex]
                                                           newVertex.vertex_setDepth[e.edge_getDestination.vertex_getDepth]

                                                           var newEdge:Edge <- Edge.create[expandedVertex, newVertex]
                                                           expandedVertex.vertex_addPath[newEdge]
                                                           expandedVertex.vertex_incrementTotalChildren
                                            end for 
                                            
                                            ret <- expandedVertex  
                                         
end graph_partialExpansion


export operation graph_fullExpansion[originalVertex: Vertex] -> [ret: Vertex]
       
         var queue: Array.of[Vertex] <- Array.of[Vertex].create[0]
         var expandedVertex: Vertex <- Vertex.create[originalVertex.vertex_getID]
         expandedVertex.vertex_setChildren
 

         queue.addUpper[originalVertex]
         originalVertex.vertex_visitVertex

         loop               
                  exit when (queue.empty)
                  
                  var currentVertex: Vertex <- queue.removeLower

                  var newOrigin: Vertex <- Vertex.create[currentVertex.vertex_getID] 
            
                  newOrigin.vertex_setChildren
                  
                  var edges: Array.of[Edge] <- Array.of[Edge].create[0]

                  for e in currentVertex.vertex_getEdges

                      var destination: Vertex <- e.edge_getDestination
                      var newDestination: Vertex <- Vertex.create[destination.vertex_getID]
                    
                      var newEdge: Edge <- Edge.create[newOrigin, newDestination]
                      newOrigin.vertex_incrementEdges
                      
                      edges.addUpper[newEdge]
                      
                      if(destination.vertex_isVisited == false) then
                                     queue.addUpper[destination]
                                     destination.vertex_visitVertex
                      end if
                      
                      expandedVertex.vertex_incrementTotalChildren

                  end for

                  currentVertex.vertex_resetVisited

                  if(newOrigin.vertex_getAmountEdges > 0) then
                               self.graph_bindEdges[expandedVertex, newOrigin.vertex_getID, edges]
                               self.graph_resetRecursionVariables
                  end if

                  currentVertex.vertex_resetVisited
                  currentVertex.vertex_unvisitVertex

         end loop

    originalVertex.vertex_unvisitVertex
   
    queue <- NIL
    ret <- expandedVertex

  end graph_fullExpansion
    
end Graph

% Superclass of Client, Proxy and DataCenter

const Role <- class Role

      export operation startRole[flag: String]
      end startRole

      export operation createCache[size: Integer]
      end createCache

      export operation setPointer[pointer: Role]
      end setPointer

      export operation getCache -> [ret: Cache]
      end getCache

      export operation expandVertex[location: Node, targetVertex: Vertex, mode: String] -> [ret: Vertex]
      end expandVertex

end Role

% Responsible for distributing functionality to various Planetlab nodes

const Run <- object Run


	process

       self.run_executeShell

     
	end process


  export operation run_executeShell

        (locate self)$stdout.putString["\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"]
        (locate self)$stdout.putString["- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"]
        (locate self)$stdout.putString["- - - - [Graph caching in Near-far Clouds using Emerald] - - - -\n"]
        (locate self)$stdout.putString["- - - - - - - - - - - - - - - - - - - - - - - - - - - -  - - - -\n"]
        (locate self)$stdout.putString["- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n"]

        self.run_printMenu

        (locate self)$stdout.putString["\n [Choose Command] \n"]

        var command: Integer <- Integer.literal[stdin.getString]

       if command = 1 then
          self.run_printMenu
        elseif command = 2 then 
          self.run_memoryCapExperiment
        elseif command = 3 then 
          self.run_generateGraphExperiment
        elseif command = 4 then  
          self.run_transmitGraphExperiment
        elseif command = 5 then 
          self.run_dfsHitSpeedExperiment
        elseif command = 6 then 
          self.run_clientServerCaching
        elseif command = 7 then 
         self.run_nearFarCloudCaching
       else 
             (locate self)$stdout.putString["\n * * * * * Illegal input detected * * * * *\n [please input a number between 1 and 7]\n"]
             self.run_executeShell
       end if


  end run_executeShell

  export operation run_memoryCapExperiment

  (locate self)$stdout.putString["\n - - - - [Starting] Experiment: Memory Capacity [Starting]  - - - - \n\n"]

  var memoryCapacityExperiment: Experiments <- Experiments.create
  memoryCapacityExperiment.experiments_memoryCap

   (locate self)$stdout.putString["\n - - - - [Finished] Experiment: Generate Graph [Finished]  - - - - \n\n"]

  end run_memoryCapExperiment

  export operation run_generateGraphExperiment

  (locate self)$stdout.putString["\n - - - - [Starting] Experiment: Generate Graph [Starting]  - - - - \n\n"]

    var generateGraphExperiment: Experiments <- Experiments.create
    generateGraphExperiment.experiments_generateGraph


     (locate self)$stdout.putString["\n - - - - [Finished] Experiment: Generate Graph [Finished]  - - - - \n\n"]


  end run_generateGraphExperiment

  export operation run_transmitGraphExperiment

   (locate self)$stdout.putString["\n - - - - [Starting] Experiment: Transmit Graph [Starting]  - - - - \n\n"]

      var c: Role <- NIL
      var dc: Role <- NIL 

      var there: Node
      var all: NodeList <- (locate self).getActiveNodes
      var maxNodes: Integer <- (all.upperBound + 1)  

      c <- Client.create
      dc <- DataCenter.create
      
     for index: Integer <- 1 while (index < maxNodes) by index <- index + 1  
                there <- all[index]$theNode                                    
     end for
           
             const clientLocation <- all[1]$theNode
             var transmitGraphExperiment: Experiments <- Experiments.create
             transmitGraphExperiment.experiments_transmitGraph[clientLocation]

   (locate self)$stdout.putString["\n - - - - [Finished] Experiment: Generate Graph [Finished]  - - - - \n\n"]


  end run_transmitGraphExperiment




  % This operation will execute DFS Hit Speed experiments on all associated nodes

  export operation run_dfsHitSpeedExperiment

      (locate self)$stdout.putString["\n - - - - [Starting] Experiment: DFS Hit Speed [Starting]  - - - - \n\n"]


      var there: Node
      var all: NodeList <- (locate self).getActiveNodes
      var maxNodes: Integer <- (all.upperBound + 1)  

   
      
     for index: Integer <- 1 while (index < maxNodes) by index <- index + 1 

            % Build a new process in order to perform parallell experiments on distinct nodes 

                const newProcess <- object newProcess

                   process

                           there <- all[index]$theNode
                           var dfsHitSpeedExperiment: Experiments <- Experiments.create
                           move dfsHitSpeedExperiment to there
                           dfsHitSpeedExperiment.experiments_DFS_hitspeed    
                        

                  end process

                end newProcess

     end for

      var dfsHitSpeedExperiment: Experiments <- Experiments.create
      dfsHitSpeedExperiment.experiments_DFS_hitspeed


            (locate self)$stdout.putString["\n - - - - [Finished] Experiment: DFS Hit Speed [Finished]  - - - - \n\n"]
           

  end run_dfsHitSpeedExperiment


  export operation run_clientServerCaching

          (locate self)$stdout.putString["\n - - - - [Starting] Caching: Client-Server [Starting]  - - - - \n\n"]

          var p: Role <- NIL 
          var c: Role <- NIL

          var there: Node
          var all: NodeList <- (locate self).getActiveNodes
          var maxNodes: Integer <- (all.upperBound + 1)  
          
          p <- Proxy.create
          c <- Client.create
          
         for index: Integer <- 1 while (index < maxNodes) by index <- index + 1  
                    there <- all[index]$theNode                                    
         end for
               
                 fix c at all[1]$theNode
                 fix p at all[2]$theNode
                                    
                
                 p.startRole["CS"]
                 c.setPointer[p]
                 c.startRole["CS"]

               loop
                                    
               end loop

  end run_clientServerCaching


  export operation run_nearFarCloudCaching

          (locate self)$stdout.putString["\n - - - - [Starting] Caching: Near-Far Cloud [Starting]  - - - - \n\n"]

          var p: Role <- NIL 
          var c: Role <- NIL
          var dc: Role <- NIL 

          var there: Node
          var all: NodeList <- (locate self).getActiveNodes
          var maxNodes: Integer <- (all.upperBound + 1)  
     
          p <- Proxy.create
          c <- Client.create
          dc <- DataCenter.create
          
         for index: Integer <- 1 while (index < maxNodes) by index <- index + 1  
                    there <- all[index]$theNode                                    
         end for
               
                 fix c at all[1]$theNode
                 fix p at all[2]$theNode
                                    
                 dc.startRole["NFC"]
                 p.setPointer[dc]
                 p.startRole["NFC"]
                 c.setPointer[p]
                 c.startRole["NFC"]

               loop
                                  
               end loop


  end run_nearFarCloudCaching


  % Prints a menu illustrating the choices that are available

   export operation run_printMenu

      (locate self)$stdout.putString["\n                    |M E N U|                    \n"]
      (locate self)$stdout.putString["---------------------------------------------------------------\n"]
      (locate self)$stdout.putString[" [1]         |Print Menu| \n"]
      (locate self)$stdout.putString[" [2]         |Experiments: Memory Capacity| \n"]
      (locate self)$stdout.putString[" [3]         |Experiments: Generate Graph| \n"]
      (locate self)$stdout.putString[" [4]         |Experiments: Transmit Graph| \n"]
      (locate self)$stdout.putString[" [5]         |Experiments: DFS hit speed| \n"]
      (locate self)$stdout.putString[" [6]         |Caching: Client-Server| \n"]
      (locate self)$stdout.putString[" [7]         |Caching: Near-Far Cloud| \n"]
      (locate self)$stdout.putString["---------------------------------------------------------------\n"]

   end run_printMenu

end Run

const Vertex <- Class Vertex[number: Integer]
    
      attached var id: Integer <- number
      attached var frequency: Integer <- 0
      attached var parent: Vertex <- NIL
      attached var depth: Integer <- 0
      attached var totalChildren: Integer <- 0
      attached var visited: Boolean <- false

      attached var hasChildren: Boolean <- false

      var fromGraph: Graph <- NIL
      attached var amountEdges: Integer <- 0

      attached var paths: Array.of[Edge] <- NIL

      attached var path1: Edge <- NIL
      attached var path2: Edge <- NIL
      attached var path3: Edge <- NIL
      attached var path4: Edge <- NIL
      attached var path5: Edge <- NIL


    export function vertex_getTotalChildren -> [ret: Integer]
           ret <- totalChildren
    end vertex_getTotalChildren

    export operation vertex_incrementTotalChildren
           totalChildren <- totalChildren + 1
    end vertex_incrementTotalChildren

    export operation vertex_setDepth[d: Integer]
           depth <- d
    end vertex_setDepth

    export function vertex_getDepth -> [ret: Integer]
           ret <- depth
    end vertex_getDepth
  
    export operation vertex_resetVisited

           if path1 !== NIL then 
            path1.edge_getDestination.vertex_unvisitVertex 
           end if

           if path2 !== NIL then 
          	 path2.edge_getDestination.vertex_unvisitVertex 
           end if

           if path3 !== NIL then 
          	 path3.edge_getDestination.vertex_unvisitVertex 
           end if

           if path4 !== NIL then 
          	 path4.edge_getDestination.vertex_unvisitVertex 
           end if

           if path5 !== NIL then 
          	 path5.edge_getDestination.vertex_unvisitVertex 
           end if     

    end vertex_resetVisited

    export operation vertex_swapVertex[newVertex: Vertex]

           if path1 !== NIL and (newVertex.vertex_getID = path1.edge_getDestination.vertex_getID) then 

             newVertex.vertex_setParent[self]
             path1.edge_setDestination[newVertex]     

           elseif path2 !== NIL and (newVertex.vertex_getID = path2.edge_getDestination.vertex_getID) then 

             newVertex.vertex_setParent[self]
             path2.edge_setDestination[newVertex] 
       

           elseif path3 !== NIL and (newVertex.vertex_getID = path3.edge_getDestination.vertex_getID) then

             newVertex.vertex_setParent[self]
             path3.edge_setDestination[newVertex] 
         

           elseif path4 !== NIL and (newVertex.vertex_getID = path4.edge_getDestination.vertex_getID) then  

             newVertex.vertex_setParent[self]
             path4.edge_setDestination[newVertex]    
            
           elseif path5 !== NIL and (newVertex.vertex_getID = path5.edge_getDestination.vertex_getID) then 

             newVertex.vertex_setParent[self]
             path5.edge_setDestination[newVertex]

           end if
 
    end vertex_swapVertex

    export operation vertex_setGraph[g: Graph]
           fromGraph <- g
    end vertex_setGraph

    export operation vertex_visitVertex
           visited <- true
    end vertex_visitVertex

    export operation vertex_unvisitVertex
           visited <- false
    end vertex_unvisitVertex

    export function vertex_cut[i: String] -> [ret: String]        
	         ret <- i.getSlice[0, i.length - 1]
    end vertex_cut
    
    export function vertex_getID -> [attached ret: Integer]
	         ret <- id
    end vertex_getID

    export function vertex_getSubGraph -> [ret: Graph]
           ret <- fromGraph
    end vertex_getSubGraph

    export function vertex_isVisited -> [ret: Boolean]
           ret <- visited
    end vertex_isVisited

    export function vertex_getParent -> [ret: Vertex]
           ret <- parent
    end vertex_getParent

    export function vertex_isParent -> [ret: Boolean]
           ret <- hasChildren
    end vertex_isParent

    export operation vertex_setParent[p: Vertex]
           parent <- p
    end vertex_setParent
    
    export operation vertex_setChildren
           hasChildren <- true
    end vertex_setChildren

   export operation vertex_incrementEdges
          amountEdges <- amountEdges + 1
   end vertex_incrementEdges

    export function vertex_getFirstPath -> [ret: Edge]
           ret <- path1
    end vertex_getFirstPath

    export function vertex_getSecondPath -> [ret: Edge]
           ret <- path2
    end vertex_getSecondPath

    export function vertex_getThirdPath -> [ret: Edge]
           ret <- path3
    end vertex_getThirdPath

    export function vertex_getFourthPath -> [ret: Edge]
           ret <- path4
    end vertex_getFourthPath

    export function vertex_getFifthPath -> [ret: Edge]
           ret <- path5
    end vertex_getFifthPath

    export function vertex_getPaths -> [ret: Array.of[Edge]]
           ret <- paths
    end vertex_getPaths

    export operation vertex_addPath[newEdge: Edge]

           if path1 == NIL then 
           	  path1 <- newEdge amountEdges <- amountEdges + 1
           elseif path2 == NIL then 
              path2 <- newEdge amountEdges <- amountEdges + 1
           elseif path3 == NIL then 
              path3 <- newEdge amountEdges <- amountEdges + 1
           elseif path4 == NIL then 
              path4 <- newEdge amountEdges <- amountEdges + 1
           elseif path5 == NIL then 
             path5 <- newEdge amountEdges <- amountEdges + 1
           end if     

    end vertex_addPath

    export operation vertex_setGraphChildren[targetGraph: Graph]

         if path1 !== NIL then 
         	path1.edge_getDestination.vertex_setGraph[targetGraph]
         end if 

         if path2 !== NIL then 
         	path2.edge_getDestination.vertex_setGraph[targetGraph]
         end if 

         if path3 !== NIL then 
         	path3.edge_getDestination.vertex_setGraph[targetGraph]
         end if 

         if path4 !== NIL then 
            path4.edge_getDestination.vertex_setGraph[targetGraph]
         end if

         if path5 !== NIL then 
         	path5.edge_getDestination.vertex_setGraph[targetGraph]
         end if 

    end vertex_setGraphChildren 

    export operation vertex_edgesToArray

           paths <- Array.of[Edge].create[0]

           if path1 !== NIL then 
           	  paths.addUpper[path1]
           end if

           if path2 !== NIL then 
           	  paths.addUpper[path2]
           end if

           if path3 !== NIL then 
           	  paths.addUpper[path3]
           end if

           if path4 !== NIL then 
           	  paths.addUpper[path4]
           end if 

           if path5 !== NIL then 
           	  paths.addUpper[path5]
           end if     

    end vertex_edgesToArray

    export operation vertex_getEdges -> [ret: Array.of[Edge]]

           var edgeArray: Array.of[Edge] <- Array.of[Edge].create[0]

           if path1 !== NIL then 
           	  edgeArray.addUpper[path1]
           end if

           if path2 !== NIL then 
           	  edgeArray.addUpper[path2]
           end if

           if path3 !== NIL then 
           	  edgeArray.addUpper[path3]
           end if

           if path4 !== NIL then 
           	  edgeArray.addUpper[path4]
           end if 

           if path5 !== NIL then 
           	  edgeArray.addUpper[path5]
           end if     

           ret <- edgeArray

    end vertex_getEdges

    export operation vertex_increaseEdges[addionalEdges: Integer]
           amountEdges <- amountEdges + addionalEdges
    end vertex_increaseEdges

    export function vertex_getPath[pathNumber: Integer] -> [ret: Edge] 

           if pathNumber = 1 then 
           	  ret <- path1
           elseif pathNumber = 2 then 
              ret <- path2
           elseif pathNumber = 3 then 
              ret <- path3
           elseif pathNumber = 4 then 
              ret <- path4
           elseif pathNumber = 5 then 
             ret <- path5
           end if

    end vertex_getPath

    export function vertex_getAmountEdges -> [ret: Integer]
           ret <- amountEdges
    end vertex_getAmountEdges

end Vertex

const CacheAlgorithm <- Typeobject CacheAlgorithm
	  operation cacheData[root: Vertex]
	  operation setCache[associatedCache: Cache]
end CacheAlgorithm


const DFSCaching <- Class DFSCaching

	  var fromCache: Cache <- NIL
	  var finished: Boolean <- false
	  var out: OutStream <-  NIL

	  initially
	  			    out <- OutStream.toUnix["caching.dat", "w"]
	  end initially

      export operation setCache[associatedCache: Cache]
             fromCache <- associatedCache
	  end setCache 

	  export operation cacheData[root: Vertex]

	  		 if(fromCache.cache_getData.graph_getSize >= 2000) then
              	
              	       (locate self)$stdout.putString["\n * * * * Caching is finished  * * * * \n"]

                       (locate self)$stdout.putString["Cache size [" || fromCache.cache_getData.graph_getSize.asString || "]\n"]
                       var p: Proxy <- view fromCache.cache_getNextLevelCache as Proxy
                       (locate self)$stdout.putString["Amount Proxy Invocations [" || p.proxy_getProxyInvocations.asString || "]\n"]
                       (locate self)$stdout.putString["Amount Data Center Invocations [" || p.proxy_getDataCenterInvocations.asString || "]\n"]

                       finished <- true
                       out.close
                       return
            else
                  
                     if(root.vertex_getPaths == NIL or ( (root.vertex_getPaths.upperBound + 1) < 1) ) then
                             root.vertex_edgesToArray
            end if

            % Cache miss: the vertex is a leaf!

            if(root.vertex_getAmountEdges < 1) 
                                                    then   

                    % Consult next level cache, request expansion of the given vertex 

                    var expandedVertex: Vertex <- fromCache.cache_getNextLevelCache.expandVertex[(locate self), root, NIL]
                                                   
                    if(expandedVertex == NIL)
                                                    then
                                            				% Expansion has failed

                                                            fromCache.cache_incrementMisses
                                                            return                                                                                                                                                           
                    else          

                    	 % Expansion is successful    
                                                      
                         var expandedSize: Integer <- expandedVertex.vertex_getTotalChildren

                         fromCache.cache_incrementHits

                         fromCache.cache_getData.graph_increaseSize[expandedSize]

                         expandedVertex.vertex_setGraph[fromCache.cache_getData]
                         expandedVertex.vertex_setGraphChildren[fromCache.cache_getData]
                         
                         if(root.vertex_getParent !== NIL) then  
                         	       expandedVertex.vertex_unvisitVertex
                                 root.vertex_getParent.vertex_swapVertex[expandedVertex]                                            
                         end if
                      	
                      	 const currentTime <- (locate self).getTimeOfDay
                         const elapsedTime <- fromCache.cache_getCurrentTime - currentTime 

                         var timeString: String <-  elapsedTime.asString  

                         var processedTimeString: String <- ""

                         for c in timeString
                                  if (c = ':') then processedTimeString <- processedTimeString || "."
                                  else processedTimeString <- processedTimeString || c.asString 
                                  end if
                         end for

                         processedTimeString <- processedTimeString.getSlice[1, processedTimeString.length-1]                   
                         var output: String <-  fromCache.cache_getData.graph_getSize.asString  || " " || processedTimeString.asString  || "\n"

                         out.putString[output]    
                         (locate self)$stdout.putString[output]

                         % Start caching from the current vertex parent 

                         self.cacheData[root.vertex_getParent]


                   end if

          else          	

                    			  for e in root.vertex_getPaths

								              var destination: Vertex <- e.edge_getDestination								          	

								              if(destination.vertex_isVisited = false) then                                                             

								             	    destination.vertex_visitVertex

								            	    self.cacheData[destination]

								                  destination.vertex_unvisitVertex
								                                                                  
								                if(finished = true) then							                	   
								                   	    return                                                                                
								                end if

								                else 
								                	                                                        
								        end if
				          end for

				    end if                               
          end if

	  end cacheData

end DFSCaching

const Cache <- Class Cache[initialSize: Integer, algorithm: CacheAlgorithm, nextLevelRole: Role]

		   var size: Integer <- 0
		   var data: Graph <- NIL
		   const MAX_EDGES <- 5
		   var currentTime: Time <- NIL

		   var amountHits: Integer <- 0
		   var amountMisses: Integer <- 0
		   var cachingAlgo: CacheAlgorithm <- NIL
		   var nextLevelCache: Role <- nextLevelRole

		   initially
		   				 data <- Graph.create
		   				 data <- data.graph_generateGraph[initialSize, MAX_EDGES]
		   				 size <- data.graph_getSize
		   				 cachingAlgo <- algorithm
		   				 cachingAlgo.setCache[self]
		   end initially

           export operation cache_commenceCaching
                  currentTime <- (locate self).getTimeOfDay
           		    cachingAlgo.cacheData[data.graph_getRoot]
           end cache_commenceCaching

           export function cache_getData -> [ret: Graph]
           		  ret <- data
           end cache_getData

           export function cache_getCurrentTime -> [ret: Time]
           		  ret <- currentTime
           end cache_getCurrentTime

           export operation cache_incrementHits
           		  amountHits<- amountHits + 1
           end cache_incrementHits

           export function cache_getAmountHits -> [ret: Integer]
           		  ret <- amountHits
           end cache_getAmountHits

           export operation cache_incrementMisses
           		  amountMisses <- amountMisses + 1
           end cache_incrementMisses

           export function cache_getAmountMisses -> [ret: Integer]
                  ret <- amountMisses
           end cache_getAmountMisses

           export function cache_getNextLevelCache -> [ret: Role]
           		  ret <- nextLevelCache
           end cache_getNextLevelCache

end Cache

const Experiments <- Class Experiments

export operation experiments_memoryCap

            var maxIntegers: Integer <- 1000
            var randomDigit: Integer <- 1
            var integerCounter: Integer <- 0

            

            loop

                     var integers: Array.of[Integer] <- Array.of[Integer].create[0]
                     const preTime <- (locate self).getTimeOfDay

                  loop
                            exit when (integerCounter = maxIntegers)

                            integers.addUpper[randomDigit]
                            randomDigit <- randomDigit + 1
                            integerCounter <- integerCounter + 1

                  end loop

                     randomDigit <- 0
                     integerCounter <- 0

                     const postTime <- (locate self).getTimeOfDay
                     const elapsedTime <- postTime - preTime                     

                     var timeString: String <- elapsedTime.asString
                     var processedTimeString: String <- ""

                     for c in timeString
                              if (c = ':') then processedTimeString <- processedTimeString || "."
                              else processedTimeString <- processedTimeString || c.asString 
                              end if
                     end for

                     var outputString: String <- (maxIntegers*4).asString || " " || processedTimeString || "\n"
   
                     (locate self)$stdout.putString[outputString]
                   
                     maxIntegers <- maxIntegers + 1000
                     integers <- NIL

            end loop


          
  end experiments_memoryCap



  export operation experiments_generateGraph

  				 var size: Integer <- 500
  				 const MAX_CHILDREN <- 5
  				 const MAX_SIZE <- 6000
  				 const out <- OutStream.toUnix["experiments_generateGraph.dat", "w"]

  				 loop

		  				 exit when size > MAX_SIZE

		  	             const preGenerate <- (locate self).getTimeOfDay

		                 var newGraph: Graph <- Graph.create 
		                 newGraph <- newGraph.graph_generateGraph[size, MAX_CHILDREN]
		                 var graphSize: Integer <- newGraph.graph_getSize

		                 const postGenerate <- (locate self).getTimeOfDay
		                 const generateTime <- postGenerate - preGenerate

		                 var timeString: String <- generateTime.asString
		                 var processedTimeString: String <- ""

		                 for c in timeString
		                           if (c = ':') then processedTimeString <- processedTimeString || "."
		                           else processedTimeString <- processedTimeString || c.asString 
		                           end if
		                 end for
		                 
		                 var s: String <- graphSize.asString || " " || processedTimeString || "\n"
		                 
		                 (locate self)$stdout.putString[s]
		                 out.putString[s]

		                 s <- NIL
		                 newGraph <- NIL
		                 processedTimeString <- NIL 

                 		 size <- size + 500

  				 end loop

  				 out.close


  end experiments_generateGraph

  export operation experiments_DFS_hitspeed

  				 (locate self)$stdout.putString["\n\n - - - - - - Experiment: DFS Hit Speed has been started at node [" || (locate self)$name || "] - - - - - - \n\n"]	


  		         var size: Integer <- 6000
  				 const MAX_CHILDREN <- 5
  				 var amountCalls: Integer <- 0
  				 var totalTime: Time <- Time.create[0,0]
  				
  				 var nodeName: String <- (locate self)$name 
  				 const out <- OutStream.toUnix["experiments_DFSHitSpeed_" || nodeName, "w"]

		                 var newGraph: Graph <- Graph.create 
		                 newGraph <- newGraph.graph_generateGraph[size, MAX_CHILDREN]
		                 var graphSize: Integer <- newGraph.graph_getSize
		              

		                 loop
		  				        exit when amountCalls = 5001

				                 const preSearch <- (locate self).getTimeOfDay

				                 var res: Vertex <- newGraph.graph_recursiveDFS[newGraph.graph_getRoot, 66666, "DFS", NIL, NIL] 
				                 newGraph.graph_resetRecursionVariables

				                 const postSearch <- (locate self).getTimeOfDay
				                 const elapsedTime <- postSearch - preSearch

				                 totalTime <- totalTime + elapsedTime

				                 var timeString: String <- elapsedTime.asString
				                 var processedTimeString: String <- ""

				                 for c in timeString
				                           if (c = ':') then processedTimeString <- processedTimeString || "."
				                           else processedTimeString <- processedTimeString || c.asString 
				                           end if
				                 end for
				                 
				                 var s: String <- amountCalls.asString || " " || processedTimeString || "\n"
				                 
				                 (locate self)$stdout.putString[s]
				                 out.putString[s]

				                 s <- NIL
				                 processedTimeString <- NIL 
		                 		 amountCalls <- amountCalls + 1

                 		 end loop

                 		 (locate self)$stdout.putString[" - - - - \n Total time: " || totalTime.asString || " - - - - \n"]

  end experiments_DFS_hitspeed


  export operation experiments_transmitGraph[location: Node] 
 			      

                 var size: Integer <- 500
  				 const MAX_CHILDREN <- 5
  				 const MAX_SIZE <- 6000
  				
  				 const out <- OutStream.toUnix["experiments_transmitGraph.dat", "w"]

  				 loop

		  				 exit when size > MAX_SIZE

		                 var newGraph: Graph <- Graph.create 
		                 newGraph <- newGraph.graph_generateGraph[size, MAX_CHILDREN]
		                 var graphSize: Integer <- newGraph.graph_getSize

		                 const preTransmission <- (locate self).getTimeOfDay

		                 move newGraph to location

		                 (locate self)$stdout.putString["\nGraph of size [" || graphSize.asString || "] has been moved to the node [" || location$name || "]\n"]

		                 const postTransmission <- (locate self).getTimeOfDay
		                 const transmissionTime <- postTransmission - preTransmission

		                 var timeString: String <- transmissionTime.asString
		                 var processedTimeString: String <- ""

		                 for c in timeString
		                           if (c = ':') then processedTimeString <- processedTimeString || "."
		                           else processedTimeString <- processedTimeString || c.asString 
		                           end if
		                 end for
		                 
		                 var s: String <- graphSize.asString || " " || processedTimeString || "\n"
		                 
		                 (locate self)$stdout.putString[s]
		                 out.putString[s]

		                 s <- NIL
		                 newGraph <- NIL
		                 processedTimeString <- NIL 

                 		 size <- size + 500

  				 end loop

  				out.close                                
                
  end experiments_transmitGraph



end Experiments

