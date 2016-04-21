function [sl,area] = pdetridi(p,t)
%PDETRIDI Side lengths and areas of triangles.

%       J. Oppelstrup 10-24-94.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:08 $

[dum,nel ] = size(t);
dx = zeros(3,nel);
dy = zeros(3,nel);
sl = zeros(3,nel);
for j = 1:3,
   j1 = rem(j ,3)+1;
   j2 = rem(j1,3)+1;
   dx(j,:) = p(1,t(j1,:)) - p(1,t(j2,:));
   dy(j,:) = p(2,t(j1,:)) - p(2,t(j2,:));
   sl(j,:) = sqrt(dx(j,:).*dx(j,:) + dy(j,:).*dy(j,:));
   end;
area = 0.5*abs(dx(1,:).*dy(2,:) - dx(2,:).*dy(1,:));

