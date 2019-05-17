if false
    d=HTdataAccess([],'query','select name, stream_id from dbo.data','cellarray');
    d(:,3)=repmat({false},size(d,1),1);
end
conn = database('QuailKit','QuailKit','Q123456789');
for i=1:size(d,1)
    obj=JRdata('',fullfile('Z:','QuailKit','data',d{i,1}),40,[0,10000,10],0.08);
    k=0;
    while ~d{i,3}
        k=k+1;
        try
            [s,f, t] = obj.get((k-1)*10, k*10, 'spgram','1');
        catch
            break
        end
        calls = SHdet(s,f,t,291,0.525,0.296,false);
        if ~isempty(calls)
            calls.data_id=repmat(d{i,2},size(calls,1),1);
            calls.channel=ones(size(calls,1),1);
            sqlwrite(conn,'detection_SHTM2018',calls);
        end
    end
    fprintf('done with %s, %d percent completed\n',d{i,1},i/size(d,1));
    d{i,3}=true;
end