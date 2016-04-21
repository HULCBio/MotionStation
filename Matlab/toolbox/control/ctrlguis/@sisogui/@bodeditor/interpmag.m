function Magi = interpmag(Editor,W,Mag,Wi)
%INTERPMAG  Interpolates magnitude data in the visual units.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 04:56:29 $

% RE: MAG and MAGI are expressed in abs units. The interpolation occurs
%     in abs or log scale depending on the mag. scale and units

if strcmp(Editor.Axes.XScale,'log')
   W = log2(W);
   nz = (Wi>0);
   Wi(nz) = log2(Wi(nz));
   Wi(~nz) = -Inf;
end

if strcmp(Editor.Axes.YUnits{1},'abs') & ...
      strcmp(Editor.Axes.YScale{1},'linear')
   % Interpolate natural magnitude
   Magi = interp1(W,Mag,Wi);
else
   % Interpolate log of magnitude
   Magi = pow2(interp1(W,log2(Mag),Wi));
end
