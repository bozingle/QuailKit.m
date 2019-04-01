
SQL=[
    'SELECT [name], DATEDIFF(millisecond,an.[start], detection.[start])/1000.0 as [start], DATEDIFF(millisecond,an.[start], detection.[end])/1000.0 as [end], a.name as audio_name',...
    'FROM detection inner join data on detection.data_id=data.stream_id inner join audio_data ad on detection.data_id=ad.data_id inner join audio_node an on ad.audio_id=an.audio_id inner join audio a on an.audio_id = a.stream_id',...
    'WHERE DATEDIFF(millisecond,an.[start], detection.[start])/1000.0 >240'];
d=HT_DataAccess([],'query',SQL,'cellarray');

doa=[];
for i =4%:size(d,1)
    obj = JR_Data(fullfile('Z:','QuailKit','audio',d{i,4}),fullfile('Z:','QuailKit','data',d{i,1}),40,0:10:10000,0.8);    
    [s1,f1,t1]=obj.get(d{i,2},d{i,3},'raw','1');
    [s2,f2,t2]=obj.get(d{i,2},d{i,3},'raw','2');
    [s3,f3,t3]=obj.get(d{i,2},d{i,3},'spgram','1');
    R1=cov(s1,s2);
    doa=[doa,rootmusicdoa(R1,1)];
    c=xcorr(s1,s2);
    figure
    plot([-t1(end:-1:2)+min(t1);t1-min(t1)],c);
    a1=audioplayer(s1,24000);
    a2=audioplayer(s2,24000);
    L=size(s1,1);
    ss1 = fft(s1);
    ss1 = ss1(1:L/2+1);
    ss2 = fft(s2);
    ss2 = ss2(1:L/2+1);
    ss1(2:end-1) = 2*ss1(2:end-1);
    ss2(2:end-1) = 2*ss2(2:end-1);
    f = 24000*(0:(L/2))/L;
    figure()
    subplot(2,2,1), plot(f,abs(ss1/L))
    subplot(2,2,2), plot(f,unwrap(angle(ss1)))
    subplot(2,2,3), plot(f,abs(ss2/L))
    subplot(2,2,4), plot(f,unwrap(angle(ss2)))
    figure()
    plot(f, unwrap(angle(ss2))-unwrap(angle(ss1)))
    figure()
    surf(t3,f3,s3','edgecolor','none');view(0,90)
    figure();plot(f, rms(angle(ss2)-angle(ss1)))
end
