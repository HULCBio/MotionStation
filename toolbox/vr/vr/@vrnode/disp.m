function disp(N)
%DISP Display a VRNODE array.
%   DISP(N) displays a VRNODE array in a standard format.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/04/01 13:49:19 $ $Author: Xjhouska $


% print variable values
for i=1:numel(N)
  if isvalid(N(i))
    PW = get(N(i), 'World');
    fprintf('\t%s (%s) [%s]\n', N(i).Name, get(N(i),'Type'), get(PW,'Description'));
  else
    fprintf('\t<invalid>\n');
  end
end
