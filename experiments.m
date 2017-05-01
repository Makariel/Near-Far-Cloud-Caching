const Experiments <- Class Experiments

export operation experiments_memoryCap

            var maxIntegers: Integer <- 1000
            var randomDigit: Integer <- 1
            var integerCounter: Integer <- 0

            const out <- OutStream.toUnix["memoryCap.dat", "w"]

            loop

                    % exit when (maxIntegers >= 163000)

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
                     out.putString[outputString]
                     (locate self)$stdout.putString[outputString]
                   
                     maxIntegers <- maxIntegers + 1000
                     integers <- NIL

            end loop

            out.close
          
  end experiments_memoryCap


  export operation experiments_transmitBytes[location: Node]

  		 var amountIntegers: Integer <- 10
  		 const out <- OutStream.toUnix["byteTransmission.dat", "w"]

  		 loop

  		 			 var payload: Array.of[Integer] <- Array.of[Integer].create[0]
         			 	
			         var counter: Integer <- 1

			         loop
			                   exit when counter > amountIntegers
			                   payload.addUpper[counter]
			                   counter <- counter + 1
			         end loop

			         var amountBytes: Integer <- amountIntegers * 4        
			    	 	
			         const preMove <- (locate self).getTimeOfDay

			         move payload to location

			         const postMove <- (locate self).getTimeOfDay
			         const moveTime <- postMove - preMove

			         var timeString: String <- moveTime.asString
			         var processedTimeString: String <- ""

			         for c in timeString
			                   if (c = ':') then processedTimeString <- processedTimeString || "."
			                   else processedTimeString <- processedTimeString || c.asString 
			                   end if
			         end for

			         var s: String <- amountBytes.asString || " " || processedTimeString || "\n"
			         out.putString[s]
			      
			         payload <- NIL

			         amountIntegers <- amountIntegers + 10

	    end loop   

	    out.close   

  end experiments_transmitBytes


  export operation experiments_generateGraph

  				 var size: Integer <- 500
  				 const MAX_CHILDREN <- 5
  				 const MAX_SIZE <- 10000
  				% const out <- OutStream.toUnix["generateGraph.dat", "w"]

  				 loop

		  				% exit when size > MAX_SIZE

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
		               %  out.putString[s]

		                 s <- NIL
		                 newGraph <- NIL
		                 processedTimeString <- NIL 

                 		 size <- size + 500

  				 end loop

  end experiments_generateGraph

  export operation experiments_DFS_hitspeed


  		         var size: Integer <- 6000
  				 const MAX_CHILDREN <- 5
  				 var amountCalls: Integer <- 0
  				 var totalTime: Time <- Time.create[0,0]
  				 
  				const out <- OutStream.toUnix["DFS_hitspeed_1000_washington.dat", "w"]

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
  				 const MAX_SIZE <- 8000
  				
  				 const out <- OutStream.toUnix["transmitGraph.dat", "w"]

  				 loop

		  				 exit when size >= MAX_SIZE

		                 var newGraph: Graph <- Graph.create 
		                 newGraph <- newGraph.graph_generateGraph[size, MAX_CHILDREN]
		                 var graphSize: Integer <- newGraph.graph_getSize

		                 const preTransmission <- (locate self).getTimeOfDay

		                 move newGraph to location

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
		                 % out.putString[s]

		                 s <- NIL
		                 newGraph <- NIL
		                 processedTimeString <- NIL 

                 		 size <- size + 500

  				 end loop

  				out.close                                
                
  end experiments_transmitGraph



end Experiments