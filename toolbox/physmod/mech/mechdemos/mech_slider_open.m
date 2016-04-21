function mech_slider_open(model_name)
% MECH_SLIDER_OPEN  Helper function to open slider gain blocks for demos
%   MECH_SLIDER_OPEN(MODEL) opens all of the slider gain dialogs in
%   the model MODEL. If the Handle Graphics position of the slider is
%   stored in the TAG property for any slider gain block, that dialog
%   is opened to that position on the screen.
%
%   This function is usually called in the INITFCN for demos.

%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/16 22:17:37 $

% Get the handle to the model
model = get_param(model_name,'handle');

% Check to see if the model is loaded or opened
IsOpened = isequal(get_param(model,'Open'),'on');

% Find all slider gain blocks
Blks = find_system(model,'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
    'masktype','Slider Gain');

% Loop through the slider gain blocks, opening their dialogs
for i=1:length(Blks),
    %set_param(model,'CurrentBlock',Blks(i));
    if IsOpened,
        open_system(Blks(i));
    end
    
    tag = get_param(Blks(i),'Tag');
    % If there is a position stored in the TAG property, then move
    % the dialog box to that position on the screen
    if ~isempty(tag)
        set(get_param(Blks(i),'UserData'), ...
            'Position', ...
            str2num(tag));
    end    
end

% Open all the blocks that have a tag "OpenMeAtStartUp"
if IsOpened,
    open_system(find_system(model,'LookUnderMasks','all','Tag','OpenMeAtStartUp'));
end
%-------------------------------------------------------------------------