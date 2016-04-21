function hout = copy(h)
% Copy method for metadata objects.
%
%   Author(s): J.G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:29:29 $
hout = hds.metadata;
hout.Units = h.Units;
if ~isempty(h.Interpolation)
   hout.Interpolation = copy(h.Interpolation);
end
