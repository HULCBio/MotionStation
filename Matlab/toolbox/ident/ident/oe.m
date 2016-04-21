function m = oe(varargin)
%OE	Computes the prediction error estimate of an Output Error model.
%
%   M = OE(Z,[nb nf nk]) or M = OE(Z,'nb',nb,'nf',nf,'nk',nk) 
%
%   M : returns the estimated model in an IDPOLY object format
%   along with estimated covariances and structure information. 
%   For the exact format of M see also help IDPOLY.
%
%   Z :  The estimation data in IDDATA or IDFRD object format.
%        See help IDDATA and help IDFRD.
%
%   [nb nf nk] are the orders and delays of the Output Error model
%
%	    y(t) = [B(q)/F(q)] u(t-nk) +  e(t)
%
%   For multi-input data, nb, nf and nk are row vectors with length
%   equal to the number of input channels.
%   CONTINUOUS TIME MODEL ORDERS: If Z is continuous time frequency domain
%   data, then continuous time models can be estimated directly. 
%   Nf then denotes the number of denominator coefficients
%   and nb the number of numerator coefficients. Nk is then of no
%   consequence and should be omitted. Example: Mi = [2 3] gives a model
%   (b1*s + b2)/(s^3 + f1*s^2 + f2*s + f3)
%
%   An alternative syntax is M = OE(Z,'nb',nb,'nf',nf) or M = OE(Z,Mi), where 
%   Mi is an estimated model or created by IDPOLY.
%   The minimization is then initialized at the parameters given in Mi. 
%
%   By M = OE(Z,nn,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See help IDPOLY for a list of Property/Value pairs. 

%   Lennart Ljung 10-10-86
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $  $Date: 2004/04/10 23:19:10 $


if nargin<2
    disp('Usage: M = oe(Data,Orders);')
    disp('       M = oe(Data,Orders,Prop/Value pairs).')
    if nargout,m = [];end
    return
end

try
   [mdum,z] = pemdecod('oe',varargin{:});
catch
   error(lasterr)
end
err = 0;
z = setid(z);
if isempty(pvget(z,'Name'))
   z=pvset(z,'Name',inputname(1));
end
if isa(mdum,'idpoly')
   nd = pvget(mdum,'nd');
   nc = pvget(mdum,'nc');
   na = pvget(mdum,'na');
   
   if sum([nd na nc])~=0
      err = 1;
   end
else
   err = 1;
end
if err
   error('This is not an OE model.')
end
% $$$ fixp = pvget(mdum,'FixedParameter'); $$$ if ~isempty(fixp) $$$
% warning(sprintf(['To fix a parameter, first define a nominal
% model.',...  $$$ '\nNote that mnemonic Parameter Names can be set by
% SETPNAME.']))  $$$ end

%try
m = pem(z,mdum);
%catch
 % error(lasterr)
 %end
es = pvget(m,'EstimationInfo');
es.Method = 'OE';
m = pvset(m,'EstimationInfo',es);

 