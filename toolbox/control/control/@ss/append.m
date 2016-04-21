function sys = append(varargin)
%APPEND  Group LTI models by appending their inputs and outputs.
%
%   SYS = APPEND(SYS1,SYS2, ...) produces the aggregate system
% 
%                 [ SYS1  0       ]
%           SYS = [  0   SYS2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND concatenates the input and output vectors of the LTI
%   models SYS1, SYS2,... to produce the resulting model SYS.
%
%   If SYS1,SYS2,... are arrays of LTI models, APPEND returns an LTI
%   array SYS of the same size where 
%      SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...) .
%
%   See also SERIES, PARALLEL, FEEDBACK, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/10 06:02:23 $


% Initialize APPEND operation
sys = ss(varargin{1});
A = sys.a;   B = sys.b;  
C = sys.c;   D = sys.d;
E = sys.e;
sflag = isstatic(sys);  % 1 if SYS is a static gain
 
% Incrementally build resulting system
for j=2:nargin,
   sysj = ss(varargin{j});
   
   % Check dimension compatibility
   sizes = size(D);
   sj = size(sysj.d);
   if length(sj)>2 & length(sizes)>2 & ~isequal(sj(3:end),sizes(3:end)),
      error('Arrays SYS1 and SYS2 must have compatible dimensions.')
   end
   
   % LTI property management   
   sfj = isstatic(sysj);
   if sflag | sfj,
      % Adjust sample time of static gains to prevent clashes
      % RE: static gains are regarded as sample-time free
      [sys.lti,sysj.lti] = sgcheck(sys.lti,sysj.lti,[sflag sfj]);
   end
   sflag = sflag & sfj;
   try
      sys.lti = append(sys.lti,sysj.lti);
   catch
      rethrow(lasterror)
   end
   
   % Append state-space realizations
   [E,e] = ematchk(E,A,sysj.e,sysj.a);
   [A,B,C,D,E] = ssops('append',A,B,C,D,E,sysj.a,sysj.b,sysj.c,sysj.d,e);
   sys.StateName = [sys.StateName ; sysj.StateName];
end
   
% Store result
sys.a = A;
sys.b = B;
sys.c = C;
sys.d = D;
sys.e = ematchk(E);

% Adjust state names
Nx = size(sys,'order');
if length(Nx)>1 | Nx~=length(sys.StateName),
   % Uneven number of states: delete state names
   sys.StateName = repmat({''},[max(Nx(:)) 1]);
end
