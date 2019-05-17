path='Z:\QuailKit\audio';
files=dir(fullfile(path,'*.wav'));
for i = 1:length(files)
    file=fullfile(path,files(i).name);
    f=audioread(file,[1,1]);
    audiowrite(file,f,1200)
end