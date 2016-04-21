function m = armax(varargin)
%ARMAX	Computes the prediction error estimate of an ARMAX model.
%
%   M = ARMAX(Z,[na nb nc nk])  or M = ARMAX(Z,'na',na,'nb',nb,'nc',nc,'nk',nk)
%
%   M : returns the estimated model in an IDPOLY object format
%   along with estimated covariances and structure information. 
%   For the exact format of M see also help IDPOLY.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA
%
%   [na nb nc nk] are the orders and delays of the ARMAX model
%
%	   A(q) y(t) = B(q) u(t-nk) + C(q) e(t)
%
%   If the data have several inputs, nb and nk are row vectors with 
%   lengths equal to the number of input channels.
%
%   An alternative syntax is M = ARMAX(Z,Mi), where 
%   Mi is an estimated model or created by IDPOLY.
%   The minimization is then initialized at the parameters given in Mi. 
%
%   By M = ARMAX(Z,nn,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See HELP IDPOLY  or IDPROPS ALGORITHM for a list of
%   Property/Value pairs.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/04/10 23:18:50 $

if nargin<2
    disp('Usage: M = armax(Data,Orders);')
    disp('       M = armax(Data,Orders,Prop/Value pairs).')
    if nargout,m = [];end
    return
end
    try
   [mdum,z] = pemdecod('armax',varargin{:});
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
   nf = pvget(mdum,'nf');
   if sum([nd nf])~=0
      err = 1;
   end
else
   err = 1;
end
if err
   error('This is not an ARMAX model.')
end
% $$$ fixp = pvget(mdum,'FixedParameter');
% $$$ if ~isempty(fixp)
% $$$    warning(sprintf(['To fix a parameter, first define a nominal model.',...
% $$$          '\nNote that mnemonic Parameter Names can be set by SETPNAME.']))
% $$$ end
try
m = pem(z,mdum);
catch
  error(lasterr)
end

es = pvget(m,'EstimationInfo');
es.Method = 'ARMAX';
m = pvset(m,'EstimationInfo',es);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
