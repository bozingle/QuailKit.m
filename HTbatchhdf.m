path="Z:\QuailKit";
d=dir(fullfile(path,'audio'));
for i=1:length(d)
    if ~d(i).isdir && ~isempty(strfind(d(i).name,'2018'))
        n=erase(d(i).name,'.wav');
        file=fullfile(d(i).folder,d(i).name);
        hfile=fullfile(path,'data',[n,'.h5']);
        if ~isfile(hfile)
            JRdata(file,hfile,40,[0,5000,10],0.08);
        end
        f=audioread(file,[1,1]);
        audiowrite(file,f,1200);
    end
end