function hout = editdlg(Constr)
%EDITDLG  Constructor for singleton instance of @editdlg
%        (dialog for editing plot constraints).

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 05:08:52 $

persistent h

% Create singleton instance 
if isempty(h)
    h = plotconstr.editdlg;
end

hout = h;
