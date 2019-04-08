addpath('JR_QuailKit');
path="Z:\QuailKit";
d=dir(fullfile(path,'data'));
for i=1:length(d)
    if ~d(i).isdir
        obj=JR_Data("",fullfile(d(i).folder,d(i).name),40,[0,10000,10],0.08);
        k=0;
        while true
            k=k+1;
            [s,f, t] = obj.get((k-1)*10, k*10, 'spgram','1');
            if isempty(s)
                break
            end
            Template=importdata('Template_291.mat');
            Calls = SH_FindCalls(s,f,t,Template,0.296,0.525,false)  
        end
    end
end