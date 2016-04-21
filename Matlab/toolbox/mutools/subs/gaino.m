% function ff = gaino(out,gain,ff,startloc,sysloc)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function ff = gaino(out,gain,ff,startloc,sysloc)
for i=1:length(out)
 ff(i+startloc,sysloc+out(i)) = ff(i+startloc,sysloc+out(i)) + gain;
end