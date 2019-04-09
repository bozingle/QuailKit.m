d=HT_DataAccess([],'query',[...
    'select name, stream_id from dbo.data',...
    ],'cellarray');
conn = database('QuailKit','QuailKit','Q123456789');
for i=1:size(d,1)
    obj=JR_Data('',fullfile('Z:','QuailKit','data',d{i,1}),40,[0,10000,10],0.08);
    k=0;
    while true
        k=k+1;
        try
            [s,f, t] = obj.get((k-1)*10, k*10, 'spgram','1');
        catch
            break
        end
        calls = SHdet(s,f,t,291,0.296,0.525,false);
        if ~isempty(calls)
            calls.data_id=repmat(d{i,2},size(calls,1),1);
            calls.channel=ones(size(calls,1),1);
            sqlwrite(conn,'detection',calls);
        end
    end
end