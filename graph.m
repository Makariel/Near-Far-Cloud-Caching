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