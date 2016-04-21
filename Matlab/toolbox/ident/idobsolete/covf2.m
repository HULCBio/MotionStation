function R=covf2(z,M)
%COVF2   Computes covariance function estimates
%
%   R = covf2(Z,M)
%
%   The routine is a subroutine to COVF. See COVF for further
%   details.

%   L. Ljung 10-1-86,11-11-94
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:37 $

[N,nz]=size(z);
z=[z;zeros(M,nz)];
j=[1:N];
for k=1:M
a=z(j,:)'*z(j+k-1,:);
R(:,k)=conj(a(:))/N;
end

