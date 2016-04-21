function [a, b, c, d, sv] = imp2sys(imp, tol, ord);
%IMP2SYS Identifies a linear system model using system impulse response.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       [NUM, DEN] = IMP2SYS(IMP) identifies a linear system transfer function
%       with numerator NUM, and denominator DEN, by using the system impulse
%       response data sequence IMP. The order of the model is determined by
%       choosing tolerance value TOL = 0.01. The Hankel matrix has dimension
%       FLOOR(LENGTH(IMP)/2).
%
%       [NUM, DEN] = IMP2SYS(IMP, TOL) identifies a transfer function based on
%       system impulse response sequence IMP and the tolerance value TOL. 
%       When TOL > 1, TOL is the order of the conversion. When TOL < 1, TOL
%       indicates the tolerance in selecting the order based on the singular
%       values. The default value of TOL is 0.01.
%
%       [NUM, DEN] = IMP2SYS(IMP, TOL, ORD) identifies a transfer function 
%       based on system impulse response sequence IMP and the tolerance value
%       TOL by constructing a Hankel matrix with order ORD. When ORD is larger
%       than FLOOR(LENGTH(IMP)/2), the Hankel matrix fills the absent value
%       with zeros.
%
%       [NUM, DEN, SV] = IMP2SYS(...) outputs the transfer function and the
%       SVD values.
%
%       [A, B, C, D] = IMP2SYS(...) outputs the state-space model (A,B,C,D).
%
%       [A, B, C, D] = IMP2SYS(...) outputs the state-space model and the SVD
%       values.

%       Wes Wang 5/25/94, 10/10/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $

if nargin < 1
    error('Too few inputs for HANK2SYS');
elseif nargin < 2
    ord = floor(length(imp)/2); tol = 0.01;
elseif nargin < 3
    ord = floor(length(imp)/2);
end;
[ord, tol] = checkinp(ord, tol, floor(length(imp)/2), 0.01);

imp = imp(:)';
if ord > floor(length(imp)/2);
    imp = [imp, zeros(1, ord*2-length(imp))];
end;

han = [];
for i = 1: ord
    han = [han; imp(1+i:ord+i)];
end;
[a, b, c, d, sv] = hank2sys(han, imp(1), tol);

if nargout < 4
    [a, b] = ss2tf(a, b, c, d, 1);
    c = sv;
end;

%--end of file imp2sys.m--

