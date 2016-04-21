function Y = idltifr(A,B,C,D,U,w);
%IDLTIFR Simuluation in the frequency domain
%   Y = idltifr(A,B,C,D,U,w);
%        
%   Calculates the output of a linear system [A,D,C,D] to the
%   frequency domain input signal U(w_k), at frequencies 
%   w = [w_k, k=1,...]

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/09/21 13:47:31 $

[msg,A,B,C,D] = abcdchk(A,B,C,D);
if ~isempty(msg)
    error(msg)
end
[p,m]=size(D);
% Remove empty inputs
kz = [];
for km=1:m
    if (norm(B(:,km))==0&norm(D(:,km))==0)|norm(U(:,km))==0
        kz = [kz,km];
    end
end
if ~isempty(kz)
    B(:,kz)=[];
    D(:,kz) = [];
    U(:,kz)=[];
end
[dum,m]=size(B);
N = length(w); 
w=w(:);
g1 = mimofr(A,B,C,[],w);
fin = find(isinf(g1));
if ~isempty(fin)
    [l1,l2,l3]=size(g1);
    frnr = floor(min(fin)/l1/l2 +1);
    infreq = w(frnr);
    warning(sprintf(['Infinite frequency response at ',num2str(infreq),' rad/s.',...
            '\nThis frequency should be removed from the data set.']))
end

if m>1
    Y = reshape((sum((reshape(shiftdim(g1,1),m,p*N)).*(repmat(U.',1,p)))).',N,p);
else
    Y = reshape(((reshape(shiftdim(g1,1),m,p*N)).*(repmat(U.',1,p))).',N,p);
end
if norm(D)>0
    Y = Y+ U*D.';
end
