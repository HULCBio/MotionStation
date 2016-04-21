function x = capture(f)
%CAPTURE Capture a Virtual Reality figure into a RGB image.
%   CAPTURE(F) captures a figure into a TrueColor RGB image that can be 
%   displayed by IMAGE.
%
%   See also IMAGE.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2004/04/06 01:11:08 $ $Author: batserve $

xraw = vrsfunc('CaptureFigure', f.handle);
x = permute(xraw(:,:,end:-1:1), [3 2 1]);
