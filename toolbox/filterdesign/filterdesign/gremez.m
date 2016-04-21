function [h,err,res] = gremez(order, ff1, aa, varargin)
%GREMEZ Generalized Parks-McClellan FIR filter design.
%   GREMEZ is obsolete.  GREMEZ still works but may be removed in the future.
%   Use FIRGR instead.
%
%   See also FIRGR, FIRPM.

%   Author(s): D. Shpak

%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.28.4.3 $  $Date: 2004/04/12 23:25:34 $ 

%   References:
%     Shpak, D. and A. Antoniou, A Generalized Remez Method for the Design
%     of FIR Digital filters, IEEE Trans. Circ. & Sys, vol 37, No 2, 1990.

if (nargin < 3)
    error('Incorrect number of input arguments.')
end

[h,err,res] = firgr(order, ff1, aa, varargin{:});

