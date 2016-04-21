function this = MATFileContainer(FileName)
% Defines properties for @MATFileContainer class
% (implements @ArrayContainer interface)

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:28:46 $
this = hds.MATFileContainer;
this.FileName = FileName;
