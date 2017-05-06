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