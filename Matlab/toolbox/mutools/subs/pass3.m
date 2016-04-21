
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out,err] = pass3(j,od,odl)
  var = od(j,1:odl(j));
  err = 0;
  out = [];
  commas = find(var==',');
  commas = [0 commas length(var)+1];
  if length(find(diff(commas)==1)) > 0
    err = 1;
  else
    for jj=1:length(commas)-1
    chunk = var(commas(jj)+1:commas(jj+1)-1);
      colons = find(chunk==':');
      if length(colons) == 0
        exp = ['value =' chunk ';'];
        eval(exp);
        out = [out ; value];
      elseif length(colons) == 1
        exp = ['schtart = ' chunk(1:colons(1)-1) ';'];
        eval(exp);
        exp = ['schtop = ' chunk(colons(1)+1:length(chunk)) ';'];
        eval(exp)
        tmp = schtart:schtop;
        out = [out ; tmp'];
      else
        err = 2;
      end
    end
  end
%
%
