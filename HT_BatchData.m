addpath('JR_QuailKit');
path="Z:\QuailKit";
d=dir(fullfile(path,'audio'));
for i=1:length(d)
    if ~d(i).isdir
        n=erase(d(i).name,'.wav');
        JR_Data(fullfile(d(i).folder,d(i).name),fullfile(path,'data',[n,'.h5']),40,0:10:10000,0.8);
    end
end