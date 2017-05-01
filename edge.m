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