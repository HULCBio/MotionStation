function outstate = isStateSpace(h)
%ISSTATESPACE  True for state space LTI systems.
%
%   ISSTATESPACE(SYS) returns 1 (true) if the LTI model SYS is in 
%   state space form, and 0 (false) otherwise.  If SYS is an
%   array of LTI models, ISSTATESPACE(SYS) is true if all models are
%   in state space form.
%
%   See also ISSISO, ISEMPTY, ISPROPERR, ISPROPERLTIMODELS.

%   Author(s): J. G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:26 $

outstate = true;