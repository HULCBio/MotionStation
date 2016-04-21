function sys = mtimes(sys1,sys2)
%MTIMES  Multiplication of LTI models.
%
%   SYS = MTIMES(SYS1,SYS2) performs SYS = SYS1 * SYS2.
%   Multiplying two LTI models is equivalent to 
%   connecting them in series as shown below:
%
%         u ----> SYS2 ----> SYS1 ----> y 
%
%   If SYS1 and SYS2 are two arrays of LTI models, their
%   product is an LTI array SYS with the same number of
%   models where the k-th model is obtained by
%      SYS(:,:,k) = SYS1(:,:,k) * SYS2(:,:,k) .
%
%   See also SERIES, MLDIVIDE, MRDIVIDE, INV, LTIMODELS.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.28 $  $Date: 2002/04/10 06:12:21 $

% Effect on other properties
% InputName is from sys2, OutputName from sys1
% UserData and Notes are deleted.

% Ensure both operands are ZPK
sys1 = zpk(sys1);
sys2 = zpk(sys2);

% Check dimensions and detect scalar multiplication  
% sys1 * sys2  with sys1 or sys2 SISO 
sizes1 = size(sys1.k);
sizes2 = size(sys2.k);
if all(sizes1(1:2)==1) & sizes2(1)~=1,
   % SYS1 is SISO (scalar multiplication)
   if any(sizes2==0),
      % Scalar * Empty = Empty
      sys = sys2;   return
   else
      ScalarMult = 1;
   end
elseif all(sizes2(1:2)==1) & sizes1(2)~=1,
   % SYS2 is SISO (scalar multiplication)
   if any(sizes1==0),
      % Scalar * Empty = Empty
      sys = sys1;   return
   else
      ScalarMult = 2;
   end
else
   ScalarMult = -(sizes1(2)==1);  % -1 if SIMO * MISO
end


% Check dimensions
if ScalarMult<=0 & sizes1(2)~=sizes2(1),
   error('In SYS1*SYS2, systems must have compatible dimensions.');
elseif ~isequal(sizes1(3:end),sizes2(3:end)),
   if length(sizes1)>2 & length(sizes2)>2,
      error('In SYS1*SYS2, model arrays SYS1 and SYS2 must have compatible dimensions.')
   elseif length(sizes1)>2 & ScalarMult~=2,
      % ND expansion of SYS2
      sys2.z = repmat(sys2.z,[1 1 sizes1(3:end)]);
      sys2.p = repmat(sys2.p,[1 1 sizes1(3:end)]);
      sys2.k = repmat(sys2.k,[1 1 sizes1(3:end)]);
      sizes2 = size(sys2.k);
   elseif length(sizes2)>2 & ScalarMult~=1,
      % ND expansion of SYS1
      sys1.z = repmat(sys1.z,[1 1 sizes2(3:end)]);
      sys1.p = repmat(sys1.p,[1 1 sizes2(3:end)]);
      sys1.k = repmat(sys1.k,[1 1 sizes2(3:end)]);
      sizes1 = size(sys1.k);
   end
end   


% Initialize output
switch ScalarMult,
case 1
   sys = sys2;
case 2
   sys = sys1;
otherwise
   sys = zpk;
end


% LTI property management
sflags = [isstatic(sys1) , isstatic(sys2)];
if any(sflags),
   % Adjust sample time of static gains to avoid unwarranted clashes
   % RE: static gains are regarded as sample-time free
   [sys1.lti,sys2.lti] = sgcheck(sys1.lti,sys2.lti,sflags);
end

% Use try/catch to keep errors at top level
try
   [sys.lti,sys1,sys2] = ltimult(sys1.lti,sys2.lti,sys1,sys2,ScalarMult);
catch
   rethrow(lasterror)
end


% Perform multiplication
switch ScalarMult
case -1
  % SISO*SISO or SIMO*MISO
   ny = sizes1(1);   nu = sizes2(2);
   sizes = [ny nu sizes1(3:end)];
   sys.z = cell(sizes);
   sys.p = cell(sizes);
   sys.k = zeros(sizes);
   
   for k=1:prod(sizes(3:end)),
      i = 1;  j = 1;
      while j<=nu,
         sys.k(i,j,k) = sys1.k(i,1,k) * sys2.k(1,j,k);
         sys.z{i,j,k} = [sys1.z{i,1,k} ; sys2.z{1,j,k}];
         sys.p{i,j,k} = [sys1.p{i,1,k} ; sys2.p{1,j,k}];
         i = i+1;
         if i>ny,  i = 1;  j = j+1;  end
      end
   end
   
case 0
   % Regular MIMO multiplication
   ny = sizes1(1);   nu = sizes2(2);
   sizes = [ny nu sizes1(3:end)];
   sys.z = cell(sizes);
   sys.p = cell(sizes);
   sys.k = zeros(sizes);
   
   % RE: All additions are performed in state space for higher accuracy
   for k=1:prod(sizes(3:end)),
      i = 1;  j = 1;
      while j<=nu,
         % Evaluate the sum of sys1(i,m)*sys2(m,j) for m=1:In1
         [sys.z{i,j,k},sys.p{i,j,k},sys.k(i,j,k)] = ...
                InnerProduct(sys1.z(i,:,k),sys1.p(i,:,k),sys1.k(i,:,k),...
                       sys2.z(:,j,k),sys2.p(:,j,k),sys2.k(:,j,k));
         i = i+1;
         if i>ny,  i = 1;  j = j+1;  end
      end
   end
   
case 1
   % Scalar multiplication sys1 * SYS2 with sys1 SISO
   nsys1 = prod(sizes1(3:end));
   nsys2 = prod(sizes2(3:end));
   for m=1:max(nsys1,nsys2),
      m1 = min(m,nsys1);
      m2 = min(m,nsys2);
      scalz = sys1.z{m1};
      scalp = sys1.p{m1};
      zm = sys2.z(:,:,m2);
      pm = sys2.p(:,:,m2);
      for i=1:prod(sizes2(1:2)),
         zm{i} = [scalz ; zm{i}];
         pm{i} = [scalp ; pm{i}];
      end
      sys.z(:,:,m2) = zm;
      sys.p(:,:,m2) = pm;
      sys.k(:,:,m2) = sys1.k(m1) * sys2.k(:,:,m2);
   end
   
case 2,
   % Scalar multiplication SYS1 * sys2 with sys2 SISO
   nsys1 = prod(sizes1(3:end));
   nsys2 = prod(sizes2(3:end));
   for m=1:max(nsys1,nsys2),
      m1 = min(m,nsys1);
      m2 = min(m,nsys2);
      zm = sys1.z(:,:,m1);
      pm = sys1.p(:,:,m1);
      scalz = sys2.z{m2};
      scalp = sys2.p{m2};
      for i=1:prod(sizes1(1:2)),
         zm{i} = [zm{i} ; scalz];
         pm{i} = [pm{i} ; scalp];
      end
      sys.z(:,:,m1) = zm;
      sys.p(:,:,m1) = pm;
      sys.k(:,:,m1) = sys1.k(:,:,m1) * sys2.k(m2);
   end
      
end


% Variable name & Display format
[sys.DisplayFormat ,sys.Variable] = dispVarFormatPick(sys1.Variable,sys2.Variable,sys1.DisplayFormat,sys2.DisplayFormat,getst(sys.lti));

%%%%%%%%%%%%%%%%%%%%%%%%%%


function [z,p,k] = InnerProduct(z1,p1,k1,z2,p2,k2)
%INNERPRODUCT  Inner product of two vectors of SISO ZPK models
%
%      [Z,P,K] = INNERPRODUCT(Z1,P1,K1,Z2,P2,K2) returns the ZPK
%      representation of the sum
%
%                         POLY(Z1{i})           POLY(Z2{i})
%         SUM  {  K1(i) * ----------- * K2(i) * -----------  }
%                         POLY(P1{i})           POLY(P2{i})
%
%      The inputs Z1,Z2,P1,P2 are cell vectors and K1,K2 are
%      vectors

z1 = z1(:);
p1 = p1(:);
k1 = k1(:);

% Evaluate the products (Z1{m},P1{m},K1(m)) * (Z2{m},P2{m},K2(m))
% Determine if all products are proper, and discard dynamics when 
% gain is zero
ks = k1 .* k2;
inz = find(ks);
allproper = all(cellfun('length',z1(inz))+cellfun('length',z2(inz))<=...
                cellfun('length',p1(inz))+cellfun('length',p2(inz)));
             
             
% Compute ZPK representation of sum{ ks(i)*poly(zs{i})/poly(ps{i}) }
if allproper
   % All models are proper: use a state-space-based algorithm
   % for adding ZPK models
   a = [];  b = zeros(0,1);  c = zeros(1,0);  d = 0;
   p = zeros(0,1);
   for i=inz',
      pi = [p1{i};p2{i}];
      [ai,bi,ci,di] = comden(ks(i),{[z1{i};z2{i}]},pi);
      [a,b,c,d] = ssops('add',a,b,c,d,[],ai,bi,ci,di,[]);
      % Update vector of denominator poles
      p = [p ; pi];
   end
   
   % Compute zeros and gain of resulting state-space model
   [z,k] = getzeros(a,b,c,d,[]);

else
   % Some models are improper: use a TF-based algorithm
   % for adding ZPK models
   num = 0;
   p = zeros(0,1);
   for i=inz',
      pi = [p1{i};p2{i}];
      nr = conv(num,poly(pi));
      nri = ks(i) * poly([z1{i};z2{i};p]);
      kd = length(nr)-length(nri);
      num = [zeros(1,kd) nri] + [zeros(1,-kd) nr];
      % Update vector of denominator poles
      p = [p ; pi];
   end

   % Get zeros and gain
   z = roots(num);
   k = num(length(num)-length(z));

end


% Discard all dynamics if sum has zero gain
if k==0,
   z = zeros(0,1);
   p = zeros(0,1);
end

