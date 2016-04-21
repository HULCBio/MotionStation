function sys = feedback(sys1,sys2,varargin)
%FEEDBACK  Feedback connection of two LTI models. 
%
%   SYS = FEEDBACK(SYS1,SYS2) computes an LTI model SYS for
%   the closed-loop feedback system
%
%          u --->O---->[ SYS1 ]----+---> y
%                |                 |           y = SYS * u
%                +-----[ SYS2 ]<---+
%
%   Negative feedback is assumed and the resulting system SYS 
%   maps u to y.  To apply positive feedback, use the syntax
%   SYS = FEEDBACK(SYS1,SYS2,+1).
%
%   SYS = FEEDBACK(SYS1,SYS2,FEEDIN,FEEDOUT,SIGN) builds the more
%   general feedback interconnection:
%                      +--------+
%          v --------->|        |--------> z
%                      |  SYS1  |
%          u --->O---->|        |----+---> y
%                |     +--------+    |
%                |                   |
%                +-----[  SYS2  ]<---+
%
%   The vector FEEDIN contains indices into the input vector of SYS1
%   and specifies which inputs u are involved in the feedback loop.
%   Similarly, FEEDOUT specifies which outputs y of SYS1 are used for
%   feedback.  If SIGN=1 then positive feedback is used.  If SIGN=-1 
%   or SIGN is omitted, then negative feedback is used.  In all cases,
%   the resulting LTI model SYS has the same inputs and outputs as SYS1 
%   (with their order preserved).
%
%   If SYS1 and SYS2 are arrays of LTI models, FEEDBACK returns an LTI
%   array SYS of the same dimensions where 
%      SYS(:,:,k) = FEEDBACK(SYS1(:,:,k),SYS2(:,:,k)) .
%
%   See also LFT, PARALLEL, SERIES, CONNECT, LTIMODELS.

%   P. Gahinet  6-26-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/10 06:12:53 $

ni = nargin;
error(nargchk(2,5,ni));

% Convert both arguments to ZPK
sys1 = zpk(sys1);
sys2 = zpk(sys2);

% Compute closed-loop ZPK model
try
   if issiso(sys1) & issiso(sys2)
      % SISO case
      try 
         % Try SS first
         sys = zpk(feedback(ss(sys1),ss(sys2),varargin{:}));
      catch
         % Switch to TF if improper or algebraic loop
         sys = zpk(feedback(tf(sys1),tf(sys2),varargin{:}));
      end
   else
      if isproper(sys1) & isproper(sys2)
         sys = zpk(feedback(ss(sys1),ss(sys2),varargin{:}));
      else
         error('FEEDBACK cannot handle improper MIMO zero-pole-gain models.')
      end
   end
catch
   % algebraic loop error
   rethrow(lasterror)
end

% Determine adequate Variable & DispForm

[sys.DisplayFormat,sys.Variable] = dispVarFormatPick(sys1.Variable,sys2.Variable,sys1.DisplayFormat,sys2.DisplayFormat,getst(sys.lti));

