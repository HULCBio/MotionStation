% function out = vpck(mat,indv)
%
%   Pack a VARYING matrix from stacked matrix
%   and independent variable data.
%
%   See also: GETIV, MINFO, PCK, UNPCK, VUNPCK
%             XTRACT and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vpck(mat,omega)

   if nargin < 2
     disp('usage: out = vpck(mat,indv)')
     return
   end
 if isempty(mat) | isempty(omega)
   out = [];
 else
   [nr,nc] = size(mat);
   if min(size(omega)) ~= 1
     error('independent variable data should be a VECTOR')
     return
   end
   [nro,nco] = size(omega);
   npts = nro;
   if nro == 1
     omega = omega.';
     npts = nco;
   end
   if floor(nr/npts) ~= ceil(nr/npts)
     error('matrix data and IV have incompatible row data')
     return
   end
   out = zeros(nr+1,nc+1);
   out(1:nr,1:nc) = mat;
   out(1:npts,nc+1) = omega;
   out(nr+1,nc+1) = inf;
   out(nr+1,nc) = npts;
 end
%