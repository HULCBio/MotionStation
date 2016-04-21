% function  [reenter] = looptst(ord,cn);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function  [reenter] = looptst(ord,cn);

reenter = 1;
if nargin == 2
  if strcmp('cn',cn);
    if isstr(ord)
      if strcmp('drawmag',ord)
        reenter = 0;
      end
    elseif ~(isempty(ord) | (ord<0) | (floor(ord) ~= ceil(ord)))
      reenter = 0;
    end
  else
    reenter = 1;
  end
else
  if isstr(ord)
    if strcmp('drawmag',ord)
      reenter = 0;
    end
  elseif ~(isempty(ord) | (floor(ord) ~= ceil(ord)))
    reenter = 0;
  end
end

