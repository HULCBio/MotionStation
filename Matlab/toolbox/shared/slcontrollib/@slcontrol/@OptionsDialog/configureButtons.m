function configureButtons(this)
% CONFIGUREBUTTONS 

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/19 01:31:24 $

% Get the dialog handle
Dialog = this.Dialog;

% Configure buttons
L = [ handle.listener( handle(Dialog.getHelpButton), ...
                       'ActionPerformed', @LocalHelpButton ); ...
      handle.listener( handle(Dialog.getOkButton), ...
                       'ActionPerformed', @LocalOKButton ); ...
      handle.listener( handle(Dialog.getApplyButton), ...
                       'ActionPerformed', @LocalApplyButton ); ...
      handle.listener( handle(Dialog.getCancelButton), ...
                       'ActionPerformed', @LocalCancelButton ) ];

set(L, 'CallbackTarget', this);
this.Listeners = [this.Listeners; L];

% ----------------------------------------------------------------------------- %
function LocalHelpButton(this, hData)
% Launch the help browser
if isa(this.OptimOptionForm, 'srogui.OptimOptionForm')
  if this.Dialog.getOptimOptionPanel.isVisible
    helpview([docroot '/toolbox/sloptim/sloptim.map'], 'options_opt')
  else
    helpview([docroot '/toolbox/sloptim/sloptim.map'], 'options_sim')
  end;
elseif isa(this.OptimOptionForm, 'speforms.OptimOptionForm')
  if this.Dialog.getOptimOptionPanel.isVisible
    helpview([docroot '/toolbox/slestim/slestim.map'], 'options_opt')
  else
    helpview([docroot '/toolbox/slestim/slestim.map'], 'options_sim')
  end;
end;

% ----------------------------------------------------------------------------- %
function LocalOKButton(this, hData)
% Call the apply callback
LocalApplyButton(this);

% Call the cancel callback
LocalCancelButton(this);

% ----------------------------------------------------------------------------- %
function LocalCancelButton(this, hData)
% Close the dialog
awtinvoke(this.Dialog, 'setVisible', false);

% ----------------------------------------------------------------------------- %
function LocalApplyButton(this, hData)
setModelData(this);
