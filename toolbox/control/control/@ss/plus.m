function sys = plus(sys1,sys2)
%PLUS  Addition of two LTI models
%
%   SYS = PLUS(SYS1,SYS2) performs SYS = SYS1 + SYS2.
%   Adding LTI models is equivalent to connecting 
%   them in parallel.
%
%   If SYS1 and SYS2 are two arrays of LTI models, their
%   addition produces an LTI array SYS with the same
%   dimensions where the k-th model is the sum of the
%   k-th models in SYS1 and SYS2:
%      SYS(:,:,k) = SYS1(:,:,k) + SYS2(:,:,k) .
%
%   See also PARALLEL, MINUS, UPLUS, LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.20 $  $Date: 2002/04/10 06:00:57 $

% Effect on other properties
% InputName and OutputName are kept if they are the same
% UserData and Notes are deleted.

% Ensure both operands are SS
sys1 = ss(sys1);
sys2 = ss(sys2);

% Check dimensions and detect scalar addition  sys1 + sys2 
% with sys2  SISO  (expanded as  sys1 + sys2*ones(sys1) )
sizes1 = size(sys1);
sizes2 = size(sys2);
if all(sizes1(1:2)==1) & any(sizes2(1:2)~=1),
   % SYS1 is SISO (scalar addition)
   if any(sizes2==0),
      % Scalar + Empty = Empty
      sys = sys2;   return
   else
      % Perform scalar expansion
      sys1 = repsys(sys1,sizes2(1:2));
      sizes1(1:2) = sizes2(1:2);
   end
   
elseif all(sizes2(1:2)==1) & any(sizes1(1:2)~=1),
   % SYS2 is SISO
   if any(sizes1==0),
      % Scalar + Empty = Empty
      sys = sys1;   return
   else
      sys2 = repsys(sys2,sizes1(1:2));
      sizes2(1:2) = sizes1(1:2);
   end
   
end

% Check dimension consistency
if ~isequal(sizes1(1:2),sizes2(1:2)),
   error('In SYS1+SYS2, systems must have same number of inputs and outputs.');
elseif length(sizes1)>2 & length(sizes2)>2 & ...
        ~isequal(sizes1(3:end),sizes2(3:end)),
   error('In SYS1+SYS2, arrays SYS1 and SYS2 must have compatible dimensions.')
end

% LTI property management
sflags = [isstatic(sys1) , isstatic(sys2)];
if any(sflags),
   % Adjust sample time of static gains to avoid unwarranted clashes
   % RE: static gains are regarded as sample-time free
   [sys1.lti,sys2.lti] = sgcheck(sys1.lti,sys2.lti,sflags);
end

% Use try/catch to keep errors at top level
sys = ss;
try
   [sys.lti,sys1,sys2] = ltiplus(sys1.lti,sys2.lti,sys1,sys2);
catch
   rethrow(lasterror)
end

% Perform addition
[e1,e2] = ematchk(sys1.e,sys1.a,sys2.e,sys2.a);
[sys.a,sys.b,sys.c,sys.d,e] = ssops('add',sys1.a,sys1.b,sys1.c,sys1.d,e1,...
                                          sys2.a,sys2.b,sys2.c,sys2.d,e2);
sys.e = ematchk(e);
sys.StateName = [sys1.StateName ; sys2.StateName];

% Adjust state names
Nx = size(sys,'order');
if length(Nx)>1 | Nx~=length(sys.StateName),
   % Uneven number of states: delete state names
   sys.StateName = repmat({''},[max(Nx(:)) 1]);
end

% If result has I/O delays, minimize number of I/O delays and of 
% input vs output delays
% Note: state time shift is immaterial in the presence of I/O delays
sys.lti = mindelay(sys.lti,'iodelay');
