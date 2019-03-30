N = 2;
d = 0.5;
elementPos = (0:N-1)*d;
angles = 20;
Nsig = 1;
R2 = sensorcov(elementPos,angles);
doa=rootmusicdoa(R2,Nsig);