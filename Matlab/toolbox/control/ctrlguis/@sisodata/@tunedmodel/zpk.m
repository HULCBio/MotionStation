function Comp = zpk(CompData,varargin)
%ZPK   Get ZPK model of tunable model.
%
%   SYS = ZPK(MODEL) returns the zero/pole/gain representation SYS of MODEL.
% 
%   SYS = ZPK(MODEL,'normalized') extracts the normalized zero/pole/gain
%   representation where the ZPK gain has been replaced by its sign.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:54:25 $
[Z,P] = getpz(CompData);
if nargin==1
   Comp = zpk(Z,P,getzpkgain(CompData),CompData.Ts);
else
   Comp = zpk(Z,P,getzpkgain(CompData,'sign'),CompData.Ts);
end
   
     
