function Hd = calatticepc(varargin)
%CALATTICEPC Power-complementary coupled-allpass lattice.
%   Hd = DFILT.CALATTICEPC(K1,K2,BETA) constructs a discrete-time
%   coupled-allpass lattice with power-complementary output object with K1 as
%   lattice coefficients in the first allpass, K2 as lattice coefficients in the
%   second allpas, and scalar BETA.
%
%   This structure is only available with the Filter Design Toolbox.
%
%   Example:
%     [b,a]=butter(5,.5);
%     [k1,k2,beta]=tf2cl(b,a);   
%     Hd = dfilt.calatticepc(k1,k2,beta)
%
%   See also DFILT/CALATTICE.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/11/08 20:10:16 $

Hd = dfilt.calatticepc(varargin{:});