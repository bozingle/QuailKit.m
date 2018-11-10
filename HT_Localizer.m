function [sources, error] = HT_Localizer(activities)
%HT_LOCALIZER Finds location and time of an incident based on acoustic
%observance in at least 3 points.

%   activities (N by 4 matrix):
%       N: Number of observations
%       4: Latitude, Longtitude, Time, Temperature
%   sources (M by 3 matrix):
%       M: Number of potentially valid localizations.
%       4: Latitude, Longitude, Time, Error

% © 2018 Hanif Tiznobake

c=354.7;
[x,y,~]=geodetic2enu(activities(:,1),activities(:,2),zeros(size(activities,1),1),...
    activities(1,1),activities(1,2),0,referenceEllipsoid('earth'));
t=activities(:,3);
v=nchoosek(1:size(activities,1),3);
sol=[];
syms x0 y0 t0
for i=1:size(v,1)
    eqns=[(x(v(i,1))-x0)^2+(y(v(i,1))-y0)^2-c^2*(t(v(i,1))-t0)^2,...
          (x(v(i,2))-x0)^2+(y(v(i,2))-y0)^2-c^2*(t(v(i,2))-t0)^2,...
          (x(v(i,3))-x0)^2+(y(v(i,3))-y0)^2-c^2*(t(v(i,3))-t0)^2];
    
    struct=solve(eqns,[x0,y0,t0]);
    a=double([struct.x0,struct.y0,struct.t0]);
    if isreal(a)
        sol=[sol;a];
    end
end
sol = sol(sol(:,3)<0,:);
sources = zeros(size(sol,1),4);
[sources(:,1),sources(:,2),~] = ...
     enu2geodetic(sol(:,1),sol(:,2),zeros(size(sol,1),1),...
     activities(1,1),activities(1,2),0,referenceEllipsoid('earth'));
sources(:,3)=sol(:,3);