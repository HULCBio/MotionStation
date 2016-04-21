function [Uout,Sout,Vout] = svd(A,economy)
% Embedded MATLAB Library function.
%
% Limitations:
% 1) Does not return correct dimensions for empty matrices.

% $INCLUDE(DOC) toolbox/eml/lib/dsp/svd.m $
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.4.2 $  $Date: 2004/04/10 23:15:02 $

eml_assert(nargin > 0, 'error', 'Not enough input arguments.');
eml_assert(isfloat(A), 'error', ['Function ''svd'' is not defined for values of class ''' class(A) '''.']);

wantv = (nargout == 3);
wantu = nargout >= 2;

if isempty(A),
    U = [];
    if wantv
        V = [];
    end
    if wantu || wantv,
        S = [];
    end
    return
end

if nargin == 1,
    econ = -1;
else
   if ischar(economy) && strcmp(economy,'econ')
       econ = 1;
   elseif isscalar(economy) && (economy == 0),
       econ = 0;
   else
       eml_assert(false, 'error', ['Use svd(X,0) or svd(X,''econ'') for economy size decomposition.']);
   end
end

%!!!  [n,p] = size(A);
n = size(A,1);
p = size(A,2);

if (econ == -1) || (n <= p),
    ncu = n;
    nru = n;
    ncv = p;
    nrv = p;
    nrS = n;
    ncS = p;
    if n > p,
        nrs = n;
        ncs = 1;
    else
        nrs = 1;
        ncs = p;
    end
else
    nru = n;
    ncu = p;
    nrv = p;
    ncv = p;
    nrS = p;
    ncS = p;
    if n > 1,
        nrs = min(n+1,p);
        ncs = 1;
    else
        nrs = 1;
        ncs = min(n+1,p);
    end
end

s = zero_matrix(nrs,ncs,A);
e = zero_matrix(p,1,A);
work = zero_matrix(n,1,A);

if wantu,
    U = zero_matrix(nru,ncu,A);
end    

if wantv
    V = zero_matrix(nrv,ncv,A);
end
%
%     Reduce A to bidiagonal form, storing the diagonal elements
%     in s and the super-diagonal elements in e.
%
nct = min(n-1,p);
nrt = max(0,min(p-2,n));
zlu = max(nct,nrt);
for l = 1:zlu
    if (l <= nct)
        %
        %           Compute the transformation for the l-th column and
        %           place the l-th diagonal in s(l).
        %
        %!!! s(l) = norm(A(l:n,l));
        nrm=zero_scalar(A);
        for ii=l:n
            if isreal(A),
                nrm = pythag(nrm,A(ii,l));
            else
                nrm = pythag(nrm,real(A(ii,l)));
                nrm = pythag(nrm,imag(A(ii,l)));
            end
        end
        s(l)=nrm;
        %!!!
        if (abs(s(l)) ~= 0.0)
            if (abs(A(l,l)) ~= 0.0)
                if isreal(A),
                    if A(l,l) >= 0.0,
                        s(l) = abs(s(l));
                    else
                        s(l) = -abs(s(l));
                    end
                else
                    rt1 = pythag(real(A(l,l)),imag(A(l,l)));
                    rt2 = pythag(real(s(l)),imag(s(l)));
                    if rt1 == 0,
                        s(l) = rt2;
                    else
                        s(l) = (rt2 / rt1) * A(l,l);
                    end
                end
            end
            %!!!
%             A(l:n,l) = A(l:n,l)/s(l)
            % slinv = unit_scalar(A) / s(l);
            for ii=l:n
                A(ii,l) = A(ii,l) / s(l); % *slinv;
            end
            %!!!
            A(l,l) = unit_scalar(A) + A(l,l);
        end
        s(l) = -s(l);
    end
    for j = l+1:p
        if (l <= nct) && (abs(s(l)) ~= 0.0) 
            %
            %              Apply the transformation.
            %
            %!!! 
	    % t = -A(l:n,l)'*A(l:n, j)/A(l,l);
            t = zero_scalar(A);
            for ii = l:n
                if isreal(A)
                    t = t + A(ii,l)*A(ii,j);
                else
		    %
		    % We do it this way, because that gives us better
		    % precision and in more agreement with MATLAB.
		    %
                    t = t + complex(real(A(ii,l))*real(A(ii,j)) + ...
                                    imag(A(ii,l))*imag(A(ii,j)), ...
                                    real(A(ii,l))*imag(A(ii,j)) - ...
                                    imag(A(ii,l))*real(A(ii,j)));
                end
            end
            t = -t / A(l,l);
            %!!! 
%             A(l:n,j) = A(l:n,j) + t*A(l:n,l);
            for ii = 1:n
                A(ii,j)= A(ii,j) + t*A(ii,l);
            end
            %!!!
        end
        %
        %           Place the l-th row of A into  e for the
        %           subsequent calculation of the row transformation.
        %
        e(j) = conj(A(l,j)); % complex(real(A(l,j)),-imag(A(l,j)));
    end
    if (wantu && l <= nct)
        %
        %           Place the transformation in U for subsequent back
        %           multiplication.
        %
        for i = l:n
            U(i,l) = A(i,l);
        end
    end
    if (l <= nrt)
        %
        %           Compute the l-th row transformation and place the
        %           l-th super-diagonal in e(l).
        %
        %!!! 
%         e(l) = norm(e(l+1:p));
        nrm = zero_scalar(A);
        for ii=l+1:p
            if isreal(e(ii)),
                nrm = pythag(e(ii),nrm);
            else
                nrm = pythag(real(e(ii)),nrm);
                nrm = pythag(imag(e(ii)),nrm);
            end
        end
        e(l) = nrm;
        %!!!
        if (abs(e(l)) ~= 0.0)
            if (abs(e(l+1)) ~= 0.0)
                if isreal(A),
                    if e(l+1) >= 0.0,
                        e(l) = abs(e(l));
                    else
                        e(l) = -abs(e(l));
                    end
                else
                    rt1 = abs(e(l+1));
                    rt2 = abs(e(l));
                    if rt1 == 0,
                        e(l) = rt2;
                    else
                        e(l) = (rt2 / rt1) * e(l+1);
                    end
                end
            end
            %!!! 
%             e(l+1:p) = e(l+1:p)/e(l);
            %elinv removed to improve precision...
            %elinv = unit_scalar(e) / e(l);
            %
            for ii=l+1:p
                e(ii) = e(ii) / e(l); % *elinv;
            end
            %!!!
            e(l+1) = e(l+1) + unit_scalar(e);
        end
        if isreal(e),
            e(l) = -e(l);
        else
            e(l) = complex(-real(e(l)),imag(e(l)));
        end
        if (l+1 <= n && abs(e(l)) ~= 0.0)
            %
            %              Apply the transformation.
            %
            for i = l+1:n
                work(i) = zero_scalar(work);
            end
            for j = l+1:p
                %!!!
%                 work(l+1:n) = work(l+1:n) + e(j)*A(l+1:n,j);
                for ii = l+1:n
                    work(ii) = work(ii)+ e(j)*A(ii,j);
                end
                %!!!
            end
            for j = l+1:p
                t = conj(-e(j)/e(l+1));
                %!!! 
%                 A(l+1:n,j) = A(l+1:n,j) + t*work(l+1:n);
                for ii = l+1:n
                    A(ii,j) = A(ii,j)+ t*work(ii);
                end
                %!!!
            end
        end
        if (wantv)
            %
            %              Place the transformation in V for subsequent
            %              back multiplication.
            %
            for i = l+1:p
                V(i,l) = e(i);
            end
        end
    end
end

%
%     Set up the final bidiagonal matrix or order m.
%
m = min(p,n+1);
if (nct < p)
    s(nct+1) = A(nct+1,nct+1);
end
if (n < m)
    s(m) = zero_scalar(A);
end
if (nrt+1 < m)
    e(nrt+1) = A(nrt+1,m);
end
e(m) = zero_scalar(e);
%
%     If required, generate U.
%
if (wantu)
    if nct+1 <= ncu,
        for j = nct+1:ncu
            for i = 1:n
                U(i,j) = zero_scalar(U);
            end
            U(j,j) = unit_scalar(U);
        end
    end
    if nct >= 1,
    for l = nct:-1:1
        if (abs(s(l)) ~= 0.0)
            for j = l+1:ncu
                %!!! 
		% Check whether this formula needs to be updated!
		% t = -U(l:n,l)'*U(l:n,j)/U(l,l);

                t = zero_scalar(A);
                for ii = l:n
                    if isreal(U),
                        t = t + U(ii,l)*U(ii,j);
                    else
   		        %
		        % We do it this way, because that gives us better
		        % precision and in more agreement with MATLAB.
		        %
                        t = t + complex(real(U(ii,l))*real(U(ii,j)) + ...
                                        imag(U(ii,l))*imag(U(ii,j)), ...
                                        real(U(ii,l))*imag(U(ii,j)) - ...
                                        imag(U(ii,l))*real(U(ii,j)));
                    end  
                end
                t = -t / U(l,l);
                %!!! 
%                 U(l:n,j) = U(l:n,j) + t*U(l:n,l);
                for ii = l:n
                    U(ii,j) = U(ii,j)+ t*U(ii,l);
                end
                %!!!
            end
            %!!! 
%             U(l:n,l) = -U(l:n,l);
            for ii = l:n
                U(ii,l) = -U(ii,l);
            end
            %!!!
            U(l,l) = unit_scalar(U) + U(l,l);
            for i = 1:l-1
                U(i,l) = zero_scalar(U);
            end
        else
            for i = 1:n
                U(i,l) = zero_scalar(U);
            end
            U(l,l) = unit_scalar(U);
        end
    end
    end
end

%
%     If it is required, generate V.
%
if (wantv)
    for l = p:-1:1
        if (l <= nrt) && (abs(e(l)) ~= 0.0)
            for j = l+1:p
                %!!! 
		% Check whether this formula needs to be updated!
		% t = -V(l+1:p,l)'*V(l+1:p,j)/V(l+1,l);
                t = zero_scalar(A);
                for ii = l+1:p
                    if isreal(V),
                        t = t + V(ii,l)*V(ii,j);
                    else
		        %
     		        % We do it this way, because that gives us better
		        % precision and in more agreement with MATLAB.
		        %
                        t = t + complex(real(V(ii,l))*real(V(ii,j)) + ...
                                        imag(V(ii,l))*imag(V(ii,j)), ...
                                        real(V(ii,l))*imag(V(ii,j)) - ...
                                        imag(V(ii,l))*real(V(ii,j)));
                    end
                end
                t = -t / V(l+1,l);
                %!!! 
%                 V(l+1:p,j) = V(l+1:p,j) + t*V(l+1:p,l);
                for ii = l+1:p
                    V(ii,j) = V(ii,j) + t*V(ii,l);
                end
                %!!!
            end
        end
        for i = 1:p
            V(i,l) = zero_scalar(V);
        end
        V(l,l) = unit_scalar(V);
    end
end

%
% Transform s and e so that they are real
%

    for l=1:m,
        t = abs(s(l));
        if t ~= 0,
            r = s(l) / t;
            s(l) = t;
            if l < m,
                e(l) = e(l) / r;
            end
            if wantu && l <= n,
                for i = 1:n,
                    U(i,l) = r * U(i,l);
                end
            end
        end
        if l < m,
            t = abs(e(l));
            if t ~= 0,
                r = t / e(l);
                e(l) = t;
                s(l+1) = s(l+1) * r;
                if wantv,
                    for i = 1:p,
                        V(i,l+1) = r * V(i,l+1);
                    end
                end
            end
        end
    end

%
%     Main iteration loop for the singular values.
%
maxit = 75;
mm = m;
iter = 0;
tiny = realmin(class(A)) / eps(class(A));
snorm = zero_scalar(real(A));

for i = 1:m,
    snorm = max(snorm, max(abs(real(s(i))),abs(real(e(i)))));
end

while (m > 0)
    %
    %        If too many iterations have been performed, set
    %        flag and return.
    %
    if (iter >= maxit) 
        error('SVD fails to converge')
    end
    %
    %        This section of the program inspects for
    %        negligible elements in the s and e arrays.  On
    %        completion the variables kase and l are set as follows.
    %
    %           kase = 1     if s(m) and e(l-1) are negligible and l<m
    %           kase = 2     if s(l) is negligible and l<m
    %           kase = 3     if e(l-1) is negligible, l<m, and
    %                        s(l), ..., s(m) are not negligible (qr step).
    %           kase = 4     if e(m-1) is negligible (convergence).
    %
    for l = m-1:-1:0
        if (l == 0)
            break
        end
        test0 = abs(real(s(l))) + abs(real(s(l+1)));
        ztest0 = abs(real(e(l)));
        if (ztest0 <= eps(class(A))*test0) || (ztest0 <= tiny) || ...
            (iter > 20 && ztest0 <= eps(class(A))*snorm),
            e(l) = zero_scalar(e);
            break
        end
    end
    if (l == m-1)
        kase = 4;
    else
        for ls = m:-1:l
            if (ls == l)
                break
            end
            test = zero_scalar(A);
            if (ls ~= m)
                test = test + abs(real(e(ls)));
            end
            if (ls ~= l + 1)
                test = test + abs(real(e(ls-1)));
            end
            ztest = abs(real(s(ls)));
            if (ztest <= eps(class(A))*test) || (ztest <= tiny),
                s(ls) = zero_scalar(s);
                break
            end
        end
        if (ls == l)
            kase = 3;
        elseif (ls == m)
            kase = 1;
        else
            kase = 2;
            l = ls;
        end
    end
    l = l + 1;
    %
    %        Perform the task indicated by kase.
    %
    switch kase
        %
        %        Deflate negligible s(m).
        %
    case 1
        f = e(m-1);
        e(m-1) = zero_scalar(e);
        for k = m-1:-1:l
            [cs,sn,t1] = factor_vector(s(k),f);
            s(k) = t1;
            if (k ~= l)
                % This is not a direct translation of lines
                % 580-585 of svd_z_rt.c because only the real
                % part of e(k-1) is updated.
                f = -sn*e(k-1);
                e(k-1) = e(k-1)*cs;
            end
            if (wantv)
                %!!! 
%                 V(1:p,[k m]) = V(1:p,[k m])*[cs -sn; sn cs];
                for ii = 1:p
                    t = V(ii,k)*cs + V(ii,m)*sn;
                    V(ii,m) = V(ii,m)*cs - V(ii,k)*sn;
                    V(ii,k) = t;
                end
                %!!!
            end
        end
        %
        %        Split at negligible s(l).
        %
    case 2
        f = e(l-1);
        e(l-1) = zero_scalar(e);
        for k = l:m
            [cs,sn,t1] = factor_vector(s(k),f);
            s(k) = t1;
            f = -sn*e(k);
            e(k) = e(k)*cs;
            if (wantu)
                %!!! 
%                 U(1:n,[k l-1]) = U(1:n,[k l-1])*[cs -sn; sn cs];
                for ii = 1:n
                    t = U(ii,k)*cs + U(ii,l-1)*sn;
                    U(ii,l-1) = U(ii,l-1)*cs - U(ii,k)*sn;
                    U(ii,k) = t;
                end
                %!!!
            end
        end
        %
        %        Perform one qr step.
        %
    case 3
        %
        %           Calculate the shift.
        %
        scale = max([abs(real(s(m))),abs(real(s(m-1))),...
                     abs(real(e(m-1))), ...
                     abs(real(s(l))),abs(real(e(l)))]);
        sm = real(s(m))/scale;
        smm1 = real(s(m-1))/scale;
        emm1 = real(e(m-1))/scale;
        sl = real(s(l))/scale;
        el = real(e(l))/scale;
        b = ((smm1 + sm)*(smm1 - sm) + emm1*emm1)/2.0;
        c = (sm*emm1);
        c = c * c;
        shift = zero_scalar(A);
        if (b ~= 0.0 || c ~= 0.0) 
            shift = sqrt(b*b+c);
            if (b < 0.0)
                shift = -shift;
            end
            shift = c/(b + shift);
        end
        f = (sl + sm)*(sl - sm) + shift;
        g = zero_scalar(A);
        g = sl*el;
        %
        %           Chase zeros.
        %
        for k = l:m-1
            %
            % C code in svd_z_rt.c only updated the real parts
            % of the complex numbers (we expect the imaginary
            % part to be 0, or very close to 0).
            %
            [cs,sn,t1] = factor_vector(f,g);
            if (k ~= l)
                e(k-1) = t1;
            end
            f = cs*s(k) + sn*e(k);
            e(k) = cs*e(k) - sn*s(k);
            g = sn*s(k+1);
            s(k+1) = cs*s(k+1);
            if (wantv)
                %!!! 
%                 V(1:p,[k k+1]) = V(1:p,[k k+1])*[cs -sn; sn cs];
                for ii = 1:p
                    t = V(ii,k)*cs + V(ii,k+1)*sn;
                    V(ii,k+1) = V(ii,k+1)*cs - V(ii,k)*sn;
                    V(ii,k) = t;
                end
                %!!!
            end
            [cs,sn,t1] = factor_vector(f,g);
            s(k) = t1;
            f = cs*e(k) + sn*s(k+1);
            s(k+1) = -sn*e(k) + cs*s(k+1);
            g = sn*e(k+1);
            e(k+1) = cs*e(k+1);
            if (wantu && k < n)
                %!!! 
%                 U(1:n,[k k+1]) = U(1:n,[k k+1])*[cs -sn; sn cs];
                for ii = 1:n
                    t = U(ii,k)*cs + U(ii,k+1)*sn;
                    U(ii,k+1) = U(ii,k+1)*cs - U(ii,k)*sn;
                    U(ii,k) = t;
                end
                %!!!
            end
        end
        e(m-1) = f;
        iter = iter + 1;
        %
        %        Convergence.
        %
    case 4
        %
        %           Make the singular value  positive.
        %
        if (s(l) < 0.0)
            s(l) = -s(l);
            if (wantv)
                %!!! V(:,l) = -V(:,l);
                for ii = 1:p
                    V(ii,l) = -V(ii,l);
                end
                %!!!
            end
        end
        %
        %           Order the singular value.
        %
        while (l < mm) && (s(l) < s(l+1))
            t = s(l);
            s(l) = s(l+1);
            s(l+1) = t;
            if (wantv && l < p)
                %!!! 
%                 V(1:p,[l l+1]) = V(1:p,[l+1 l]);
                for ii = 1:p
                    t = V(ii,l);
                    V(ii,l) = V(ii,l+1);
                    V(ii,l+1) = t;
                end
                %!!!
            end
            if (wantu && l < n)
                %!!! 
%                 U(1:n,[l l+1]) = U(1:n,[l+1 l]);
                for ii = 1:n
                    t = U(ii,l);
                    U(ii,l) = U(ii,l+1);
                    U(ii,l+1) = t;                    
                end
                %!!!
            end
            l = l + 1;
        end
        iter = 0;
        m = m - 1;
    end
end

if nargout < 2
    rr = min(nrS,ncS);
    Uout = zero_real_matrix(rr,1,A);
    Uout(1:rr) = real(s(1:rr));
else
    S = zero_real_matrix(nrS,ncS,A);
    ns = min(nrS,min(ncS,length(s)));
    for i = 1:ns,
        S(i,i) = real(s(i));
    end
    if econ < 1 || (econ == 1 && n >= p),
        Uout = U;
	Sout = S;
        Vout = V;
    else
	Uout = U(1:n,1:n);
	Sout = S(1:n,1:n);
	Vout = V(1:size(V,1),1:n);
    end
end

function s = zero_scalar(A)
    s = zero_matrix(1,1,A);

function B = zero_matrix(n,m,A)
    if isreal(A)
    	B = zeros(n,m,class(A));
    else
        B = zeros(n,m,class(A)) + 0i;
    end

function B = zero_real_matrix(n,m,A)
    B = zeros(n,m,class(A));

function s = unit_scalar(A)
    s = ones(1,1,class(A));

function r = pythag(a,b)
if abs(a) > abs(b)
    tmp = b/a;
    r = abs(a)*sqrt(unit_scalar(a)+tmp*tmp);
elseif b ~= 0
    tmp = a/b;
    r = abs(b)*sqrt(unit_scalar(b)+tmp*tmp);
else
    r = zeros(1,1,class(a));
end

function [c,s,r,z] = factor_vector(x,y)
    absx = abs(x);
    absy = abs(y);
    if absx > absy,
        rho = x;
    else
        rho = y;
    end
    r = pythag(x,y);
    if rho <= 0,
        r = -r;
    end
    if r ~= 0,
        c = x / r;
        s = y / r;
    else
        c = zero_scalar(x) + unit_scalar(x);
        s = zero_scalar(y);
    end
    if absx > absy,
        z = s;
    else
        z = zero_scalar(s);
        if c ~= 0,
            z = unit_scalar(z) / c;
        else
            z = zero_scalar(s) + unit_scalar(z);
        end
    end
