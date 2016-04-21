function A = copy(this,DataCopy)
%COPY  Copy method for @MATFileContainer.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:47 $

% RE: Never copy the file pointer (no obvious way to copy file-based data)
A = hds.MATFileContainer;