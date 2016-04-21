function [L,sys1,sys2] = ltimult(L1,L2,sys1,sys2,ScalarMult)
%LTIMULT  LTI property management for LTI model product.
% 
%   [SYS.LTI,SYS1,SYS2] = LTIMULT(SYS1.LTI,SYS2.LTI,SYS1,SYS2,SCALARMULT)
%   sets the LTI properties of the model SYS = SYS1 * SYS2.
%   In discrete time, conflicting delays are removed using DELAY2Z 
%   (SYS1 and SYS2 are then updated accordingly).
%
%   See also TF/MTIMES.

%   Author(s):  P. Gahinet, 5-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.16.4.1 $  $Date: 2002/11/11 22:21:46 $

% Sample time management
% RE: Assumes that the sample time of static gains 
%     has already been adjusted
%
if (L1.Ts==-1 & L2.Ts>0) | (L2.Ts==-1 & L1.Ts>0),
   % Discrete/discrete with one unspecified sample time
   Ts = max(L1.Ts,L2.Ts);
elseif L1.Ts~=L2.Ts,
   error('In SYS1*SYS2, both models must have the same sample time.')
else
   Ts = L1.Ts;
end

% Other LTI properties: handle various types of multiplication
switch ScalarMult
case 1
   % Scalar multiplication sys1 * SYS2 (Keep Notes and UserData)
   L = L2;
   
   % Multiply all entries of SYS2 by time delay in SYS1
   L.InputDelay = ndops('add',L.InputDelay,L1.InputDelay);
   L.OutputDelay = ndops('add',L.OutputDelay,L1.OutputDelay);
   L.ioDelay = ndops('add',L.ioDelay,L1.ioDelay);
      
case 2
   % Scalar multiplication SYS1 * sys2 (Keep Notes and UserData)
   L = L1;
   
   % Multiply all entries of SYS1 by time delay in SYS2
   L.InputDelay = ndops('add',L.InputDelay,L2.InputDelay);
   L.OutputDelay = ndops('add',L.OutputDelay,L2.OutputDelay);
   L.ioDelay = ndops('add',L.ioDelay,L2.ioDelay);
   
otherwise
   % Regular multiplication
   L = L2;  % Takes care of InputName,Group,Delay
   L.Notes = {};
   L.UserData = [];
   
   % Output names, groups, delays
   L.OutputName = L1.OutputName; 
   L.OutputGroup = L1.OutputGroup;
   L.OutputDelay = L1.OutputDelay;
   
   % I/O delays
   Dm1 = ndops('add',L1.ioDelay,repmat(ndops('trans',L1.InputDelay),[size(L1.ioDelay,1) 1]));
   sd1 = size(Dm1);
   Dm2 = ndops('add',L2.ioDelay,repmat(L2.OutputDelay,[1 size(L2.ioDelay,2)]));  
   sd2 = size(Dm2);
   
   % SYS1*SYS2 is representable as a delay system if DxDy([Dm1;-Dm2'])=0
   Dm12 = ndops('vcat',Dm1(:,:,:),-permute(Dm2(:,:,:),[2 1 3]));
   d = diff(diff(Dm12,1,1),1,2);
   
   if sd1(2)==0,
      Dm = zeros(sd1(1),sd2(2));
      
   elseif all(abs(d(:))<=1e3*eps*max(Dm12(:))),
      % Product is representable as LTI model with delays
      sd1 = [sd1 ones(1,length(sd2)-length(sd1))];
      sd2 = [sd2 ones(1,length(sd1)-length(sd2))];
      psizes = [sd1(1) sd2(2) max(sd1(3:end),sd2(3:end))];
      Dm = reshape(ndops('add',Dm1(:,ones(1,sd2(2)),:),Dm2(ones(1,sd1(1)),:,:)),psizes);
      
   elseif Ts | isa(sys1,'frd')
      % Discrete-time case: extract parts of Dm1,Dm2 satisfying DxDy([Dm1;-Dm2'])=0. 
      % Other delays mapped to z=0
      % RE: Blows away LTI properties of sys1 and sys2 (no longer used in MTIMES)
      a = min(Dm1,[],2); 
      b = min(Dm2,[],1);
      Dm = ndops('add',repmat(a,[1 sd2(2)]),repmat(b,[sd1(1) 1]));
      sys1.InputDelay = zeros(sd1(2),1);
      sys1.OutputDelay = zeros(sd1(1),1);
      sys1.ioDelay = ndops('add',Dm1,-repmat(a,[1 sd1(2)]));
      sys1 = delay2z(sys1);
      sys2.InputDelay = zeros(sd2(2),1);
      sys2.OutputDelay = zeros(sd2(1),1);
      sys2.ioDelay = ndops('add',Dm2,-repmat(b,[sd2(1) 1]));
      sys2 = delay2z(sys2);
      
   else
      error('Product SYS1*SYS2 cannot be represented using a single delay for each I/O pair.')
   end
      
   % Set I/O delays to DM
   L.ioDelay = tdcheck(Dm);
   
end


% Set sample time field
L.Ts = Ts;


