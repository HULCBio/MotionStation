function B = fstab(A,T,thresh);
%FSTAB	FSTAB(A) stabilizes a MONIC polynomial with respect to the
%	unit circle, i.e. roots whose magnitudes are greater than
%	one are reflected into the unit circle.  The result is a monic
%	polynomial as well.

%       L.Ljung 2-10-92
%	Copyright 1992-2003 The MathWorks, Inc.

if nargin==1,T=1;end
if nargin<3
    if T
        thresh = 1;
    else
        thresh = 0;
    end
end
[nr,nc] = size(A);
if nr==1|nc==1
    A=A(:)';
    [nr,nc]=size(A);
end
B  = A;
if nr == 1 & nc == 1
    return
end
for kr =1:nr
    v = roots(A(kr,:)); 
    if T>0
        %         ind=(abs(v)>eps);
        %         vs = 0.5*(sign(abs(v(ind))-1)+1);
        %         v(ind) = (1-vs).*v(ind) + vs./ (conj(v(ind)));
        ind = find(abs(v)>thresh);
        v(ind) = thresh^2*ones(size(ind))./v(ind);
    else
        ind=find(real(v)>thresh);
        if length(ind)>0,
            v(ind)=2*thresh - real(v(ind))+i*imag(v(ind));
        end
    end
    bv  = poly(v);lbv = length(bv);
    if T
        B(kr,1:lbv)=bv;
    else
        B(kr,nc-lbv+1:end) = bv;
    end
end
if isreal(A),B=real(B);end
