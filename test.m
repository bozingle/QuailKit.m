function test()
    obj = JR_Data("SM304472_0+1_20181219$100000.wav");
    
    %Property of a JR_Data object. It contains the final second of the 
    %processed recording.(For iteration purposes)
    lastTime = obj.finalTime;
    %Retrieves all the 10s intervals from memory.
    for i = 10:10:lastTime
        [s,t] = obj.get(i-10, i);
    end
    %Retrieves a specific interval that isn't a 10s interval.
    [s,t] = obj.get(500,900);
end