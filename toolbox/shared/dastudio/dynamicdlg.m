function jobj = dynamicdlg (argin)
% DYNAMICDLGS Produce dynamic dialogs, for internal MathWorks use.
%
%   DYNAMICDLG(m-struct | file) will use the struct/mat-file-name passed in to define
%    the layout of the dialog. This feature requires Java Swing support. 
%   Here is the expected structure of the dialog structure:
%
%       dlgstruct -
%          - DialogTitle
%          - Tab_1
%               - Name
%               - Group_1
%                    - Name
%                    - NameVisible
%                    - BoxVisible
%                    - WidthFactor (Optional, default = 100)
%                    - Widget_1
%                         - Name (Required for pushbutton, text, label, radiobutton)
%                         - Type
%                         - ObjectProperty | ObjectMethod | MatlabMethod (One of these is
%                                                          required)
%                         - MethodArgs (Optional, used along with
%                                       ObjectMethod and MatlabMethod)
%                         - DialogCallback (Optional, use if you want the
%                                           dialog to update itself)
%                         - ToolTip  (Optional, default = '')
%                         - Enabled
%                         - Visible
%                         - Editable (Optional, used only for combobox, default = false)
%                         - Entries (Required for listbox, combobox and radiobutton)
%                         - SelectedItem (Optional, used by listbox, combobox, radiobutton, 
%                                         checkbox)
%                         - WidthFactor (Optional, default = 100) 
%                       :
%                    - Widget_N
%                  :
%               - Group_N
%              :
%          - Tab_N
%  
%   The following widgets are currently supported:
%     pushbutton     radiobutton       list        edit          combobox 
%     editarea       text              label       checkbox      hyperlink       
%   The 'WidthFactor' field in Group_N and Widget_N  are optional fields that
%   can be used to fine tune layout. By default, they are set to 100,
%   so that widgets are laid out one per row. They can be set to any number 
%   between 10 and 100. To lay out widgets side by side instead, choose
%   width factors for each widget so that the total for each row sums to 100.
%   Note that dialog creators are responsible for creating and maintaining a 
%   Japanese version of their dialog schema. This could be done by using
%   Java resource bundles.
%
%   See also MODELEXPLORER.


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:32:10 $
  

  % Test some basic things first
  error(nargchk(1,1,nargin));
  
  if ~usejava('swing')
    error('This dialog requires Java Swing support.');
  end
  
  % Load the dialog struct. FILE MUST HAVE A VARIABLE NAMED 'dlgstruct'.
  if isstruct(argin)
      dlgstruct = argin;
  else
      dlg = load(argin);
      dlgstruct = dlg.dlgstruct;
  end
  
  if isempty(dlgstruct)
    jobj = [];
    return
  end
  
  % Create the dialog generator object */
  d = DAStudio.DialogGenerator;
  jobj = d.generateDialog(dlgstruct);
  
  
