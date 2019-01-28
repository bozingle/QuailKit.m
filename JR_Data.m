classdef JR_Data
    %UNTITLED3 Summary of this class goes here
    %To invoke the constructor:
    %   obj = JR_Data(fileDir+fileName+audio extension(i.e ".wav"))
    % To retrieve intervals of time from memory
    %   obj.get(first, last)
    %first and last are in seconds. Any interval works.
    %first - the start of the interval to load from memory.
    %last - the end of the interval to load from memory.
    
    properties
        audio
        fs
        spgram
        scale
        progress
        filepath
        finalTimeAudio
        finalTimeSpgram
    end
    
    methods
        function obj = JR_Data(recording)
            obj.filepath = ""+erase(recording,".wav");%Location where the processed file should be.
            if exist(obj.filepath)
                fileObj = load(obj.filepath+"\processed"+erase(recording,".wav")+".mat");
                obj = fileObj.obj;
                ds = datastore(obj.filepath + "\spgram");
                obj.spgram = tall(ds);
                ds = datastore(obj.filepath+"\audio");
                obj.audio = tall(ds);
            else
                obj.finalTimeSpgram = 0;
                [obj,raw]=obj.read(recording);
                obj.scale=0.8;
                obj = obj.process(raw);
                obj = obj.sp();
                ds = datastore(obj.filepath + "\spgram");
                obj.spgram = tall(ds);
                obj = obj.formatAudio();
                ds = datastore(obj.filepath+"\audio");
                obj.audio = tall(ds);
                save(obj.filepath+"\processed"+erase(recording,".wav")+".mat", "obj");
            end
        end
        
        function [obj,raw]=read(obj,recording)
            filepath = "..\..\..\Quail Call - Recordings\"+recording; %"..\..\..\Quail Call - Recordings\"+
            [raw,obj.fs]=audioread(filepath);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function obj = formatAudio(obj)
            obj.audio = obj.audio';
            obj.audio(:,2) = obj.audio;
            obj.finalTimeAudio = (length(obj.audio)/obj.fs)
            obj.audio(:,1) = ((1/obj.fs):(1/obj.fs):obj.finalTimeAudio)';
            obj.audio = tall(obj.audio);
            write(obj.filepath+"\audio",obj.audio,'FileType', 'mat');
        end
        
        function [obj]=sp(obj)
            mkdir(obj.filepath);
            f  = 0:10:10000;
            mult=20*round(10/obj.scale);%125 for 10s intervals
            first = round(0.1*obj.scale*obj.fs);
            last = length(obj.audio);
            obj.progress = 0;
            spgramTA = tall([]);
            disp("Processing spectrogram");
            for (i = first*mult:first*mult:last)
                [s,~,t] = spectrogram(obj.audio((i-first*mult+1):i),first,...
                    round(0.8*0.1*obj.scale*obj.fs),f,obj.fs);
                s = db(abs(s'));
                iter = i/(first*mult);
                t = t' + obj.finalTimeSpgram;
                sLength = length(s(1,:));
                spgramA = t; 
                spgramA(:,2:sLength+1) = s;
                spgramTA = tall([spgramTA;tall(spgramA)]);
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
                obj.finalTimeSpgram = t(end);
            end
            write(obj.filepath+"\spgram",spgramTA,'FileType', 'mat');
            disp("Complete!");
        end
        
        function [s,t] = get(obj, first, last, propertyType)
            if propertyType == "spgram"
                idx = obj.spgram(:,1) <= last;
                newData = obj.spgram(idx,:);
            elseif propertyType == "audio"
                idx = obj.audio(:,1) <= last;
                newData = obj.audio(idx,:);
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram and audio.");
            end
            idx = newData(:,1) >= first;
            newData = gather(newData(idx,:));
            t = newData(:,1);
            s = newData(:,2:end);
        end
        
        function display(obj,graphics,interval)
           % set(graphics.axis_audio,...
           %     'XData', obj.audio.,...
           %     'YData', obj.audio.)
           % set(graphics.axis_spectrogram,...
           %     'XData', obj.spectrogram.,...
           %     'YData', obj.spectrogram.,...
           %     'ZData', obj.spectrogram.)
        end
    end
end
