function Sys = parallel(Sys1,Sys2,inp1,inp2,out1,out2)
%PARALLEL  Parallel interconnection of two LTI models.
%   Requires the Control Systems Toolbox
%
%                          +------+
%            w1 ---------->|      |----------> z1
%                          | MOD1 |
%                   u1 +-->|      |---+ y1
%                      |   +------+   |
%             u ------>+              O------> y
%                      |   +------+   |
%                   u2 +-->|      |---+ y2
%                          | MOD2 |
%            w2 ---------->|      |----------> z2
%                          +------+
%
%   MOD = PARALLEL(MOD1,MOD2,IN1,IN2,OUT1,OUT2) connects the two 
%   IDmodels MOD1 and MOD2 in parallel such that the inputs 
%   specified by IN1 and IN2 are connected and the outputs specified
%   by OUT1 and OUT2 are summed.  The resulting LTI model MOD maps 
%   [v1;u;v2] to [z1;y;z2].  The vectors IN1 and IN2 contain indexes 
%   into the input vectors of MOD1 and MOD2, respectively, and define 
%   the input channels u1 and u2 in the diagram.  Similarly, the 
%   vectors OUT1 and OUT2 contain indexes into the outputs of these 
%   two systems. 
%
%   The resulting model is always an IDSS object.
%
%   If IN1,IN2,OUT1,OUT2 are jointly omitted, PARALLEL forms the 
%   standard parallel interconnection of MOD1 and MOD2 and returns
%          MOD = MOD2 + MOD1 .
%
%   NOTE: PARALLEL  only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%   
%   See also APPEND, SERIES, FEEDBACK, LTIMODELS.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2001/04/06 14:22:16 $



ni = nargin;
Sys1.CovarianceMatrix=[];
Sys2.CovarianceMatrix=[];
if ni==2,
   Sys = Sys1('m') + Sys2('m');
   return
elseif ni~=6,
   error('Wrong number of arguments (must be 2 or 6).');
end

SSys1 = ss(Sys1('m'));
SSys2 = ss(Sys2('m'));
SSys = parallel(SSys1,SSys2,inp1,inp2,out1,out2);
Sys = idss(SSys);
