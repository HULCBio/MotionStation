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

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24.4.1 $  $Date: 2002/11/11 22:22:12 $

% Effect on other properties
% InputName is from sys2, OutputName from sys1
% UserData and Notes are deleted.

% Ensure both operands are TF
sys1 = tf(sys1);
sys2 = tf(sys2);

% Check dimensions and detect scalar multiplication  
sizes1 = size(sys1.num);
sizes2 = size(sys2.num);
if all(sizes1(1:2)==1) &  sizes2(1)~=1,
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
      % Empty * Scalar = Empty
      sys = sys1;   return
   else
      ScalarMult = 2;
   end
else
   ScalarMult = 0;
end


% Check dimension consistency
if ~ScalarMult & sizes1(2)~=sizes2(1),
   error('In SYS1*SYS2, systems must have compatible dimensions.');
elseif ~isequal(sizes1(3:end),sizes2(3:end)),
   if length(sizes1)>2 & length(sizes2)>2,
      error('In SYS1*SYS2, model arrays SYS1 and SYS2 must have compatible dimensions.')
   elseif length(sizes1)>2 & ScalarMult~=2,
      % ND expansion of SYS2
      sys2.num = repmat(sys2.num,[1 1 sizes1(3:end)]);
      sys2.den = repmat(sys2.den,[1 1 sizes1(3:end)]);
      sizes2 = size(sys2.num);
   elseif length(sizes2)>2 & ScalarMult~=1,
      % ND expansion of SYS1
      sys1.num = repmat(sys1.num,[1 1 sizes2(3:end)]);
      sys1.den = repmat(sys1.den,[1 1 sizes2(3:end)]);
      sizes1 = size(sys1.num);
   end
end   


% Initialize output
switch ScalarMult,
case 0
   sys = tf;
case 1
   sys = sys2;
case 2
   sys = sys1;
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
case 0
   % Regular multiplication
   ny = sizes1(1);   nu = sizes2(2);
   sizes = [ny nu sizes1(3:end)];
   sys.num = cell(sizes);
   sys.den = cell(sizes);
   
   % Compute each entry
   for k=1:prod(sizes(3:end)),
      i = 1;  j = 1;
      while j<=nu,
         % Initialize num and den for (i,j,k) entry
         nij = 0;
         dij = 1;
         
         % Evaluate sum of sys1(i,k)*sys2(k,j) for k=1:m1
         for m=1:sizes1(2),
            [nij,dij] = sisoplus(nij,dij,conv(sys1.num{i,m,k},sys2.num{m,j,k}),...
                                         conv(sys1.den{i,m,k},sys2.den{m,j,k}));
         end
         
         % Eliminate common leading zeros
         if ~any(nij),
            sys.num{i,j,k} = 0;   sys.den{i,j,k} = 1;
         else
            [sys.num{i,j,k},sys.den{i,j,k}] = ndorder(nij,dij);
         end
         
         i = i+1;
         if i>ny,  i = 1;  j = j+1;  end
      end
   end
   
case 1
   % Scalar multiplication sys1 * SYS2 with sys1 SISO
   nsys1 = prod(sizes1(3:end));
   nsys2 = prod(sizes2(3:end));
   for k=1:max(nsys1,nsys2),
      scalnum = sys1.num{min(k,nsys1)};
      scalden = sys1.den{min(k,nsys1)};
      k2 = min(k,nsys2);
      nk = sys2.num(:,:,k2);
      dk = sys2.den(:,:,k2);
      for i=1:prod(sizes2(1:2)),
         nk{i} = conv(scalnum,nk{i});
         if ~any(nk{i}),
            nk{i} = 0;   dk{i} = 1;
         else
            [nk{i},dk{i}] = ndorder(nk{i},conv(scalden,dk{i}));
         end
      end
      sys.num(:,:,k2) = nk;
      sys.den(:,:,k2) = dk;
   end
   
case 2
   % Scalar multiplication SYS1 * sys2 with sys2 SISO
   nsys1 = prod(sizes1(3:end));
   nsys2 = prod(sizes2(3:end));
   for k=1:max(nsys1,nsys2),
      scalnum = sys2.num{min(k,nsys2)};
      scalden = sys2.den{min(k,nsys2)};
      k1 = min(k,nsys1);
      nk = sys1.num(:,:,k1);
      dk = sys1.den(:,:,k1);
      for i=1:prod(sizes1(1:2)),
         nk{i} = conv(nk{i},scalnum);
         if ~any(nk{i}),
            nk{i} = 0;   dk{i} = 1;
         else
            [nk{i},dk{i}] = ndorder(nk{i},conv(dk{i},scalden));
         end
      end
      sys.num(:,:,k1) = nk;
      sys.den(:,:,k1) = dk;
   end

end

% Variable name
sys.Variable = varpick(sys1.Variable,sys2.Variable,getst(sys.lti));

