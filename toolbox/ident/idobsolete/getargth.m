function [arg,rarg,carg]=getargth(eta)
%GETARGTH   Gets the auxiliary argument for a state-space model
%           structure
%   OBSOLETE function. Use IDGREY Property 'FileArgument' instead.
%
%   ARG = getargth(TH)
%
%   TH: The model structure in the THETA-format (See help theta)
%   ARG: The auxiliary argument

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:38 $


if ~isa(eta,'idgrey')
   error('This is not a idgrey based model.')
end
arg = eta.FileArgument;
