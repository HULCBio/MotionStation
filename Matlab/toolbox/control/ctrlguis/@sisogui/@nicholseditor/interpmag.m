function Magi = interpmag(Editor, W, Mag, Wi)
%INTERPMAG  Interpolates magnitude data in the visual units.
%           MAG and MAGI are expressed in Absolute units.
%           The interpolation occurs in abs or log scale depending
%           on the magnitude scale and units.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2002/04/10 05:04:27 $

% Interpolate log of magnitude
Magi = pow2(interp1(W, log2(Mag), Wi));
