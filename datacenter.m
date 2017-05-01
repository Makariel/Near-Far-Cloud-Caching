
const DataCenter <- Class DataCenter(Role)

    var activated: Boolean <- false
    var cacheReady: Boolean <- false
    var output: OutStream <- NIL
    var localCache: Cache <- NIL
    var proxyConnection: Proxy

    process

                 loop
                          exit when activated
                 end loop

                 (locate self)$stdout.putString["\n\n [NODE ONLINE]             DATA CENTER            [NODE ONLINE] \n\n"]

                 self.createCache

                 
                
     end process

     export operation startRole 
            activated <- true
     end startRole

     export operation createCache 

            var datacenterCachingAlgorithm: CacheAlgorithm <- DFSCaching.create
            localCache <- Cache.create[5000, datacenterCachingAlgorithm, NIL]
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