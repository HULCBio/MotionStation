function sys = horzcat(varargin)
%HORZCAT  Horizontal concatenation of LTI models.
%
%   SYS = HORZCAT(SYS1,SYS2,...) performs the concatenation 
%   operation
%         SYS = [SYS1 , SYS2 , ...]
% 
%   This operation amounts to appending the inputs and 
%   adding the outputs of the LTI models SYS1, SYS2,...
% 
%   See also VERTCAT, STACK, LTIMODELS.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.19 $  $Date: 2002/04/10 06:01:41 $

% Effect on other properties: UserData and Notes are deleted

% Delete empty models
% RE: needed for [[] , sys], guarantees [ss(zeros(2,0)) ; zeros(2,0)] is 4x0
ni = nargin;
EmptyModels = logical(zeros(1,ni));
for i=1:ni,
   sizes = size(varargin{i});
   EmptyModels(i) = ~any(sizes(1:2));
end
varargin(EmptyModels) = [];

% Get number of non empty model
nsys = length(varargin);
if nsys==0,
   sys = ss;  return
end

% Initialize output SYS to first input system
sys = ss(varargin{1});
A = sys.a;   B = sys.b;  
C = sys.c;   D = sys.d;
E = sys.e;
sflag = isstatic(sys);  % 1 if SYS is a static gain

% Concatenate remaining input systems
for j=2:nsys,
   sysj = ss(varargin{j});

   % Check dimension compatibility
   sizes = size(D);
   sj = size(sysj.d);
   if sj(1)~=sizes(1),
      error('In [SYS1 , SYS2], SYS1 and SYS2 must have the same number of outputs.')
   elseif length(sj)>2 & length(sizes)>2 & ~isequal(sj(3:end),sizes(3:end)),
      error('In [SYS1 , SYS2], arrays SYS1 and SYS2 must have compatible dimensions.')
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
      sys.lti = [sys.lti , sysj.lti];
   catch
      rethrow(lasterror)
   end
      
   % Perfom concatenation
   [E,e] = ematchk(E,A,sysj.e,sysj.a);
   [A,B,C,D,E] = ssops('hcat',A,B,C,D,E,sysj.a,sysj.b,sysj.c,sysj.d,e);
   sys.StateName = [sys.StateName ; sysj.StateName];
end
   
% Create result
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

% If result has I/O delays, minimize number of I/O delays and of 
% input vs output delays
% Note: state time shift is immaterial in the presence of I/O delays
sys.lti = mindelay(sys.lti,'iodelay');
