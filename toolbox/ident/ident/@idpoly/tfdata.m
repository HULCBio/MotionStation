function [num,den,dnum,dden]=tfdata(th,v)
%IDPOLY/TFDATA  Transforms IDPOLY model objects to transfer functions.
%
%   [NUM,DEN] = TFDATA(MODEL) returns the numerator(s) and denominator(s) 
%   of the model object MODEL.  For a transfer function with NY 
%   outputs and NU inputs, NUM and DEN are NY-by-NU cell arrays such that
%   NUM{I,J} (note the curly brackets) specifies the transfer 
%   function from input J to output I.   
%   [NUM,DEN,SDNUM,SDDEN] = TFDATA(MODEL) also returns the standard
%   deviations of the numerator and denominator coefficients. 
%   Other properties of MODEL can be accessed with GET or by direct structure-like 
%   referencing (e.g., MODEL.Ts.)
%
%   If MODEL is a time series (NU=0) the transfer functions from the noise source
%   e to the outputs y are returned. There are NY-by-NY such transfer functions.
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
%   $Revision: 1.12 $  $Date: 2002/01/21 09:35:29 $

if nargin < 1
   disp('Usage: [NUM, DEN] = TFDATA(Model)')
   disp('       [NUM, DEN, SDNUM, SDDEN] = TFDATA(Model)')
   return
end
Ts =pvget(th,'Ts');
if nargout<3
   [a,b,c,d,f] = polydata(th);
else
   [a,b,c,d,f,da,db,dc,dd,df] = polydata(th);
end
nu=size(b,1);
nu=size(th,'nu');

if nu > 0
    NF = size(f,2);
   for iu=1:nu
       if Ts>0
      deno = conv(a,f(iu,1:th.nf(iu)+1));
  else
      deno = conv(a,f(iu,NF-th.nf(iu):end));
  end
      nume = b(iu,1:th.nb(iu)+th.nk(iu));
      ld=length(deno);ln=length(nume);mn=max(ld,ln);
      if Ts>0,
         den{1,iu}=[deno,zeros(1,mn-ld)];num{1,iu}=[nume,zeros(1,mn-ln)];
      else
         den{1,iu}=[zeros(1,mn-ld),deno];num{1,iu}=[zeros(1,mn-ln),nume];
      end
   end
else
   deno = conv(a,d);
   nume = c;
    ld=length(deno);ln=length(nume);mn=max(ld,ln);

   if Ts>0,
      den{1,1}=[deno,zeros(1,mn-ld)];num{1,1}=[nume,zeros(1,mn-ln)];
   else
      den{1,1}=[zeros(1,mn-ld),deno];num{1,1}=[zeros(1,mn-ln),nume];
   end
   
end
dden=cell(size(den));dnum=cell(size(num));

if nargin==2 % V
   num=num{1,1};den=den{1,1};
   dnum=dnum{1,1};dden=dden{1,1};
end

if nargout<3|isempty(da)
   return
end

if nu > 0
   for iu=1:nu
      deno = conv(da,f(iu,1:th.nf(iu)+1))+conv(a,df(iu,1:th.nf(iu)+1));%%LL%%
      nume = db(iu,1:th.nb(iu)+th.nk(iu));
      ld=length(deno);ln=length(nume);mn=max(ld,ln);
      if Ts>0,
         dden{1,iu}=[deno,zeros(1,mn-ld)];dnum{1,iu}=[nume,zeros(1,mn-ln)];
      else
         dden{1,iu}=[zeros(1,mn-ld),deno];dnum{1,iu}=[zeros(1,mn-ln),nume];
      end
   end
else
   deno = conv(da,d)+conv(a,dd); %%LL%%
   nume = dc;
   if Ts>0,
      dden{1,1}=[deno,zeros(1,mn-ld)];dnum{1,1}=[nume,zeros(1,mn-ln)];
   else
      dden{1,1}=[zeros(1,mn-ld),deno];dnum{1,1}=[zeros(1,mn-ln),nume];
   end
   
end
if nargin==2 %% V
   dnum=dnum{1,1};dden=dden{1,1};
end

