function Hd = calattice(varargin)
%CALATTICE Coupled-allpass lattice.
%   Hd = DFILT.CALATTICE(K1,K2,BETA) constructs a discrete-time
%   coupled-allpass lattice filter object with K1 as lattice coefficients in
%   the first allpass, K2 as lattice coefficients in the second allpass, and
%   scalar BETA.  
%
%   This structure is only available with the Filter Design Toolbox.
%
%   Example:
%     [b,a]=butter(5,.5);
%     [k1,k2,beta]=tf2cl(b,a);
%     Hd = dfilt.calattice(k1,k2,beta)
%
%   See also DFILT/CALATTICEPC.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:59:50 $

Hd = dfilt.calattice(varargin{:}); 
