function L = mpower(sys,k)
%MPOWER  Repeated product of IDMODELS.
%   Requires the Control Systems Toolbox.
%
%   MODm = MPOWER(MOD,K) is invoked by MOD^K where MOD is any 
%   IDMODEL object with the same number of inputs and outputs, 
%   and K must be an integer.  The result is the IDMODEL MODm
%   which is an IDSS object, describing
%     * if K>0, MOD * ... * MOD (K times) 
%     * if K<0, INV(MOD) * ... * INV(MOD) (K times)
%     * if K=0, the static gain EYE(SIZE(MOD)).
%
%   Covariance information is lost in the transformation.
%
%   The noise inputs are first eliminated.
%
%   See also  PLUS, MTIMES.

%    Copyright 1986-2001 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2001/04/06 14:22:16 $

sys.CovarianceMatrix = [];
try
sys1 = ss(sys('m'));
 
catch
  error(lasterr)
end

try
  L = mpower(sys1,k);
  if isa(sys,'idpoly')
    L = idpoly(L);
    else
  L = idss(L);
  end
catch
  error(lasterr)
end
