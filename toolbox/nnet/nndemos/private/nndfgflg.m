function f=nndfgflg(n)
%NNDFGFLG Neural Network Design utility function.

% NNDFGFLG(N)
%   N - Name of figure (string).
% Returns handle to figure with name N if it exists.
% Returns 0, otherwise.

% Copyright 1994-2003 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.8.2.2 $
% First Version, 8-31-95.

%==================================================================

z = get(0,'children');
for i=1:length(z)
  typ = get(z(i),'type');
  if strcmp(typ,'figure')
    nam = get(z(i),'name');
  if strcmp(nam,n)
    f = z(i);
    return
  end
  end
end

f = 0;
