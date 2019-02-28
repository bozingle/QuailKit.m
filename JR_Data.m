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
        scale
        progress
        audiofs
        spgramfs
        filepath
        finalTimeAudio
        finalTimeSpgram
    end
    
    methods
        function obj = JR_Data(recording)
            obj.filepath = ""+erase(recording,".wav");%Location where the processed file should be.
            if exist(obj.filepath)
                fileObj = load(obj.filepath+"\processed"+erase(recording,".wav")+".mat");
                prop = fileObj.propertiesStruct;
                obj.scale = prop.scale;
                obj.audiofs = prop.audiofs;
                obj.spgramfs = prop.spgramfs;
                obj.finalTimeAudio = prop.finalTimeAudio;
                obj.finalTimeSpgram = prop.finalTimeSpgram;
            else
                obj.finalTimeSpgram = 0;
                obj.scale = 0.8;
                [obj,raw]=obj.read(recording);
                audio = obj.process(raw);
                obj = obj.sp(audio, 40, [0:10:10000]);
                obj = obj.formatAudio(audio);
                propertiesStruct = struct(...
                    "scale", obj.scale,...
                    "audiofs", obj.audiofs,...
                    "spgramfs", obj.spgramfs,...
                    "filepath", obj.filepath,...
                    "finalTimeAudio", obj.finalTimeAudio,...
                    "finalTimeSpgram", obj.finalTimeSpgram...
                    );
                save(obj.filepath+"\processed"+erase(recording,".wav")+".mat", "propertiesStruct");
            end
        end
        
        function [obj,raw]=read(obj,recording)
            filepath = "..\..\..\Quail Call - Recordings\"+recording; %"..\..\..\Quail Call - Recordings\"+
            [raw,obj.audiofs]=audioread(filepath);
        end
        
        function audio = process(obj,raw)
            audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function obj = formatAudio(obj, audio)
            audio = audio';
            h5create(obj.filepath+"\information.h5", '/audio', [length(audio(:,1)) length(audio(1,:))]);
            h5writeatt(obj.filepath+"\information.h5", '/audio', "audiofs", obj.audiofs);
            h5write(obj.filepath+"\information.h5", '/audio', audio);
        end
        
        function obj = sp(obj, audio, seconds, f)
            mkdir(obj.filepath);
            window = (round(0.8*0.1*obj.scale*obj.audiofs));
            mult = seconds*round(10/obj.scale);%multiplier needed to get 40s intervals
            first = round(0.1*obj.scale*obj.audiofs);
            last = length(audio);
            obj.progress = 0;
            disp("Processing spectrogram");
            for (i = first*mult:first*mult:last)
                [s,~,t] = spectrogram(audio((i-first*mult+1):i),first,...
                    window,f,obj.audiofs);
                spgramA = db(abs(s'));
                if ~exist(obj.filepath+"\information.h5")
                    obj.spgramfs = 1/abs(t(1) - t(2));
                    h5create(obj.filepath+"\information.h5", '/spgram', [inf length(spgramA(1,:))], 'ChunkSize', [length(spgramA(:,1)) length(spgramA(1,:))]);
                    Size = h5info(obj.filepath+"\information.h5", '/spgram');
                    Size = Size.Dataspace.Size;
                    h5writeatt(obj.filepath+"\information.h5", '/spgram', 'propertiesArray', [obj.spgramfs f(1) f(end)]);
                end
                h5write(obj.filepath+"\information.h5", '/spgram', spgramA,[Size(1)+1 1], [length(spgramA(:,1)) length(spgramA(1,:))]);
                Size(1) = Size(1) + length(spgramA(:,1));
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
                obj.finalTimeSpgram = t(end);
            end
            disp("Complete!");
        end
        
        function [s,t] = get(obj, first, last, propertyType)
            startIn = 0;
            endIn = 0;
            s = [];
            t = [];
            if propertyType == "spgram"
                Size = h5info(obj.filepath+"\information.h5", '/spgram');
                Size = Size.Dataspace.Size;
                startIn = first*obj.spgramfs + 1;
                endIn = last*obj.spgramfs-startIn+1;
                spgram = h5read(obj.filepath+"\information.h5", '/spgram', [startIn 1], [endIn Size(2)]);
                t = (first:1/obj.spgramfs:last)';
                t = t(1:length(spgram(:,1)));
                s = spgram;
            elseif propertyType == "audio"
                Size = h5info(obj.filepath+"\information.h5", '/audio');
                Size = Size.Dataspace.Size;
                startIn = first*obj.audiofs + 1;
                endIn = last*obj.audiofs-startIn+1;
                audio = h5read(obj.filepath+"\information.h5", '/audio', [startIn 1], [endIn Size(2)]);
                t = (first:1/obj.audiofs:last)';
                t = t(1:length(audio(:,1)));
                s = audio;
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram and audio.");
            end
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
