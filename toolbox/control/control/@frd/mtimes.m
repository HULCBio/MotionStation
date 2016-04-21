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

%   Author(s): S. Almy, A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2002/11/11 22:21:28 $

% Effect on other properties
% InputName is from sys2, OutputName from sys1
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
   
   % Detect scalar multiplication  
   sizes1 = size(sys1.ResponseData);
   sizes2 = size(sys2.ResponseData);
   if all(sizes1(1:2)==1) &  sizes2(1)~=1,
      % SYS1 is SISO (scalar multiplication)
      if any(sizes2==0),
         % Scalar * Empty = Empty
         return
      else
         ScalarMult = 1;
      end
   elseif all(sizes2(1:2)==1) & sizes1(2)~=1,
      % SYS2 is SISO (scalar multiplication)
      if any(sizes1==0),
         % Empty * Scalar = Empty
         return
      else
         ScalarMult = 2;
      end
   else
      ScalarMult = 0;
   end
   
   % Check I/O size consistency
   if ~ScalarMult && sizes1(2)~=sizes2(1),
      error('In SYS1*SYS2, systems must have compatible dimensions.');
   end
   
   % Check and harmonize array sizes
   [sys1,sys2] = CheckArraySize(sys1,sys2);
   
   % Check frequency vector compatibility (give priority to units of rad/s)
   sys = sys1;
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
   [sys.lti,sys1,sys2] = ltimult(sys1.lti,sys2.lti,sys1,sys2,ScalarMult);
   
   % Perform multiplication
   sizeResp = size(sys.ResponseData);
   switch ScalarMult
      case 0
         % Regular multiplication
         resp = zeros([sizes1(1) sizes2(2) sizeResp(3:end)]);
         for k=1:prod(sizeResp(3:end))
            resp(:,:,k) = sys1.ResponseData(:,:,k)*sys2.ResponseData(:,:,k);
         end
         
      case 1
         % Scalar multiplication sys1 * SYS2 with sys1 SISO
         resp = zeros(size(sys2.ResponseData));
         for freqIndex = 1:sizeResp(3)
            scalarResp = sys1.ResponseData(:,:,freqIndex);
            for k=1:prod(sizeResp(4:end))
               resp(:,:,freqIndex,k) = scalarResp * sys2.ResponseData(:,:,freqIndex,k);
            end
         end
         
      case 2
         % Scalar multiplication SYS1 * sys2 with sys2 SISO
         resp = zeros(size(sys1.ResponseData));
         for freqIndex = 1:sizeResp(3)
            scalarResp = sys2.ResponseData(:,:,freqIndex);
            for k=1:prod(sizeResp(4:end))
               resp(:,:,freqIndex,k) = scalarResp * sys1.ResponseData(:,:,freqIndex,k);
            end
         end
   end
   
   sys.ResponseData = resp;
   
catch
   rethrow(lasterror)
end
