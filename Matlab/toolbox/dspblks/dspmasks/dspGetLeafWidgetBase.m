function dlgstruct = dspGetWidgetLeafBase(type,name,tag,sync,prop)
%dspGetLeafWidgetBase DSP Blockset Dynamic Dialog block helper function.
%
%   dspGetLeafWidgetBase(type,name,tag,prop)
%   Returns a MATLAB structure for use with Dynamic Dialogs
%   The structure has several common fields filled out:
% 
%    type : Type
%    name : Name
%    tag  : Tag
%    sync : whether or not to set MatlabMethod/MatlabArgs for syncing
%           input the controller source to set
%           input 0 to ignore
%    prop : ObjectProperty (optional)
%    
%   Also, the struct has Mode set to 1, and Tunability set to 0
%   

% Copyright 2003 The MathWorks, Inc.

error(nargchk(4,5,nargin,'struct'));

dlgstruct.Type    = type;
% don't even create a Name field if the string is blank
if ~isempty(name)
  dlgstruct.Name    = name;
end
dlgstruct.Tag     = tag;
dlgstruct.Mode    = 1;
dlgstruct.Tunable = 0;

%if sync ~= 0
%  dlgstruct.MatlabMethod = 'slDialogUtil';
%  dlgstruct.MatlabArgs = {sync,'sync','%dialog',type,'%tag'};
%end

if sync ~= 0 
  dlgstruct.MatlabMethod = 'dspDDGSync';
  dlgstruct.MatlabArgs = {sync,'%dialog','%tag'};
end


if nargin >= 5
  dlgstruct.ObjectProperty = prop;
end
