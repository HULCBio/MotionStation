function [yred] = skipdata(y,ptskip)
%SKIPDATA Skip "ptskip" of points in a data array or matrix.
%
% [YRED] = SKIPDATA(Y,PTSKIP) produces a reduced size vector (or matrix)
%  of "y" by skipping "ptskip" points that one specifies.
%
%          Note: 1) Y vector (or matrix) should store data COLUMNWISE
%                2) The first point of the data is always saved

% R. Y. Chiang & M. G. Safonov 10/93
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

[m,n] = size(y);

if (1+ptskip > m)
   yred = y(1,:);
   return
end

ind = fix(m/(ptskip+1));
for i = 1:n
   ytemp = zeros(ptskip+1,ind);
   ytemp(:) = y(1:(1+ptskip)*ind,i);
   if (ind*(1+ptskip) < m)
      yskip = [ytemp(1,:)';y((1+ptskip)*ind+1,i)];
   else
      yskip = ytemp(1,:)';
   end
   if (i == 1)
      yred = yskip;
   else
      yred = [yred yskip];
   end
end
%
% ------- End of SKIPDATA.M % RYC/MGS %