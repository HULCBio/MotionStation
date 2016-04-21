function optblock()
%OPTBLOCK   Error trapping for obsolete NCD mask.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:47:00 $
msg = 'Run the NCDUPDATE command to upgrade models containing old NCD blocks.';
errordlg(msg,'Block Dialog Error','modal')
