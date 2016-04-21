function descriptionPane = dspGetDescriptionPane(block,text)
% getDescriptionPane(block,text)
%   Returns a MATLAB struct for use with DSP Fixed-point Dynamic Dialogs
%   
%   block = UDD object associated with a DSP block
%   text  = text to put in description pane
%
% The string '\n\nSettings on the ''Fixed-point'' tab only apply when 
% block inputs are fixed-point.' is added to the input text.

% Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/20 23:16:11 $

description.Type = 'text';
description.Name = sprintf([text '\n\nSettings on the "Fixed-point" pane only apply when block inputs are fixed-point signals.']);

description.Tag = 'description';
description.WordWrap = 1;

paneName = block.MaskType;
%if strcmp(lower(get_param(block,'linkstatus')),'resolved')
%  paneName = [paneName ' (mask) (link)'];
%else
%  paneName = [paneName ' (mask)'];
%end

descriptionPane = dspGetWidgetBase('group', paneName, 'descriptionPane');
descriptionPane.Items = {description};
descriptionPane.RowSpan = [1 1];
descriptionPane.ColSpan = [1 1];
descriptionPane.Tag = 'descriptionPane';
