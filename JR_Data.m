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
        datetime
        progress
        audiofs
        spgramfs
        filepath
        rawfs
        startRecTime
    end
    
    methods
        function obj = JR_Data(audiopath, filepath, varargin)
            obj.filepath = filepath;
            if exist(obj.filepath)
                attVals = h5readatt(obj.filepath, '/c1/spgram', 'props');
                obj.spgramfs = attVals(1);
                obj.scale = attVals(4);
                obj.startRecTime = attVals(5);
                attVals = h5readatt(obj.filepath, '/c1/audio', 'audiofs');
                obj.audiofs = attVals(1);
                attVals = h5readatt(obj.filepath, '/c1/audio', 'audiofs');
                obj.rawfs=attVals(1);
                attVals = h5readatt(obj.filepath, '/', 'props');
                obj.datetime = attVals;
            else
                obj.fileSetup(audiopath, varargin{1,1}, varargin{1,2}, varargin{1,3},obj.filepath);
            end
        end
        
        function fileSetup(obj, audiopath, seconds, f, scale, varargin)
            RecordingName = split(audiopath,'\');
            RecordingName = RecordingName(end);
            [obj,raw]=obj.read(audiopath);
            audio = obj.process(raw);
            obj.scale = scale;
            
            filename =  split(obj.filepath,'\');
            filename = filename(end);
            filename = string(filename{1,1});
            
            fileStartLoc = string(varargin{1,1});
            
            for i = 1:length(audio(1,:))
                    disp("Processing spectrogram");
                    mult = floor(varargin{1,1}*obj.audiofs) + 1;                       %multiplier needed to get 40s intervals
                    audioLength = length(audio);
                    obj.progress = 0;
                    exists = 0;
                    for k = mult:mult:audioLength
                        [spgramA, t] = obj.sp(audio(:,i), f, mult, k);
                        if ~exists
                            obj.spgramfs = 1/abs(t(1) - t(2));
                            obj.startRecTime = t(1);
                            h5create(obj.filepath, "/c"+string(num2str(i))+"/spgram", [inf length(spgramA(1,:))], 'ChunkSize', [length(spgramA(:,1)) length(spgramA(1,:))]);
                            exists = 1;
                            Start = h5info(obj.filepath, "/c"+string(num2str(i))+"/spgram");
                            Start = Start.Dataspace.Size + 1;
                        end
                        
                        h5write(obj.filepath,"/c"+string(num2str(i))+"/spgram", spgramA,[Start(1) 1], [length(spgramA(:,1)) length(spgramA(1,:))]);
                        Start(1) = Start(1) + length(spgramA(:,1))+1;
                        disp("Progress: " + obj.progress + "%");
                        obj.progress = round((k/audioLength)*10000)/100;
                    end
                    disp('Complete!');
                    
                    h5writeatt(obj.filepath, "/c"+string(num2str(i))+"/spgram", 'props', [obj.spgramfs varargin{1,2}(1) varargin{1,2}(end) obj.scale obj.startRecTime]);
                    h5create(obj.filepath, "/c"+string(num2str(i))+"/raw", [size(raw,1) 1]);
                    h5write(obj.filepath, "/c"+string(num2str(i))+"/raw", raw(:,i));
                    
                    audio1 = audio(:,i);
                    h5create(fileStartLoc, "/c"+string(num2str(i))+"/audio", [size(audio1,1) 1]);
                    h5writeatt(fileStartLoc, "/c"+string(num2str(i))+"/audio", "audiofs", obj.audiofs);
                    h5write(fileStartLoc, "/c"+string(num2str(i))+"/audio", audio1);
                    
                end
%                 obj.datetime = HT_DataAccess([],'query', [...
%                     'SELECT an.start',...
%                     ' FROM [QuailKit].[dbo].[audio_node] an'...
%                     ' inner join [QuailKit].[dbo].[audio] a on an.audio_id = a.stream_id',...
%                 char(" WHERE name = '"+RecordingName+"'")], 'cellarray');
%                 obj.datetime=obj.datetime{1,1};
                h5writeatt(fileStartLoc, "/", 'props', '');
%                obj.datetime = datetime(obj.datetime,'InputFormat','yyyy-MM-dd HH:mm:ss.SSS');
                if length(varargin) == 2
                    fileEndLoc = string(varargin{1,2});
                    copyfile(fileStartLoc, fileEndLoc);
                    delete(fileStartLoc);
                end

        end
        
        function [obj,raw]=read(obj,audiopath)
            [raw,obj.audiofs]=audioread(audiopath);
        end
        
        function audio = process(obj,raw)
            audio=zscore(raw);
        end
        
        function [spgramA,t] = sp(obj, audio, f, mult, i)
            noverlap = (round(0.8*0.1*obj.scale*obj.audiofs));
            window = round(0.1*obj.scale*obj.audiofs);
            [s,~,t] = spectrogram(audio((i-mult+1):i),window,...
                    noverlap,f,obj.audiofs);
            spgramA = db(abs(s'));
        end
        
        function [s,f, t] = get(obj, first, last, propertyType,channel)
            propertyType = string(propertyType);
            testStr = char(propertyType);
            amountOfDS = h5info(obj.filepath, "/c"+channel+"/");
            amountOfDS = length(amountOfDS.Datasets);
            if testStr == "spgram" && str2num(channel) <= amountOfDS
                fs=obj.spgramfs;
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                
                attVals = h5readatt(obj.filepath, "/c"+channel+"/"+propertyType, 'props');
                obj.spgramfs = attVals(1);
                obj.scale = attVals(4);
                if mod(first,1) == 0
                    startIn = floor((first-obj.startRecTime)*obj.spgramfs) + 1;
                elseif first < obj.startRecTime
                    startIn = 1;
                end
                
                startIn = floor(first*obj.spgramfs) + 1;
                endIn = floor(last*obj.spgramfs) + 1;
                startT=floor(first*obj.spgramfs)/obj.spgramfs;
                endT=floor(last*obj.spgramfs)/obj.spgramfs;
                
                attVals = h5readatt(obj.filepath, "/c"+channel+"/"+propertyType, 'props');
                fStart = attVals(2);
                fEnd = attVals(3);
                
                step = (fEnd-fStart)/1000;
                s = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn-startIn+1 Size(2)]);
                f = fStart:step:fEnd;
                t = (startT:1/obj.spgramfs:endT)';
                t(1)
                
            elseif propertyType == "audio"
                f = [];
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                
                startIn = floor(first*obj.audiofs) + 1;
                endIn = floor(last*obj.audiofs) + 1;
                startT=floor(first*obj.audiofs)/obj.audiofs;
                endT=floor(last*obj.audiofs)/obj.audiofs;   
                
                audio = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn-startIn+1 1]);
                t = (startT:1/obj.audiofs:endT)';
                s = audio;

            elseif propertyType == "raw"
                f = [];
                Size = h5info(obj.filepath, "/c"+channel+"/"+propertyType);
                Size = Size.Dataspace.Size;
                
                startIn = floor(first*obj.rawfs) + 1;
                endIn = floor(last*obj.rawfs) + 1;
                startT=floor(first*obj.rawfs)/obj.rawfs;
                endT=floor(last*obj.rawfs)/obj.rawfs; 
                
                raw = h5read(obj.filepath, "/c"+channel+"/"+propertyType, [startIn 1], [endIn-startIn+1 1]);
                t = (startT:1/obj.rawfs:endT)';
                s = raw;            
                
            else
                error("Incorrect propertyType:"+newline+char(9)+"The propertyType "+propertyType+" does not correspond with the existing ones: spgram(+Number of spectrogram that exists in the dataset) and audio.");
            end
        end
        
        function emptyFile(obj, varargin)
            %Gets the name of the h5 file from obj.filepath for the temp h5 file.
            filename =  split(obj.filepath,'\');
            filename = filename(end);
            filename = string(filename{1,1});
            
            %Create new h5 file
            fileInfo = h5info(obj.filepath);
            for i = 1:length(fileInfo.Groups)
                h5create(filename,"/c"+i+"/spgram",fileInfo.Groups(i).Datasets(3).Dataspace.Size);
                h5writeatt(filename,"/c"+i+"/spgram", 'props', h5readatt(obj.filepath, "/c"+i+"/spgram", 'props'));
                h5create(filename,"/c"+i+"/audio",fileInfo.Groups(i).Datasets(1).Dataspace.Size);
                h5writeatt(filename,"/c"+i+"/audio", 'audiofs', h5readatt(obj.filepath, "/c"+i+"/audio", 'audiofs'));
                h5create(filename,"/c"+i+"/raw",fileInfo.Groups(i).Datasets(2).Dataspace.Size);
                h5writeatt(filename,"/",'props',h5readatt(obj.filepath, '/', 'props'));
            end 
            %Put the datetime into props on the root of the file.
            h5writeatt("C:\Users\jreznick\Texas Tech University\Quail Call - Joel\QuailKit.m\"+filename, '/','props',fileInfo.Attributes.Value);
            
            %Copy data that we want to keep into the datasets.
            if length(varargin) > 0
                lex = string(varargin{1,1});
                i = 1;
                while (i <= length(varargin))
                    i = i + 1;
                    while i <= length(varargin)
                        lex = string(varargin{1,i});
                        if lex == "spgram"
                            segments = 2300;
                            for c = 1:length(fileInfo.Groups)
                                SizeDSSpgram = fileInfo.Groups(c).Datasets(3).Dataspace.Size;
                                sizeNewFile = [1 SizeDSSpgram(2)];
                                for j = 1:segments:floor(SizeDSSpgram(1)/segments)
                                    if j < SizeDSSpgram(1) 
                                        spgram = h5read(obj.filepath,"/c"+c+"/"+lex+"/",[sizeNewFile(1) 1],[segments SizeDSSpgram(2)]);
                                        h5write(filename, "/c"+c+"/"+lex+"/", spgram, [sizeNewFile(1) 1],[segments SizeDSSpgram(2)]);
                                        sizeNewFile(1) = sizeNewFile(1) + j;
                                    end
                                end
                            end    
                            clear spgram;
                        elseif lex == "audio"
                            for c = 1:length(fileInfo.Groups)
                                audio = h5read(obj.filepath,"/c"+c+"/"+lex+"/");
                                h5write(filename,"/c"+c+"/"+lex+"/", audio);
                            end
                            clear audio;
                        elseif lex == "raw"
                            for c = 1:length(fileInfo.Groups)
                                raw = h5read(obj.filepath,"/c"+c+"/"+lex+"/");
                                h5write(filename,"/c"+c+"/"+lex+"/", raw);
                            end
                            clear raw;
                        else
                            break;
                        end
                        i = i+1;
                    end
                end
            end
            
            %copy file into SQL folder
            copyfile(filename,obj.filepath);
            delete(filename)
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
