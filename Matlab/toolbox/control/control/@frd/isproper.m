function boo = isproper(sys)
%ISPROPER  True for proper LTI systems.
%
%   ISPROPER(SYS) returns 1 (true) if the LTI model SYS is proper 
%   (relative degree<=0), and 0 (false) otherwise.  If SYS is an
%   array of LTI models, ISPROPER(SYS) is true if all models are
%   proper.
%
%   See also ISSISO, ISEMPTY, LTIMODELS.

%   Author(s): S. Almy
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/10 23:13:10 $

boo = true;