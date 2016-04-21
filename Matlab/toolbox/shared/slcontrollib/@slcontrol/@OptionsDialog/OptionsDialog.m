function this = OptionsDialog(SimOptionForm, OptimOptionForm, parent)
% OPTIONSDIALOG 

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:43 $

% Create class instance and configure the Java handles
this = slcontrol.OptionsDialog;

% Store option objects
this.SimOptionForm   = SimOptionForm;
this.OptimOptionForm = OptimOptionForm;

% Create the options dialog
switch class(OptimOptionForm)
case 'srogui.OptimOptionForm'
  type = 'SRO';
case 'speforms.OptimOptionForm'
  type = 'SPE';
end

% If the parent is a Figure, 
if isjava(parent)
  this.Dialog = com.mathworks.toolbox.control.settings.OptionsDialog(parent, type);
else
  this.Dialog = com.mathworks.toolbox.control.settings.OptionsDialog([], type);
  centerfig(this.Dialog, parent)
end

% Configure callbacks & listeners
configurePanels(this);
configureButtons(this);

% Update the GUI content with the new data
setViewData(this);

% Listeners
L(1) = handle.listener(this, 'ObjectBeingDestroyed', {@LocalDestroy this});

%if (nargin == 4)
%  L(2) = handle.listener(obj, 'ObjectBeingDestroyed', {@LocalDelete this});
%end

this.Listeners = [ this.Listeners; L(:) ];

% --------------------------------------------------------------------------
function LocalDestroy(hSrc, hData, this)
% Delete dialog
dispose(this.Dialog)

% --------------------------------------------------------------------------
function LocalDelete(hSrc, hData, this)
% Delete object
delete(this)
