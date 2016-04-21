function disp(F)
%DISP Display a VRFIGURE array.
%   DISP(F) displays a VRFIGURE array in a standard format.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/04/01 13:49:18 $ $Author: Xjhouska $


% print variable values
for i=1:numel(F)
  if isvalid(F(i))
    fprintf('\t%s\n', get(F(i), 'Name'));
  else
    fprintf('\t<invalid>\n');
  end
end
