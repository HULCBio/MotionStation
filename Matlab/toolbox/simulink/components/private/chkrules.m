function [isDiscretizable,discFcn] = chkrules(block, theRules)
%CHKRULES checks if a block is discretizable and return the discretization function
%
%   [ISDISCRETIZABLE,DISCFCN] = CHKRULES(BLOCK,THERULES)
%

% $Revision: 1.5 $ $Date: 2002/03/30 16:10:42 $
% Copyright 1990-2002 The MathWorks, Inc.

isDiscretizable = 0;
discFcn         = '';
for k = 1:length(theRules)
  theRule = theRules{k};
  isThisRule = 1;
  err = 0;
  i = 1;
  while i <= length(theRule) - 1 & err == 0
    try  
      if ~feval(theRule{i}{2},get_param(block,theRule{i}{1}),theRule{i}{3})
        isThisRule = 0;
        err = 1;
      end
    catch
      isThisRule = 0;
    end
    i = i+1;
  end
  if isThisRule
    isDiscretizable = 1;
    discFcn = theRule{length(theRule)};
    break;
  end
end

%end chkRule

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% haselement - test if a string expression  contains another string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = haselement(thestr, ele)

if(ischar(thestr))
    if(isempty(findstr(thestr, ele)))
        ret = 0;
    else
        ret = 1;
    end
else %cell array
    if(isempty(strmatch(ele, thestr)))
        ret = 0;
    else
        ret = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkWSVariables - check the sample time in MaskWSVariables (for LTI
% block)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = checkWSVariables(wsvars, var)

ret = 0;
for k = 1:length(wsvars),
    tt = wsvars(k);
    if(strcmpi(tt.Name, var) & tt.Value == 0)
        ret = 1;
        break;
    end
end

%end checkWSVariables

% [EOF] chkrules.m