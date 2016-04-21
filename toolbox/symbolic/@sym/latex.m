function r = latex(s)
%LATEX  LaTeX representation of a symbolic expression.
%   LATEX(S) returns the LaTeX representation of the symbolic expression S.
%
%   Examples:
%      syms x
%      f = taylor(log(1+x));
%      latex(f) =
%         x-1/2\,{x}^{2}+1/3\,{x}^{3}-1/4\,{x}^{4}+1/5\,{x}^{5}
%
%      H = sym(hilb(3));
%      latex(H) =
%         \left [\begin {array}{ccc} 1&1/2&1/3\\\noalign{\medskip}1/2&1/3&1/4
%         \\\noalign{\medskip}1/3&1/4&1/5\end {array}\right ]
%     
%      syms alpha t
%      A = [alpha t alpha*t];
%      latex(A) =
%         \left [\begin {array}{ccc} \alpha&t&\alpha\,t\end {array}\right ]
%
%   See also PRETTY, CCODE, FORTRAN.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:06:39 $

r = maple('latex',char(s));
