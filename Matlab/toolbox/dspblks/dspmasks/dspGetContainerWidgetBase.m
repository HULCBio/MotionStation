function dlgstruct = dspGetContainerWidgetBase(type,name,tag)
%dspGetContainerWidgetBase DSP Blockset Dynamic Dialog block helper function.
%
%   dspGetContainerWidgetBase(type,name,tag,prop)
%   Returns a MATLAB structure for use with Dynamic Dialogs
%   The structure has several common fields filled out:
% 
%    type: Type
%    name: Name
%    tag:  Tag
%    

% Copyright 2003 The MathWorks, Inc.

error(nargchk(3,3,nargin,'struct'));

dlgstruct.Type = type;
dlgstruct.Name = name;
dlgstruct.Tag = tag;

