function [par,status] = findnan(mt,ms)
% FINDNAN  finds the parameters that correspond to NaN's

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2001/04/06 14:22:21 $

par = []; status = [];

for kk=1:length(mt)
   mtr = mt{kk}.';
   msr = ms{kk}.';
   msr = msr(:);
   mtr = mtr(:);
   nr  = find(isnan(msr));
   nri = find(~isnan(msr));
   if ~isempty(nri) & any(abs(mtr(nri)-msr(nri))>100*eps)
      status = 1;
   end
   par=[par; mtr(nr)];
end
