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