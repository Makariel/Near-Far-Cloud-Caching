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