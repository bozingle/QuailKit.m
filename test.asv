function test()
    obj = JR_Data("SM304472_0+1_20181219$100000.wav");
    
    %Property of a JR_Data object. It contains the final second of the 
    %processed recording.(For iteration purposes)
    
    %Final second of obj.spgram
    %lastTimeSpgram = obj.finalTimeSpgram;
    %Final second of obj.audio
    %lastTimeAudio = obj.finalTimeAudio;
    
    %Retrieves all the 10s intervals from obj.spgram.
    %for i = 10:10:lastTimeSpgram
    %    [s,t] = obj.get(i-10, i,"spgram");
    %end
    
    %Retrieves all 10s inteverals from obj.audio.
    %for i = 10:10:lastTimeAudio
    %    [s,t] = obj.get(i-10, i,"audio");
    %end
    
    %Demonstrates flexible second intervals.
    %[s,t] = obj.get(500,900,"audio");
    
    %Test of the error case
    %obj.get(0,10,"asdf");
end