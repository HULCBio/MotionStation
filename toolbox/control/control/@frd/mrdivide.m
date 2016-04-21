function sys = mrdivide(sys1,sys2)
%MLDIVIDE  Right division for LTI models.
%
%   SYS = MRDIVIDE(SYS1,SYS2) is invoked by SYS=SYS1/SYS2
%   and is equivalent to SYS = SYS1*INV(SYS2).
%
%   See also MLDIVIDE, INV, MTIMES, LTIMODELS.

%   Author(s): S. Almy, A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2002/11/11 22:21:27 $


try
   % Simplify delays when SYS1 is SISO and delayed
   if isa(sys1,'lti') & isa(sys2,'lti')
      [sys1,sys2] = simpdelay(sys1,sys2);
   end
   
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
   
   %Remove remaining delays from SYS2 before inverting
   sys2 = delay2z(sys2);
   
   sizes1 = size(sys1.ResponseData);
   sizes2 = size(sys2.ResponseData);
   if all(sizes1(1:2)==1) &  sizes2(1)~=1,
      % SYS1 is SISO
      scalarMult = 1;
      ioSizes = sizes2(1:2);
   elseif all(sizes2(1:2)==1) & sizes1(2)~=1,
      scalarMult = 2;
      ioSizes = sizes1(1:2);
   else
      scalarMult = 0;
      ioSizes = [sizes1(1),sizes2(1)];
   end

   % Check I/O size consistency
   if sizes2(1)~=sizes2(2)
      error('Cannot invert non-square system.');
   elseif ~scalarMult && sizes1(2)~=sizes2(1),
      error('In SYS1/SYS2, systems must have compatible dimensions.');
   end
   
   % Check and harmonize array sizes
   [sys1,sys2] = CheckArraySize(sys1,sys2);
   
   % Check frequency vector compatibility (give priority to units of rad/s)
   sys = sys1;
   [sys.Frequency,sys.Units] = ...
      freqcheck(sys1.Frequency,sys1.Units,sys2.Frequency,sys2.Units);
   
   % Invert LTI parent of SYS2
   sys2.lti = inv(sys2.lti);
   
   % LTI property management
   sflags = [isstatic(sys1) , isstatic(sys2)];
   if any(sflags),
      % Adjust sample time of static gains to avoid unwarranted clashes
      % RE: static gains are regarded as sample-time free
      [sys1.lti,sys2.lti] = sgcheck(sys1.lti,sys2.lti,sflags);
   end
   [sys.lti,sys1,sys2] = ltimult(sys1.lti,sys2.lti,sys1,sys2,scalarMult);
   
   % Compute response
   sizes = size(sys1.ResponseData);
   sys.ResponseData = zeros([ioSizes,sizes(3:end)]);
   for k = 1:prod(sizes(3:end))
      [L,U,P] = lu(sys2.ResponseData(:,:,k));
      if rcond(U)<10*eps
         error('Cannot invert FRD model with singular frequency response.');
      elseif scalarMult==1
         sys.ResponseData(:,:,k) = sys1.ResponseData(:,:,k) * (U\(L\P));
      else
         sys.ResponseData(:,:,k) = ((sys1.ResponseData(:,:,k)/U)/L)*P;
      end
   end
   
catch
   rethrow(lasterror)
end

