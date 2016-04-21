function x=usolve(U,b)
%USOLVE  Solve GF upper-triangular system U*x=b.
%  USOLVE(U,b) is the solution to the upper-triangular 
%  system of equations U*x=b. b must be a column on input.
%
%  See also LSOLVE, LU, INV.

%    Copyright 1996-2003 The MathWorks, Inc.
%    $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:01:10 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

    if ~isa(U,'gf'), U = gf(U,b.m,b.prim_poly); end
    if ~isa(b,'gf'), b = gf(b,U.m,U.prim_poly); end
    if U.m~=b.m
      error('Orders must match.')
    elseif U.prim_poly~=b.prim_poly
      error('Primitive polynomials must match.')
    end

    n=length(U.x);
    if (length(b.x) ~= n),
        error(' USOLVE: Inputs U and b must be of compatible dimensions');
    end;

    if any(( any(double(U.x)-double(triu(U.x))) )), 
        error(' USOLVE: Input matrix U must be upper-triangular');
    end;

    if ( any(diag(double(U.x))==0) ), 
        error(' USOLVE: Input matrix U must be nonsingular');
    end;

    x = b;
    if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
       [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
    end
    x.x=uint16(zeros(size(b.x)));
    %x(n)=b(n)/U(n,n);
    x.x(n)=gf_mex(b.x(n),...
                    gf_mex(U.x(n,n),U.x(n,n),b.m,...
                             'rdivide',b.prim_poly,GF_TABLE1,GF_TABLE2),...
                    b.m,'times',b.prim_poly,GF_TABLE1,GF_TABLE2);
    for k=n-1:-1:1,
        Ukk_inv = gf_mex(U.x(k,k),U.x(k,k),b.m,'rdivide',...
                           b.prim_poly,GF_TABLE1,GF_TABLE2);
        % x(k)=(b(k) - U(k,k+1:n)*x(k+1:n))/U(k,k);
        Ux = gf_mex(U.x(k,k+1:n),x.x(k+1:n),b.m,'mtimes',...
                      b.prim_poly,GF_TABLE1,GF_TABLE2);
        x.x(k)= gf_mex(bitxor(b.x(k),Ux),Ukk_inv,b.m,'mtimes',...
                         b.prim_poly,GF_TABLE1,GF_TABLE2);
    end;
