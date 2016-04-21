function [num,deno,dnum,dden]=tfdata(th,iu)
%IDMODEL/TFDATA  Transforms IDMODEL model objects to transfer functions.
%
%   [NUM,DEN] = TFDATA(MODEL) returns the numerator(s) and denominator(s) 
%   of the model object MODEL.  For a transfer function with NY 
%   outputs and NU inputs, NUM and DEN are NY-by-NU cell arrays such that
%   NUM{I,J} (note the curly brackets) specifies the transfer 
%   function from input J to output I.   
%  
%   [NUM,DEN,SDNUM,SDDEN] = TFDATA(MODEL) also returns the standard
%   deviations of the numerator and denominator coefficients. 
%   Other properties of MODEL can be accessed with GET or by direct structure-like 
%   referencing (e.g., MODEL.Ts.)
%
%   If MODEL is a time series (NU=0) the transfer functions from
%   the (unnormalized, see HELP NOISECNV) noise source e to the
%   outputs y are returned. There are NY-by-NY such transfer functions.
%  
%   To obtain the noise responses for a system with input, use
%       [NUM,DEN] = TFDATA(MODEL('noise'))
%
%   Use NOISECNV to convert the noise sources to measured channels, with options
%   to include normalizations of noise variances.
%
%   For a SISO model MODEL, the syntax
%       [NUM,DEN] = TFDATA(MODEL,'v')
%   returns the numerator and denominator as row vectors rather than
%   cell arrays.
%
%   See also IDMODEL/SSDATA, IDMODEL/ZPKDATA, IDMODEL/POLYDATA, IDMODEL/FREQRESP
%   and NOISECNV.


%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 2002/02/12 07:34:58 $

if nargin < 1
   disp('Usage: [NUM, DEN] = TFDATA(Model)')
   disp('       [NUM, DEN, SDNUM, SDDEN] = TFDATA(Model)')
   return
end
Ts =pvget(th,'Ts');
[a,b1,c,d1,k]=ssdata(th);
if isempty(a)&isempty(d1)
  num =[]; deno = []; dnum =[]; dden =[];
  return
end

[ny,nu]=size(d1);
Nu = nu;
[mc,nc] = size(c);dk=eye(mc);
den = poly(a);
if nu == 0
   b = k;
   d = eye(ny);
   nu = ny;
   else
   b = b1;
   d = d1;
end

 
for ku=1:nu   
   for ky=1:ny   
      num1  = poly(a-b(:,ku)*c(ky,:)) + (d(ky,ku) - 1) * den;
     if Ts>0
         nnn =max(find(abs(num1 )>100*eps));
      nnd =max(find(abs(den)>100*eps));
  else
      nnn = length(num1);nnd = length(den);
  end
      if isempty(nnn)
         deno{ky,ku} = 1;
         num{ky,ku} = 0;
      else
         deno{ky,ku}=den(1:max(nnn,nnd));
         num{ky,ku}=num1(1:max(nnn,nnd));
      end
   end
end
if nargin==2 %% V
   num=num{1,1};deno=deno{1,1};
end
if nargout<3
   return
end
if Nu>0
   mp = idpolget(th,[],'b'); 
else
   mp = idpolget(th,[],'b');
   end
if isempty(mp)
   dnum = []; dden =[];
   return
end

for ky = 1:ny
   if ~iscell(mp),mp={mp};end
   [dum,dum,dnum1,dden1] = tfdata(mp{ky}(1,1:nu));
   dnum(ky,:)=dnum1;
   dden(ky,:)=dden1;
end
if nargin==2 % V
   dnum=dnum{1,1};dden=dden{1,1};
end



