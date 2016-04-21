function [ac,bc,cc,dc] = cloop(a,b,c,d,e,f)
%   CLOOP is obsolete, use FEEDBACK instead.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%CLOOP  Close unity feedback loops.
%   [Ac,Bc,Cc,Dc] = CLOOP(A,B,C,D,SIGN) produces a state-space model
%   of the closed-loop system obtained by feeding all the outputs of
%   the system to all the inputs.  If SIGN = 1 then positive feedback
%   is used.  If SIGN = -1 then negative feedback is used.  In all 
%   cases, the resulting system has all the inputs and outputs of the
%   original model.
%                            -->O-->[System]--+--->
%                               |             |
%                               +-------------+
%
%   [Ac,Bc,Cc,Dc] = CLOOP(A,B,C,D,OUTPUTS,INPUTS) produces the closed
%   loop system obtained by feeding the specified outputs into the 
%   specified outputs.  The vectors OUTPUTS and INPUTS contain indexes
%   into the outputs and inputs of the system respectively.  Positive
%   feedback is assumed. To close with negative feedback, use negative
%   values in the vector INPUTS.
%
%   [NUMc,DENc] = CLOOP(NUM,DEN,SIGN) produces the SISO closed loop 
%   system in transfer function form obtained by unity feedback with
%   the sign SIGN.
%
%   See also: PARALLEL, SERIES, and FEEDBACK.

%   Clay M. Thompson 6-26-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:34:55 $

error(nargchk(2,6,nargin));

% --- Determine which syntax is being used. ---

if (nargin == 2)   % T.F. form w/o sign -- Assume negative feedback
  [num,den] = tfchk(a,b); sgn = -1;
end
if (nargin == 3)   % Transfer function form with sign
  [num,den] = tfchk(a,b); sgn=sign(c);
end

% --- Form closed loop T.F. system ---
if (nargin == 2)|(nargin == 3)
  ac = num; bc = den - sgn*num;

elseif (nargin >= 4)  % State space systems
  [msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);
  [ny,nu] = size(d);
  if (nargin == 4)    % System w/o sign -- Assume negative feedback
    outputs = 1:ny; inputs = [1:nu]; sgn = -ones(1,length(inputs));
  end
  if (nargin == 5)    % State space form with sign
    outputs = 1:ny; inputs = [1:nu]; sgn = sign(e)*ones(1,length(inputs));
  end
  if (nargin == 6)    % State space form w/selection vectors
    outputs=e; inputs=abs(f); sgn=sign(f);
  end

  % --- Form Closed Loop State-space System ---

  nin = length(inputs); nout = length(outputs);
  if nin ~= nout,
    error('The number of feedback inputs and outputs are not equal');
  end
  [nx,na] = size(a);

  % Form feedback column and row, deal with nonzero D22
  S = [a,b;c,d];
  Bu = S(:,[nx+inputs]); Cy = S([nx+outputs],:);
  if ~isempty(Cy)
    Cy(sgn==-1,:)=-Cy(sgn==-1,:);  % Get ready for negative feedback
    E = eye(nout) - Cy(:,[nx+inputs]);    % E=(I-D22)
    Cy = E\Cy;
    
    Sc = S + Bu*Cy;   % Close Loop

    % Extract closed loop system
    ac = Sc(1:nx, 1:nx);
    bc = Sc(1:nx, nx+1:nx+nu);
    cc = Sc(nx+1:nx+ny, 1:nx);
    dc = Sc(nx+1:nx+ny, nx+1:nx+nu);
  else
    ac=a; bc=b; cc=c; dc=d;
  end
end
