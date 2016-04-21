function m = bj(varargin)
%BJ	Computes the prediction error estimate of a Box-Jenkins model.
%
%   M = BJ(Z,[nb nc nd nf nk])  or
%   M = BJ(Z,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk) 
%       (Omitted orders are taken as zero, and the argument order is arbitrary)
%
%   M : returns the estimated model in an IDPOLY object format
%   along with estimated covariances and structure information. 
%   For the exact format of M see also help IDPOLY.
%
%   Z :  The estimation data in IDDATA object format. See help IDDATA
%
%   [nb nc nd nf nk] are the orders and delays of the Box-Jenkins model
%	    y(t) = [B(q)/F(q)] u(t-nk) +  [C(q)/D(q)]e(t)
%
%   An alternative is M = BJ(Z,Mi), where 
%   Mi is an estimated model or created by IDPOLY.
%   The minimization is then initialized at the parameters given in Mi. 
%
%   By M = BJ(Z,nn,Property_1,Value_1, ...., Property_n,Value_n)
%   all properties associated with the model structure and the algorithm
%   can be affected. See HELP IDPOLY and IDPROPS ALGORITHM for a list of
%   Property/Value pairs.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $ $Date: 2004/04/10 23:18:54 $

if nargin<2
    disp('Usage: M = bj(Data,Orders);')
    disp('       M = bj(Data,Orders,Prop/Value pairs).')
    if nargout,m = [];end
    return
end

try
   [mdum,z] = pemdecod('bj',varargin{:});
catch
   error(lasterr)
end
err = 0;
z = setid(z);
if isempty(pvget(z,'Name'))
   z=pvset(z,'Name',inputname(1));
end
if isa(mdum,'idpoly')
   if  pvget(mdum,'na')~=0
      error('This is not a BJ model.')
   end
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
es.Method = 'BJ';
m = pvset(m,'EstimationInfo',es);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
