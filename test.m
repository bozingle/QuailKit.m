function test()
%     date = "12/19/2018";
%     obj = JR_MapMake(date);
%     key = ''; %Put in your key.
%     obj.mapMake(1, 'miles', key);
    %obj.newmapMake(1, 'miles');
    
    %Varargins- Intervals for spectrogram to create, frequency interval,
    %scale
    obj = JR_Data("","SM304472_0+1_20181219$100000.wav",40,[0:10:10000],0.8);
    
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
    %Last argument is channel now.
    [s,~, t] = obj.get(0,100,"audio","1");
end
