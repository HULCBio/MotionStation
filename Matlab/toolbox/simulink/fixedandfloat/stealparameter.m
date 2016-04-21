function outvalue = stealparameter( curBlock, paramNameStr, invalue );
% STEALPARAMETER used in Fixed Point Autoscaling to get parameters
%   values hidden under one or more layers of masks.
%
%    See also AUTOFIXEXP.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.10 $  
% $Date: 2002/06/17 13:10:40 $

outvalue = invalue;

global FixPtTempGlobal

len = length(FixPtTempGlobal);

iFound = 0;

for i=1:len
    if strcmp(FixPtTempGlobal{i}.Path, curBlock )

      FixPtTempGlobal{i} = setfield(FixPtTempGlobal{i},'Parameters',paramNameStr,'paramValue',invalue);
    
      iFound = i;
      break;
    end
end

if iFound == 0
  FixPtTempGlobal{end+1}.Path = curBlock;

  FixPtTempGlobal{end} = setfield(FixPtTempGlobal{end},'Parameters',paramNameStr,'paramValue',invalue);
end
