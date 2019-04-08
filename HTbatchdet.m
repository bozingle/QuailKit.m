addpath('JR_QuailKit');
path="Z:\QuailKit";
d=dir(fullfile(path,'data'));
for i=1:length(d)
    if ~d(i).isdir
        obj=JR_Data("",fullfile(d(i).folder,d(i).name),40,[0,10000,10],0.08);
        k=0;
        Calls=[];
        while true
            k=k+1;
            [s,f, t] = obj.get((k-1)*10, k*10, 'spgram','1');
            if isempty(s)
                break
            end
            Template=importdata('Template_291.mat');
            Calls = [Calls; SHdet(s,f,t,Template,0.296,0.525,false)];
        end
        l=size(Calls,1);
        for i = 1:l
            HT_DataAccess(handles,'query',...
                ['insert into audio_detection([audio_id], [start], [end], [low], [high]) ',...
                'values (''',char(string(Mics{k,4})),...
                ''', ''',datestr(milliseconds(Calls(i,1)*1000)+handles.Data.Date,'yyyy-mm-ddTHH:MM:SS.FFF'),''', ''',datestr(milliseconds(Calls(i,2)*1000)+handles.Data.Date,'yyyy-mm-ddTHH:MM:SS.FFF'),...
                ''', ',char(string(Calls(i,3))),', ',char(string(Calls(i,4))),')'],'cellarray');
        end
    end
end