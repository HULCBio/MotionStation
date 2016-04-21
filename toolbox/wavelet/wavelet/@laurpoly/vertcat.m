function M = vertcat(varargin)
%VERTCAT Vertical concatenation of Laurent polynomials.
%   M = VERTCAT(P1,P2,...) performs the concatenation 
%   operation M = [P1 ; P2 ; ...]. M is a Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Jun-2003.
%   Last Revision: 21-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:39:28 $

M = laurmat(varargin(:));
