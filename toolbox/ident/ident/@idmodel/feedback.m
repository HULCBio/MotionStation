function sys = feedback(sys1,sys2,varargin)
%FEEDBACK  Feedback connection of two IDMODEL models.
%   Requires the Control Systems Toolbox.
%
%   MOD = FEEDBACK(MOD1,MOD2) computes an IDSS MOD for
%   the closed-loop feedback system
%
%          u --->O---->[ MOD1 ]----+---> y
%                |                 |           y = MOD * u
%                +-----[ MOD2 ]<---+
%
%   Negative feedback is assumed and the resulting system MOD 
%   maps u to y.  To apply positive feedback, use the syntax
%   MOD = FEEDBACK(MOD1,MOD2,+1).
%
%   MOD = FEEDBACK(MOD1,MOD2,FEEDIN,FEEDOUT,SIGN) builds the more
%   general feedback interconnection:
%                      +--------+
%          v --------->|        |--------> z
%                      |  MOD1  |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[  MOD2  ]<---+
%
%   The vector FEEDIN contains indices into the input vector of MOD1
%   and specifies which inputs u are involved in the feedback loop.
%   Similarly, FEEDOUT specifies which outputs y of MOD1 are used for
%   feedback.  If SIGN=1 then positive feedback is used.  If SIGN=-1 
%   or SIGN is omitted, then negative feedback is used.  In all cases,
%   the resulting LTI model MOD has the same inputs and outputs as MOD1 
%   (with their order preserved).
%
%   NOTE: FEEDBACK only deals with the measured input channels.
%   To interconnect also the noise input channels, first convert
%   them to measured channels by NOISECNV.
%
%   The covariance information is lost.
%
%   See also APPEND, PARALLEL, SERIES.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:22:16 $

ni = nargin;
sys1.CovarianceMatrix=[];
sys2.CovarianceMatrix=[];

try
SSys1 = ss(sys1('m'));
SSys2 = ss(sys2('m'));
catch
  error(lasterr)
end

try
if nargin ==2
  SSys = feedback(SSys1,SSys2);
else
  SSys = feedback(SSys1,SSys2,varargin{:});
end
catch
  error(lasterr)
end

sys = idss(SSys);
