function dlgstruct = blockGetDialogSchema(h)
  
 % This is the default schema files for all SL blocks.
   slashn = double(sprintf('\n'));
   name = strrep(h.name, char(slashn), ' ');
   
   
  desc.Type = 'text';
  desc.Name = ['This item does not have dialogs that can be displayed in the Model Explorer. \n' ...
               'Please use the links below to open the stand-alone dialogs.'];
  desc.RowSpan = [1 1];
  desc.ColSpan = [1 1];
  
  paramlink.Name = ['- Open ', name, '.'];
  paramlink.Type = 'hyperlink';
  paramlink.ToolTip = 'This is identical to double-clicking on the block in the model.';
  paramlink.MatlabMethod = 'open_system';
  paramlink.MatlabArgs = {h.getFullName};
  paramlink.RowSpan = [2 2];
  paramlink.ColSpan = [1 1];
  
  proplink.Name = ['- Open block properties dialog for ', name, '.'];
  proplink.Type = 'hyperlink';
  proplink.ToolTip = 'Open block properties.';
  proplink.MatlabMethod = 'open_system';
  proplink.MatlabArgs = {h.getFullName, 'property'};
  proplink.RowSpan = [3 3];
  proplink.ColSpan = [1 1];
  
  spacer.Type = 'panel';
  spacer.RowSpan = [4 4];
  spacer.ColSpan = [1 1];
  
  dlgstruct.DialogTitle = ['Default block dialog: ' name];
  dlgstruct.Items = {desc, paramlink, proplink, spacer};
  dlgstruct.LayoutGrid = [4 1];
  dlgstruct.RowStretch = [0 0 0 1];
  
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:57 $
