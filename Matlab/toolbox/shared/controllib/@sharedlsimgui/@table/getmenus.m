function out1 = getmenus(h)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:58 $

nummenus = length(h.menulabels);
if nummenus > 0
	out1 = javaArray('java.lang.String',nummenus);
	for k=1:nummenus
            out1(k) = java.lang.String(h.menulabels{k});
	end
else % This function must return a valid string
    out1 = javaArray('java.lang.String',1);
    out1(1) = java.lang.String('');
end
