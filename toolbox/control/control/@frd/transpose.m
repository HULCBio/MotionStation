function tsys = transpose(sys)
%TRANSPOSE  Transposition of Frequency Response Data object.
%
%   TSYS = TRANSPOSE(SYS) is invoked by TSYS = SYS.'.
%
%   The ResponseData fields of SYS and TSYS are 
%   related by
%       TSYS.ResponseData = SYS.ResponseData.',
%       at each frequency point.
%
%   If SYS represents the transfer function H(s) or H(z),
%   then TSYS represents the transfer function H(s).' 
%   (respectively, H(z).' in the discrete-time case).
%
%   See also CTRANSPOSE, FRD, LTIMODELS.

%   Author(s): S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 06:16:22 $

tsys = sys;

sysResponse = sys.ResponseData;

sizes = size(sysResponse);
sizes([1 2]) = sizes([2 1]);

response = zeros(sizes);

for k=1:prod(sizes(3:end))
   response(:,:,k) = sysResponse(:,:,k).';
end

tsys.ResponseData = response;

tsys.lti = (sys.lti).';
