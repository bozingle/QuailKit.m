classdef JRmapMake
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
          
        function obj=JRmapMake(h,key, data, distance,micDataPaths)
            R = 6.3781*(10.^6);
            mLoc = [];
            for i = 1:size(micDataPaths,2)
                micData = readtable(micDataPaths(i));
                temp = []
                if char(micData{1,4}) == 'N'
                    temp(1) = mean(micData{:,3});
                else
                    temp(1) = - mean(micData{:,3});
                end
                if char(micData{1,6}) == 'E'
                    temp(2) =  mean(micData{:,5});
                else
                    temp(2) = - mean(micData{:,5});
                end
                temp(3) = 0;
                temp(4) =  mean(micData{:,9});
                mLoc = [mLoc; temp];
            end
            
            %Find max long min long
            meanLong =  mean(data(:,2));
            obj.lonlim = [meanLong - rad2deg(distance/R) meanLong + rad2deg(distance/R)];
            
            %Find max lat min lat
            meanLat = mean(data(:,1));
            obj.latlim = [meanLat - rad2deg(distance/R) meanLat + rad2deg(distance/R)];
            
            h.XLim=obj.lonlim;
            h.YLim=obj.latlim;
            hold on;
            plot_google_map('Axis',h,'MapScale', 1, 'maptype', 'satellite', 'showLabels', 0, 'APIKey', key, 'AutoAxis', 1);
            plot(h,data(:,2)', data(:,1)', '.r',...
            mLoc(:,2)', mLoc(:,1)', 'y.', 'MarkerSize', 20);
            
            hold off;
        end
    end
end

