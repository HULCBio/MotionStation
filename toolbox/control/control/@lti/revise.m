function [L,LoadVersion,CurrentVersion] = revise(L)
%VERINFO  Updates LTI object version and returns both the
%         version of the loaded object, and the version 
%         in the current release.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/01/07 19:32:32 $

% Version of loaded object (preserved by LOADOBJ)
LoadVersion = L.Version;
% Version in current release
CurrentVersion = getVersion(L);
% Update LTI object version
L.Version = CurrentVersion;
