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

            if(root.vertex_getAmountEdges < 1) 
                                                    then   

                    var expandedVertex: Vertex <- fromCache.cache_getNextLevelCache.expandVertex[(locate self), root, NIL]
                                                   
                    if(expandedVertex == NIL)
                                                    then
                                            
                                                            fromCache.cache_incrementMisses
                                                            return                                                                                                                                                           
                    else              
                                                      
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

                          var p: Proxy <- view fromCache.cache_getNextLevelCache as Proxy
                          var proxyInvocations: Integer <- p.proxy_getDataCenterInvocations
                   
                         var output: String <-  fromCache.cache_getData.graph_getSize.asString  || " " || proxyInvocations.asString  || "\n"

                         % processedTimeString.asString
                         % proxyInvocations.asString
                         % processedTimeString.asString

                         out.putString[output]     	                 	                       
                         (locate self)$stdout.putString[output]

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