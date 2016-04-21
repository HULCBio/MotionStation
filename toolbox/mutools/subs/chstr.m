% function out = chstr(in)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = chstr(in)
 for i=0:9
  if ~isempty(in)
    tmp = int2str(i);
    in = in(find(in ~= tmp));
  end
 end
 if isempty(in)
  out = 0;
 elseif strcmp(in,'.')
  out = 0;
 elseif strcmp(in,'e+')
  out = 0;
 elseif strcmp(in,'e-')
  out = 0;
 elseif strcmp(in,'.e+')
  out = 0;
 elseif strcmp(in,'.e-')
  out = 0;
 else
  out = 1;
 end
%
%