% Construct and transform an array of circles, and
% display it over the original and transformed images.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2003/05/03 17:53:35 $

gray = 0.65 * [1 1 1];
for u = 0:64:320
    for v = 0:64:256
        theta = (0 : 32)' * (2 * pi / 32);
        uc = u + 20*cos(theta);
        vc = v + 20*sin(theta);
        [xc,yc] = tformfwd(T,uc,vc);
        figure(h1); line(uc,vc,'Color',gray);
        figure(h2); line(xc,yc,'Color',gray);
    end
end
