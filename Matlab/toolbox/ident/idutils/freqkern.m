function [f] = freqkern(A,B,U,w);
%FREQKERN Simuluation of frequency responses
%  f = freqkern(A,B,U,w,D,T);
%     
%  f = [(w(1)I-A)^{-1}BU(1,:).', (w(2)I-A)^{-1}BU(2,:),'
%  ... (w(N)I-A)^{-1}BU(N,:).A
%   
% Calculates the frequency response kernel of a linear system in state
% space form.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2003/11/11 15:50:51 $

[n,dum] = size(A); if n~=dum, error('A matrix must be square'); end;
[dum,m]  = size(B); if n~=dum, error('A,B matrices not compatible'); end;
kz = [];
for km=1:m
    if norm(B(:,km))==0|norm(U(:,km))==0
        kz = [kz,km];
    end
end
if ~isempty(kz)
    B(:,kz)=[];U(:,kz)=[];
end
[dum,m]=size(B);
N = length(w); 
if m==0
    f = zeros(n,N);
    return
end

w=w(:);
%f = zeros(n,N);
g1 = mimofr(A,B,[],[],w);
fin = find(isinf(g1));
if ~isempty(fin)
    [l1,l2,l3]=size(g1);
    frnr = floor(min(fin)/l1/l2 +1);
    infreq = w(frnr);
    warning(sprintf(['Infinite frequency response at ',num2str(infreq),' rad/s.',...
            '\nThis frequency should be removed from the data set.']))
end

% for p=1:m,
%     gdum = reshape(g1(:,p,:),[length(A) length(w)]);
%     if ~all(U(:,p)==1)
%     gdum = gdum*spdiags(U(:,p),0,N,N);
% end
%     f  =  f + gdum;
% end
if m>1
     f=reshape((sum((reshape(shiftdim(g1,1),m,n*N)).*(repmat(U.',1,n)))).',N,n).';
 else
     f=reshape(((reshape(shiftdim(g1,1),m,n*N)).*(repmat(U.',1,n))).',N,n).';
 end
 %norm(ff-f)
    
