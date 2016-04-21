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

%   Author: P. Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.26 $  $Date: 2002/04/10 06:12:16 $

% Effect on other properties
% InputName and OutputName are kept if they are the same
% UserData and Notes are deleted.

% Ensure both operands are ZPK
sys1 = zpk(sys1);
sys2 = zpk(sys2);

% Check dimensions and detect scalar addition
sizes1 = size(sys1.k);
sizes2 = size(sys2.k);
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
      sys2.z = repmat(sys2.z,[1 1 sizes1(3:end)]);
      sys2.p = repmat(sys2.p,[1 1 sizes1(3:end)]);
      sys2.k = repmat(sys2.k,[1 1 sizes1(3:end)]);
   else
      % ND expansion of SYS1
      sys1.z = repmat(sys1.z,[1 1 sizes2(3:end)]);
      sys1.p = repmat(sys1.p,[1 1 sizes2(3:end)]);
      sys1.k = repmat(sys1.k,[1 1 sizes2(3:end)]);
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
sys = zpk;
try
   [sys.lti,sys1,sys2] = ltiplus(sys1.lti,sys2.lti,sys1,sys2);
catch
   rethrow(lasterror)
end

% Perform addition
sizes = size(sys1.k);
z = cell(sizes);
p = cell(sizes);
k = zeros(sizes);

for i=1:prod(sizes),
   [z{i},p{i},k(i)] = sisoplus(sys1.z{i},sys1.p{i},sys1.k(i),...
                               sys2.z{i},sys2.p{i},sys2.k(i));
end
sys.z = z;
sys.p = p;
sys.k = k;

% Set Variable property
[sys.DisplayFormat,sys.Variable] = dispVarFormatPick(sys1.Variable,sys2.Variable,sys1.DisplayFormat,sys2.DisplayFormat,getst(sys.lti));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [z,p,k] = sisoplus(z1,p1,k1,z2,p2,k2)
%SISOPLUS  Addition of SISO ZPK models
%
%   [Z,P,K] = SISOPLUS(Z1,P1,K1,Z2,P2,K2) performs
%   the SISO addition
%
%      (Z,P,K) = (Z1,P1,K1) + (Z2,P2,K2)
%
%   where Z* and P* are column vectors.


% Discard dynamics when gain is zero
if k1==0,
   z1 = zeros(0,1);  p1 = zeros(0,1);
elseif k2==0,
   z2 = zeros(0,1);  p2 = zeros(0,1);
end
p = [p1 ; p2];

% Determine if both model are proper
allproper = (length(z1)<=length(p1)) & (length(z2)<=length(p2));

% Compute ZPK representation of the SISO sum 
if allproper
   % All models are proper: use a state-space-based algorithm
   % for adding ZPK models
   [a1,b1,c1,d1] = comden(k1,{z1},p1);
   [a2,b2,c2,d2] = comden(k2,{z2},p2);
   [a,b,c,d] = ssops('add',a1,b1,c1,d1,[],a2,b2,c2,d2,[]);
   [z,k] = getzeros(a,b,c,d,[]);

else
   % Some models are improper: use a TF-based algorithm
   % for adding ZPK models
   % Compute numerator of the sum
   nr1 = k1 * poly([z1 ; p2]);
   nr2 = k2 * poly([z2 ; p1]);
   kd = length(nr2)-length(nr1);
   n = [zeros(1,kd) nr1] + [zeros(1,-kd) nr2];

   % Compute ZPK data 
   z = roots(n);
   k = n(length(n)-length(z));
end

% Delete dynamics if gain is zero
if k==0,
   z = zeros(0,1);
   p = zeros(0,1);
end

