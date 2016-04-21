function tsys = transpose(sys)
%TRANSPOSE  Transposition for zero-pole-gain models.
%
%   TSYS = TRANSPOSE(SYS) is invoked by TSYS = SYS.'.
%
%   The zero-pole-gain data of SYS and TSYS are related 
%   by
%       TSYS.Z = (SYS.Z).'
%       TSYS.P = (SYS.P).'
%       TSYS.K = (SYS.K).'
%
%   If SYS represents the transfer function H(s) or H(z),
%   then TSYS represents the transfer function H(s).' 
%   (respectively, H(z).' in the discrete-time case).
%
%   See also CTRANSPOSE, ZPK, LTIMODELS.

%   Author(s): P.Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/10 06:11:43 $

tsys = sys;

% Transpose NUM and DEN
sizes = size(sys.k);
sizes([1 2]) = sizes([2 1]);
tsys.z = cell(sizes);
tsys.p = cell(sizes);
tsys.k = zeros(sizes);

for j=1:prod(sizes(3:end)),
   tsys.z(:,:,j) = sys.z(:,:,j)';
   tsys.p(:,:,j) = sys.p(:,:,j)';
   tsys.k(:,:,j) = sys.k(:,:,j)';
end

tsys.lti = (sys.lti).';

