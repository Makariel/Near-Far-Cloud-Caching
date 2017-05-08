
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