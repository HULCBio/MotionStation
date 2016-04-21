function [eig1, eig2]=pdeeigx(a11,a12,a21,a22)
%PDEEIGX Exact calculation of eigenvalues for a 2-by-2 matrix.
%         [a11(i), a12(i); a21(i), a22(i)]
%
%         [EIG1, EIG2]=PDEEIGX(A11,A12,A21,A22)
%
%         Note: Input arguments may be equally sized vectors

%         Magnus Ringh, 1-12-95.
%         Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/01 04:28:14 $

if nargin<4,
  error('PDE:pdeeigx:nargin', 'Too few input arguments.')
end

a11=a11(:); a12=a12(:); a21=a21(:); a22=a22(:);
sizes=zeros(4,2);
sizes(1,:)=size(a11);
sizes(2,:)=size(a12);
sizes(3,:)=size(a21);
sizes(4,:)=size(a22);
if any(diff(sizes(:,1))),
  error('PDE:pdeeigx:InputSize', 'Vectors must be of same size.')
end

% All checks OK, calculate eigenvalues:
discr=(a11-a22).*(a11-a22)+4*a12.*a21;
eig1=(a11+a22-sqrt(discr))/2;
eig2=(a11+a22+sqrt(discr))/2;

