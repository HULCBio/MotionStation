function Sys = series(Sys1,Sys2,outputs1,inputs2)
%SERIES  Series interconnection of the two IDMODELS.
%   Requires the Control Systems Toolbox.
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        | MOD2 |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  | MOD1 |
%                  |      |---> z1
%                  +------+
%
%   MOD = SERIES(MOD1,MOD2,OUTPUTS1,INPUTS2) connects two IDMODELS
%   MOD1 and MOD2 in series such that the outputs of MOD1 specified by
%   OUTPUTS1 are connected to the inputs of MOD2 specified by INPUTS2.  
%   The vectors OUTPUTS1 and INPUTS2 contain indices into the outputs 
%   and inputs of MOD1 and MOD2, respectively.  The resulting
%   IDMODEL MOD is an IDSS object and maps u1 to y2.
%
%   If OUTPUTS1 and INPUTS2 are omitted, SERIES connects MOD1 and MOD2
%   in cascade and returns
%                     MOD = MOD2 * MOD1 .
%
%   NOTE: SERIES only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%
%   See also APPEND, PARALLEL, FEEDBACK.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:22:17 $


ni = nargin;
Sys1.CovarianceMatrix=[];
Sys2.CovarianceMatrix=[];
if ni==2,
   Sys = Sys1('m')*Sys2('m');
   return
elseif ni~=4,
   error('Wrong number of arguments (must be 2 or 6).');
end

SSys1 = ss(Sys1('m'));
SSys2 = ss(Sys2('m'));
SSys = series(SSys1,SSys2,outputs1,inputs2);
Sys = idss(SSys);
