function c = ccode(s)
%CCODE  C code representation of a symbolic expression.
%   CCODE(S) returns a fragment of C that evaluates the symbolic expression S.
%
%   Examples:
%      syms x
%      f = taylor(log(1+x));
%      ccode(f) =
%
%         t0 = x-x*x/2.0+x*x*x/3.0-x*x*x*x/4.0+x*x*x*x*x/5.0;
%
%      H = sym(hilb(3));
%      ccode(H) =
%
%         H[0][0] = 1.0;          H[0][1] = 1.0/2.0;      H[0][2] = 1.0/3.0;
%         H[1][0] = 1.0/2.0;      H[1][1] = 1.0/3.0;      H[1][2] = 1.0/4.0;
%         H[2][0] = 1.0/3.0;      H[2][1] = 1.0/4.0;      H[2][2] = 1.0/5.0;
%
%   See also PRETTY, LATEX, FORTRAN.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 03:12:24 $

t = inputname(1);
if isempty(t), t = 'T'; end
maple([t ':=' char(s)]);
c = maple(['C(' t ');']);
maple([t ':=''' t '''']);
