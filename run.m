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