function [svout,w] = sigma(varargin)
%SIGMA  Singular value plot of LTI models.
%
%   SIGMA(SYS) produces a singular value (SV) plot of the frequency 
%   response of the LTI model SYS (created with TF, ZPK, SS, or FRD).  
%   The frequency range and number of points are chosen automatically.  
%   See BODE for details on the notion of frequency in discrete time.
%
%   SIGMA(SYS,{WMIN,WMAX})  draws the SV plot for frequencies ranging
%   between WMIN and WMAX (in radian/second).
%
%   SIGMA(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the frequency response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   SIGMA(SYS,W,TYPE) or SIGMA(SYS,[],TYPE) draws the following
%   modified SV plots depending on the value of TYPE:
%          TYPE = 1     -->     SV of  inv(SYS)
%          TYPE = 2     -->     SV of  I + SYS
%          TYPE = 3     -->     SV of  I + inv(SYS) 
%   SYS should be a square system when using this syntax.
%
%   SIGMA(SYS1,SYS2,...,W,TYPE) draws the SV response of several LTI
%   models SYS1,SYS2,... on a single plot.  The arguments W and TYPE
%   are optional.  You can also specify a color, line style, and marker 
%   for each system, as in  sigma(sys1,'r',sys2,'y--',sys3,'gx').
%   
%   SV = SIGMA(SYS,W) and [SV,W] = SIGMA(SYS) return the singular 
%   values SV of the frequency response (along with the frequency 
%   vector W if unspecified).  No plot is drawn on the screen. 
%   The matrix SV has length(W) columns and SV(:,k) gives the
%   singular values (in descending order) at the frequency W(k).
%
%   For details on Robust Control Toolbox syntax, type HELP RSIGMA.
%
%   See also BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, LTIMODELS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%SIGMA Singular value frequency response of continuous linear systems.
%	SIGMA(A,B,C,D) (or optional SIGMA(SS_) in RCT) produces a singular 
%       value plot of matrix    -1
%                G(jw) = C(jwI-A) B + D 
%	as a function of frequency.  The singular values are an extension
%	of Bode magnitude response for MIMO systems.  The frequency range
%	and number of points are chosen automatically.  For square systems, 
%       SIGMA(A,B,C,D,'inv') produces the singular values of the inverse 
%       matrix     -1               -1      -1
%                 G (jw) = [ C(jwI-A) B + D ]
%
%	SIGMA(A,B,C,D,W) or SIGMA(A,B,C,D,W,'inv') uses the user-supplied
%	frequency vector W which must contain the frequencies, in 
%	radians/sec, at which the singular value response is to be 
%	evaluated. When invoked with left hand arguments,
%	    [SV,W] = SIGMA(A,B,C,D,...)
%	or  [SV,W] = SIGMA(SS_,...)      (for Robust Control Toolbox user)
%	returns the frequency vector W and the matrix SV with as many 
%	columns	as MIN(NU,NY) and length(W) rows, where NU is the number
%	of inputs and NY is the number of outputs.  No plot is drawn on 
%	the screen.  The singular values are returned in descending order.
%
%	See also: LOGSPACE,SEMILOGX,NICHOLS,NYQUIST and BODE.

%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%	Revised P. Gahinet 5-7-96
%	Revised M. G. Safonov 9-12-97 & 4/18/98
%	Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.26.4.2 $  $Date: 2004/04/10 23:13:55 $


% Initialize variables

ni = nargin;
no = nargout;
nag1=0;  % becomes nonzero if rct mksys system present in input

if ni==0,
   error('Not enough input arguments.')
end

rct = license('test','Robust_Toolbox'); % 1 if rct installed, else 0

% Expand pre-LTI Robust Toolbox MKSYS system, if present 
% if Robust Toolbox is installed --- M.G. Safonov 9/12/97
% and it is a non-LTI Robust Toolbox MKSYS system of type 'ss'
if ni<4 & rct & feval('issystem',varargin{1}),   
   [emsg,nag1,xsflag,Ts,a,b,c,d,w,invflag]=mkargs5x('ss',varargin); error(emsg);
   ni=nag1;
   if ni<4, error('Not enough inputs.'),end
else
  Ts=0;
  a=varargin{1}; b=varargin{2}; c=varargin{3}; d=varargin{4};
  if ni > 5
    invflag = varargin{6}; w=varargin{5};
  elseif ni > 4,
    w=varargin{5};
  end
end

% Check inputs 
error(nargchk(4,6,ni));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
% Detect null systems
if ~(length(d) | (length(b) &  length(c)))
  return
end

% Trap pre-1990 syntax & convert to newer 
% sigma(a,b,c,d,w,ty) syntax  --- M.G. Safonov 9/12/97
%  If W is a valid OLDTY (1,2,3,4) 
if rct & ni>5 & isa(w,'double') & length(w)==1 & any(w==[1 2 3 4]),
   % Determine if INVFLAG is a valid TY (0,1,2,3)
   % If INVFLAG is a valid TY (0,1, 2, or 3)) 
   if isa(invflag,'double') & length(invflag)==1 & any(invflag==[0 1 2 3]),
      % slightly ambiguous syntax could be either sigma(sys,OLDTY,w) 
      % with scalar w(= 1 or 2 or 3) or could be sigma(sys,w,TY) 
      % with scalar w (=1 or 2 or 3 or 4).
      warning('Syntax sigma(sys,integer1,integer2) could be ambiguous.')
      msg =   '         MATLAB assumes that you intend sigma(sys,w,ty).';
      disp(msg)
   % if INVFLAG is NOT a valid TY and not a string
   elseif ~isstr(invflag),     
      % then it must be old rct sigma(a,b,c,d,oldty,w) syntax 
      % which is equivalent to sigma(ss(a,b,c,d),w,oldty-1)
      temp=w;
      w=invflag;
      invflag=temp-1;
   end
end


% Determine status of invflag (0 for normal, 1 for 'inv')
if ni==4, 
  invflag = 0;
  w = [];
elseif (ni==5)
  if (isstr(w)),
    invflag = w;
    w = [];
    [ny,nu] = size(d);
    if (ny~=nu), error('The state space system must be square when using ''inv''.'); end
  else
    invflag = 0;
  end
else
  [ny,nu] = size(d);
end

if isstr(invflag) & length(strmatch('inv',invflag)), 
  invflag = 1; 
  if (ny~=nu),
    error('The state space system must be square when using ''inv''.')
  end
end


% Call @lti/sigma for computations
if no==0,
  sigma(ss(a,b,c,d,Ts),w,invflag)
else
  % Return output
  [svout,w] = sigma(ss(a,b,c,d,Ts),w,invflag);
end

% end sigma.m
