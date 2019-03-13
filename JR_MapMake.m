classdef JR_MapMake
    %JR_MAPMAKE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        results
        unit
        image
        key
        recorders
        window
        filepath
        imglon
        imglat
        lonlim
        latlim
    end
    
    methods
        
        function obj = JR_MapMake(key, unit, recordingDateTime)
            mkdir(obj.filepath);
            obj.unit = unit
            obj.key = key;
            
            
%             recordingDateTime = split(recordingDateTime);
%             date = char(recordingDateTime(1)); 
%             time = char(recordingDateTime(2));
%             time2 = split(time,':');
%             min = num2str(str2num(string(time2(2)))+5);
%             if length(min) <= 2
%                 min = "0" + min;
%             end
%             timeFinal = char(string(time2(1))+":"+min+":"+ string(time2(3)));
%             queriedRecorderPos = HT_DataAccess([],'query',...
%             ['SELECT Recorders.[Recorder ID], Statuses.Latitude, Statuses.Longitude',...
%             'FROM Recorders INNER JOIN Statuses ON Recorders.[Recorder ID] = Statuses.[Recorder ID]',...
%             'WHERE (((Statuses.DATE)>#',date,'#) AND ((Statuses.TIME) Between', '"',time,'"',' And ','"',timeFinal,'"','))',...
%             'ORDER BY Recorders.[Recorder ID], Statuses.TIME;'],...
%             'numeric');
            
            ylim([33 34]);
            xlim([-102 -99])
            %Zohar Bar-Yehuda's Static Google Maps API
            [obj.imglon, obj.imglat, obj.image] =  plot_google_map('MapScale', 1, 'maptype', 'satellite', 'showLabels', 0, 'APIKey', obj.key, 'AutoAxis', 1);
        end
        
        function mapMake(obj, data, distance)
            R = 1;
            if obj.unit == 'miles'
                R = 3959;
            elseif obj.unit == 'meters'
                R = 6.3781*(10.^6);
            elseif obj.unit == 'kilometers'
                R = 6.3781*(10.^3);
            end
            %Find max long min long
            meanLong =  mean(data(:,2));
            obj.lonlim = [meanLong - rad2deg(distance/R) meanLong + rad2deg(distance/R)];
            
            %Find max lat min lat
            meanLat = mean(data(:,1));
            obj.latlim = [meanLat - rad2deg(distance/R) meanLat + rad2deg(distance/R)];
            
            hold on;
            figure('Name', "Display Data: lon("+obj.lonlim(1) +", "+obj.lonlim(2)+") lat("+obj.latlim(1) + ", "+obj.latlim(2)+")");
            ylim([min(obj.imglat) max(obj.imglat)]);
            xlim([min(obj.imglon) max(obj.imglon)]);
            imshow(obj.image);
            plot(data(:,2)', data(:,1)' , '.r', 'MarkerSize', 20);
            ylim(obj.latlim);
            xlim(obj.lonlim);
            hold off;
        end
    end
end

