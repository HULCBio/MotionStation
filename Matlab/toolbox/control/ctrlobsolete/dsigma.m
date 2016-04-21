function [svout,w] = dsigma(varargin)
%DSIGMA Singular value frequency response of discrete-time linear systems.
%   DSIGMA(A,B,C,D,Ts) (or optional SIGMA(SS_,Ts) in RCT) produces a 
%       singular value plot of matrix:   -1
%                    G(w) = C(exp(jwT)I-A) B + D 
%   as a function of frequency.  The singular values are an extension
%   of Bode magnitude response for MIMO system.  The frequency range 
%       and number of points are chosen automatically. For square systems, 
%       DSIGMA(A,B,C,D,Ts,'inv') produces the singular values of the inverse 
%       matrix     -1                    -1      -1
%             G (w) = [ C(exp(jwT)I-A) B + D ]
%   DSIGMA(A,B,C,D,Ts,W) or DSIGMA(A,B,C,D,Ts,W,'inv') use the user-
%   supplied frequency vector W which must contain the frequencies, in
%   radians/sec, at which the singular value response is to be 
%   evaluated. Aliasing will occur at frequencies greater than the 
%   Nyquist frequency (pi/Ts).  When invoked with left hand arguments,
%           [SV,W] = DSIGMA(A,B,C,D,Ts,...)
%   or  [SV,W] = SIGMA(SS_,Ts,...)    (for Robust Control Toolbox user)
%   returns the frequency vector W and the matrix SV with MIN(NU,NY)
%   columns and length(W) rows, where NU is the number of inputs and
%   NY is the number of outputs.  No plot is drawn on the screen. 
%   The singular values are returned in descending order.
%
%   See also:  SIGMA, LOGSPACE, SEMILOGX, NICHOLS, NYQUIST, BODE.

%   Clay M. Thompson  7-10-90
%   Revised A.Grace 2-12-91, 6-21-92
%   Revised W.Wang 7/24/92
%   Revised P. Gahinet 5-7-96
%   Revised M. Safonov 9-12-97 & 4-18-98
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.16.4.2 $  $Date: 2004/04/10 23:14:53 $


%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])

% Initialize variables
ni = nargin;
no = nargout;
nag1=0;  % becomes nonzero if rct mksys system present in input

if ni==0,
   eval('dexresp(''dsigma'',1)'), 
   return
end

rct = license('test','Robust_Toolbox'); % 1 if rct installed, else 0

% Expand pre-LTI Robust Toolbox MKSYS system, if present 
% if Robust Toolbox is installed --- M.G. Safonov 9/12/97
% and it is a non-LTI Robust Toolbox MKSYS system of type 'ss'
if ni<5 & rct & feval('issystem',varargin{1}),   
   % eval(mkargs('(a,b,c,d,Ts,w,invflag)',ni,'ss'))
   [emsg,nag1,xsflag,Ts,a,b,c,d,Ts,w,invflag]=mkargs5x('ss',varargin); error(emsg);
   ni=nag1;
   if ni<5, error('Not enough inputs'),end
else
  a=varargin{1}; b=varargin{2}; c=varargin{3}; d=varargin{4}; Ts=varargin{5};
  if ni>6,
    invflag=varargin{7}; w=varargin{6}; Ts=varargin{5};
  elseif ni>5,
    w=varargin{6}; Ts=varargin{5};
  end
end

% Check inputs
error(nargchk(5,7,ni));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
if ~(length(d) | (length(b) &  length(c)))
    return;
end


% Trap pre-1990 rct syntax & convert to newer 
% sigma(a,b,c,d,Ts,w,ty) syntax  --- M.G. Safonov 9/12/97
%  If Ts is a valid OLDTY (1,2,3,4) 
if rct & ni>6 & isa(Ts,'double') & length(Ts)==1 & any(Ts==[1 2 3 4]),
   % Determine if INVFLAG is a valid TY (0,1,2,3)
   % If INVFLAG is a valid TY (0,1, 2, or 3)) 
   if length(invflag)==1 & any(invflag==[0 1 2 3]),
      % slightly ambiguous syntax could be either dsigma(sys,OLDTY,w) 
      % with scalar w(= 1 or 2 or 3) or could be dsigma(sys,w,TY) 
      % with scalar w (=1 or 2 or 3 or 4).
      warning('Syntax dsigma(sys,integer1,w,integer2) could be ambiguous.')
      disp('         MATLAB assumes that you intend dsigma(sys,Ts,w,ty).')
   % if INVFLAG is a valid Ts, but NOT a valid TY and not a string
   elseif isa(invflag,'double') & length(invflag)==1 & invflag>=0,     
      % then it must be old rct sigma(a,b,c,d,oldty,w,Ts) syntax
      % which is equivalent to sigma(ss(a,b,c,d,Ts),w,oldty-1),
      temp=invflag;
      invflag=Ts-1;
      Ts=temp;
   end
end


% Determine status of invflag
if ni==5, 
    invflag = 0;
    w = [];
elseif (ni==6)
    if (isstr(w)),
        invflag = w;
        w = [];
        [ny,nu] = size(d);
        if (ny~=nu), error('The state space system must be square when using ''inv''.'); end
    else
        invflag = 0;
    end
else
    if isstr(w),
      invflag = 1;
    end
    [ny,nu] = size(d);
end

if isstr(invflag) & length(strmatch('inv',invflag)), 
   invflag = 1;
   if (ny~=nu),
      error('The state space system must be square when using ''inv''.');
   end
end

% Call @lti/sigma for computations
if no==0,
  sigma(ss(a,b,c,d,Ts),w,invflag)
else
  % Return output
  [svout,w] = sigma(ss(a,b,c,d,Ts),w,invflag);
end

% end dsigma
