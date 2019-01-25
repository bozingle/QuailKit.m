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
        f
        fs
        audio
        spgram
        scale
        overlap
        progress
        filepath
        finalTimeAudio
        finalTimeSpgram
    end
    
    methods
        function obj = JR_Data(recording,varargin)
            p=inputParser;
            addRequired(p,'recording',@(x) ischar(x));
            addParameter(p,'scale',0.08,@(x) isnumeric(x));
            addParameter(p,'overlap',0.8,@(x) isnumeric(x));
            addParameter(p,'f',0:10:10000,@(x) isnumeric(x));
            parse(p,recording,varargin{:});
            
            obj.filepath = "..\..\..\Quail Call - Datastore\"+erase(p.Results.recording,".wav")+"\";%Location where the processed file should be.
            if exist(obj.filepath) && isempty(varargin)
                fileObj = load(obj.filepath+erase(p.Results.recording,".wav")+".mat");
                obj = fileObj.obj;
                ds = datastore(obj.filepath + "\spgram");
                obj.spgram = tall(ds);
                ds = datastore(obj.filepath+"\audio");
                obj.audio = tall(ds);
            else
                try
                    rmdir(obj.filepath,'s');
                catch
                end
                mkdir(obj.filepath);
                [obj,raw]=obj.read(p.Results.recording);
                obj.scale = p.Results.scale;
                obj.f = p.Results.f;
                obj.overlap = p.Results.overlap;
                obj = obj.process(raw);
                obj = obj.sp();
                ds = datastore(obj.filepath + "\spgram");
                obj.spgram = tall(ds);
                obj = obj.formatAudio();
                ds = datastore(obj.filepath+"\audio");
                obj.audio = tall(ds);
                save(obj.filepath+erase(p.Results.recording,".wav")+".mat", "obj");
            end
        end
        
        function [obj,raw]=read(obj,recording)
            path = "..\..\..\Quail Call - Recordings\"+recording;
            [raw,obj.fs]=audioread(path);
        end
        
        function obj=process(obj,raw)
            obj.audio(1:size(raw,1))=zscore(raw(:,1));
        end
        
        function obj = formatAudio(obj)
            obj.audio = obj.audio';
            obj.audio(:,2) = obj.audio;
            obj.finalTimeAudio = (length(obj.audio)/obj.fs);
            obj.audio(:,1) = ((1/obj.fs):(1/obj.fs):obj.finalTimeAudio)';
            obj.audio = tall(obj.audio);
            write(obj.filepath+"\audio",obj.audio,'FileType', 'mat');
        end
        
        function [obj]=sp(obj)
            %mult = 250;%125 for 10s intervals (please don't do hard-coded numbers next time)
            window = round(obj.scale*obj.fs);
            mult=round(20/obj.scale);
            last = length(obj.audio);
            obj.progress = 0;
            spgramTA = tall([]);
            disp("Processing spectrogram");
            for i = window*mult:window*mult:last
                [s,~,t1] = spectrogram(obj.audio(max(1,(i-window*(mult+1)-round(obj.overlap*window)+1)):i),window,...
                    round(obj.overlap*window),obj.f,obj.fs);
                s = db(abs(s'));
                iter = i/(window*mult);
                t1 = t1' + (iter - 1)*20;
                sLength = length(s(1,:));
                spgramA = t1; 
                spgramA(:,2:sLength+1) = s;
                spgramTA = tall([spgramTA;tall(spgramA)]);
                disp("Progress: " + obj.progress + "%");
                obj.progress = round((i/last)*10000)/100;
                obj.finalTimeSpgram = t1(end);
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
