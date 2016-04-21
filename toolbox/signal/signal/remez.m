function [h,err,res] = remez(order, ff, aa, varargin)
%REMEZ Parks-McClellan optimal equiripple FIR filter design.
%   REMEZ is obsolete.  REMEZ still works but may be removed in the future.
%   Use FIRPM instead.
%
%   See also FIRPM.

%   Author(s): L. Shure, 3-27-87
%          L. Shure, 6-8-88, revised
%          T. Krauss, 3-17-93, fixed hilbert bug in m-file version
%          T. Krauss, 3-2-97, consolidated grid generation, function-function

%        D. Shpak, 7-15-99, incorporated C-mex firpm function
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.21.4.2 $  $Date: 2004/04/13 00:19:00 $

%   References:
%     [1] "Programs for Digital Signal Processing", IEEE Press
%          John Wiley & Sons, 1979, pg. 5.1-1.
%     [2] "Selected Papers in Digital Signal Processing, II",
%          IEEE Press, 1976, pg. 97.

nargchk(3,6,nargin);

[h,err,res] = firpm(order, ff, aa, varargin{:});

% EOF

