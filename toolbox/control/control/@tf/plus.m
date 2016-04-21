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

%   Author(s): A. Potvin, 3-1-94,  P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.20.4.1 $  $Date: 2002/11/11 22:22:13 $

% Effect on other properties
% InputName and OutputName are kept if they are the same
% UserData and Notes are deleted.

% Ensure both operands are TF
sys1 = tf(sys1);
sys2 = tf(sys2);

% Check dimensions and detect scalar addition  sys1 + sys2 
% with sys2  SISO  (expanded as  sys1 + sys2*ones(sys1) )
sizes1 = size(sys1.num);
sizes2 = size(sys2.num);
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
      % Perform scalar expansion
      sys2 = repsys(sys2,sizes1(1:2));
      sizes2(1:2) = sizes1(1:2);
   end
end

% Check dimension consistency
if ~isequal(sizes1(1:2),sizes2(1:2)),
   error('In SYS1+SYS2, systems must have same number of inputs and outputs.');
elseif ~isequal(sizes1(3:end),sizes2(3:end)),
   if length(sizes1)>2 & length(sizes2)>2,
      error('In SYS1+SYS2, arrays SYS1 and SYS2 must have compatible dimensions.')
   elseif length(sizes1)>2,
      % ND expansion of SYS2
      sys2.num = repmat(sys2.num,[1 1 sizes1(3:end)]);
      sys2.den = repmat(sys2.den,[1 1 sizes1(3:end)]);
   else
      % ND expansion of SYS1
      sys1.num = repmat(sys1.num,[1 1 sizes2(3:end)]);
      sys1.den = repmat(sys1.den,[1 1 sizes2(3:end)]);
   end
end   

% LTI property management
sflags = [isstatic(sys1) , isstatic(sys2)];
if any(sflags),
   % Adjust sample time of static gains to avoid unwarranted clashes
   % RE: static gains are regarded as sample-time free
   [sys1.lti,sys2.lti] = sgcheck(sys1.lti,sys2.lti,sflags);
end

% Use try/catch to keep errors at top level
sys = tf;
try
   [sys.lti,sys1,sys2] = ltiplus(sys1.lti,sys2.lti,sys1,sys2);
catch
   rethrow(lasterror)
end


% Perform addition
sizes = size(sys1.num);
num = cell(sizes);
den = cell(sizes);

for i=1:prod(sizes),
   [n,d] = sisoplus(sys1.num{i},sys1.den{i},sys2.num{i},sys2.den{i});
   if ~any(n),
      num{i} = 0;   den{i} = 1;
   else
      % Eliminate leading zeros generated, e.g., in s^2+s
      [num{i},den{i}] = ndorder(n,d);
   end
end
sys.num = num;
sys.den = den;

% Set Variable property
sys.Variable = varpick(sys1.Variable,sys2.Variable,getst(sys.lti));



