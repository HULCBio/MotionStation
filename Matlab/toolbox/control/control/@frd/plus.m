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

%   Author(s): S. Almy, A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2002/11/11 22:21:29 $

% Effect on other properties
% InputName and OutputName are kept if they are the same
% UserData and Notes are deleted.

try
   % Ensure both operands are FRD
   if ~isa(sys1,'frd')
      if isa(sys1,'double') & ndims(sys1) < 3
         sys1 = repmat(sys1,[1 1 length(sys2.Frequency)]);
      end
      sys1 = frd(sys1,sys2.Frequency,'units',sys2.Units);
   elseif ~isa(sys2,'frd')
      if isa(sys2,'double') & ndims(sys2) < 3
         sys2 = repmat(sys2,[1 1 length(sys1.Frequency)]);
      end
      sys2 = frd(sys2,sys1.Frequency,'units',sys1.Units);
   end
   
   % Detect scalar addition  sys1 + sys2 with sys2  SISO  
   % (expanded as  sys1 + sys2*ones(sys1) )
   sizes1 = size(sys1.ResponseData);
   sizes2 = size(sys2.ResponseData);
   if all(sizes1(1:2)==1) & any(sizes2(1:2)~=1),
      % SYS1 is SISO (scalar addition)
      if any(sizes2==0),
         % Scalar + Empty = Empty
         sys = sys2;
         return
      else
         % Perform scalar expansion
         sys1 = repsys(sys1,sizes2(1:2));
         sizes1(1:2) = sizes2(1:2);
      end
   elseif all(sizes2(1:2)==1) & any(sizes1(1:2)~=1),
      % SYS2 is SISO
      if any(sizes1==0),
         % Scalar + Empty = Empty
         sys = sys1;
         return
      else
         % Perform scalar expansion
         sys2 = repsys(sys2,sizes1(1:2));
         sizes2(1:2) = sizes1(1:2);
      end
   end
   
   % Check I/O dimension consistency
   if ~isequal(sizes1(1:2),sizes2(1:2)),
      error('In SYS1+SYS2, systems must have same number of inputs and outputs.');
   end
   
   % Check and harmonize array sizes
   [sys1,sys2] = CheckArraySize(sys1,sys2);
   
   % Initialize output
   sys = sys1;
   
   % Check frequency vector compatibility (give priority to units of rad/s)
   [sys.Frequency,sys.Units] = ...
      freqcheck(sys1.Frequency,sys1.Units,sys2.Frequency,sys2.Units);
   
   % LTI property management
   sflags = [isstatic(sys1) , isstatic(sys2)];
   if any(sflags),
      % Adjust sample time of static gains to avoid unwarranted clashes
      % RE: static gains are regarded as sample-time free
      [sys1.lti,sys2.lti] = sgcheck(sys1.lti,sys2.lti,sflags);
   end
   
   % Use try/catch to keep errors at top level 
   % RE: takes care of delays
   [sys.lti,sys1,sys2] = ltiplus(sys1.lti,sys2.lti,sys1,sys2);
   
   % Perform addition
   sys.ResponseData = sys1.ResponseData + sys2.ResponseData;
   
catch
   rethrow(lasterror)
end
