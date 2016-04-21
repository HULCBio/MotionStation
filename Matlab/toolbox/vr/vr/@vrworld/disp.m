function disp(W)
%DISP Display a VRWORLD array.
%   DISP(W) displays a world array in a standard format.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2004/03/02 03:08:13 $ $Author: batserve $


% print variable values
for i=1:numel(W)
  if isvalid(W(i))
    wdf = get(W(i), {'Description', 'FileName'});
    fprintf('\t%s (%s)\n', wdf{:});     %#ok wdf is expanded cell array
  else
    fprintf('\t<invalid>\n');
  end
end
