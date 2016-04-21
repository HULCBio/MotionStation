function mfname=getmfth(eta)
%GETMFTH Gets the name of the .m-file that defines the model structure
%   OBSOLETE function. Use IDGREY Property name 'MfileName' instead.
%
%   MFNAME = getmfth(TH)
%
%   TH: The model structure defined in the THETA-format (See help theta)
%   MFNAME: The name of the m-file that defines the structure

%   L. Ljung 10-2-90,10-10-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:38 $

if nargin < 1
   disp('Usage: MFILE_NAME = GETMFTH(TH)')
   return
end
if ~isa(eta,'idgrey')
   error('GETMFTH only applies to IDGREY models')
end
mfname = get(eta,'MfileName');
return
