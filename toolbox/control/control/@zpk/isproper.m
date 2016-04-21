function boo = isproper(sys)
%ISPROPER  True for proper LTI systems.
%
%   ISPROPER(SYS) returns 1 (true) if the LTI model SYS is proper 
%   (relative degree<=0), and 0 (false) otherwise.  If SYS is an
%   array of LTI models, ISPROPER(SYS) is true if all models are
%   proper.
%
%   See also ISSISO, ISEMPTY, LTIMODELS.

%       Author(s): P. Gahinet, 4-1-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.13 $


boo = all(sys.k(:)==0 | cellfun('length',sys.z(:))<=cellfun('length',sys.p(:)));

