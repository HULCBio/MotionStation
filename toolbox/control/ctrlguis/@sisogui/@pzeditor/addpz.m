function addpz(Editor,PZID,PZType)
%ADDPZ  Creates additional edit boxes for PZ Editor.
%
%   PZID is Pole or Zero, and PZTYPE is the type of pole/zero group.

%   Author(s): P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 04:55:22 $

% Create new group
g = sisodata.pzgroup;
g.Type = PZType;

% Default values (initialize with NaN)
NaNvec = NaN;
isComplex = strcmp(PZType,'Complex');
InitValue = NaNvec(ones(1,1+isComplex),:);
if strcmp(PZID,'Zero')
    g.Zero = InitValue;
else
    g.Pole = InitValue;
end

% Add to list of groups (triggers update)
Editor.PZGroup = [Editor.PZGroup ; g];
