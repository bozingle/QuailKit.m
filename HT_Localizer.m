function [location,datetime] = HT_Localizer(observe)
%HT_LOCALIZER Finds location and time of an incident based on acoustic
%observance in at least 3 points.

%   observe (N by 4 matrix):
%       N: Number of microphones
%       4: Latitude, Longtitude, Datetime, Temperature
%   location (1 by 3 vector): [x, y, accuracy]
%       x: Distance from first microphone to the east (meters)
%       y: Distance from first microphone to the north (meters)
%       accuracy: Accuracy (meters)
%   datetime (1 by 2 vector): [t, accuracy]
%       t: Datetime of incidence (datetime)
%       accuracy: Accuracy (datetime)

% © 2018 Hanif Tiznobake

s=331.3;
[x,y,~]=geodetic2enu(observe(:,1),observe(:,2),zeros(size(observe,1),1),...
    observe(1,1),observe(1,2),0,referenceEllipsoid('earth'));
t=observe(:,3)-observe(1,3);
v=nchoosek(1:size(observe,1),3);
sol=[];
syms x0 y0 t0
for i=1:size(v,1)
    eqns=[(x(v(i,1))-x0)^2+(y(v(i,1))-y0)^2-(t(v(i,1))-t0)^2*s^2,...
          (x(v(i,2))-x0)^2+(y(v(i,2))-y0)^2-(t(v(i,2))-t0)^2*s^2,...
          (x(v(i,3))-x0)^2+(y(v(i,3))-y0)^2-(t(v(i,3))-t0)^2*s^2];
    
    struct=solve(eqns,[x0,y0,t0]);
    a=double([struct.x0,struct.y0,struct.t0]);
    if isreal(a)
        sol=[sol;a];
    end
end
sol=sol(sol(:,3)<0,:);
location=[median(sol(:,1:2),1),std(sol(:,1:2),0,1)];
[location(:,1),location(:,2),~] = ...
    enu2geodetic(location(:,1),location(:,2),zeros(size(location,1),1),...
    observe(1,1),observe(1,2),0,referenceEllipsoid('earth'));
datetime=[median(sol(:,3),1),std(sol(:,3),0,1)];
