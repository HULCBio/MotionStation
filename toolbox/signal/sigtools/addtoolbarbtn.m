function [newHndls, hnewbtn] = addtoolbarbtn(varargin)
%ADDTOOLBARBTN Add a toolbar button to a figure.
%   ADDTOOLBARBTN(H,POS,TYPE,ICONDATA) creates a toolbar button of TYPE toggle 
%   or push at position POS with an icon defined in ICONCDATA and returns a handle to it.
%   Both TYPE and ICONCDATA must be cell arrays.
%
%   ADDTOOLBARBTN(...,CLICKEDCALLBACK,TAG,SEPARATOR,TOOLTIPSTRING,) creates the button 
%   and sets it properties. If TYPE is 'TOGGLE', then both OFFCALLBACKS and ONCALLBACKS can 
%   be defined, e.g., ADDTOOLBARBTN(...OFFCALLBACK,ONCALLBACKTOOLTIP).
%
%   To add several buttons, POS is the starting position and TYPE, ICONCDATA, etc must be 
%   cell arrays of the same size.
%
%   Inputs:
%     H        - Handle to a figure.
%     POS      - Scalar representing the position of new button.
%     TYPE     - Cell array containing the new button types ('TOGGLE','PUSH').
%     ICONDATA - A three-dimensional matrix of RGB values that defines a truecolor image 
%                displayed on either a push button or toggle button. Each value must be 
%                between 0.0 and 1.0.
%     CLICKEDCALLBACK - Cell array containing the button callbacks. 
%     TAG      - (Optional) Cell array containing the button tag.
%     SEP      - (Optional) Cell array indicating whether or not 
%               to include a separator before the button. 'Off' means do not
%               include a separator whereas a 'On' means include it. 
%               If omitted, sep defaults to 'Off'.
%     TOOLTIPSTRING - Cell array of tooltips.
%     OFFCALLBACK   - (Toggle buttons only) called whenever the state is changed to 'Off'.
%     ONCALLBACK    - (Toggle buttons only) called whenever the state is changed to 'On'.
%
%   Output:
%     hnewbtn  - Handle or vector of handles to the new button(s).
%     newHndls - New handles to the original toolbar buttons.
%
%   See also UITOGGLETOOL, UIPUSHTOOL.

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/14 23:52:31 $ 

% Parse inputs
[hFig,pos,type,icon,cbs,tags,sep,ttip,offcbs,oncbs] = parse_inputs(varargin{:});

% Get the handle to the uitoolbar
hparent = findall(hFig,'Type','uitoolbar');

% Render the new button and set it in the toolbar.
[newHndls, hnewbtn] = setNewToolbar(hparent,pos,type,icon,cbs,tags,sep,ttip,offcbs,oncbs);

                              
%----------------------------------------------------------------------
function [hFig,pos,type,icon,cbs,tags,sep,ttip,offcbs,oncbs] = ...
                                    parse_inputs(hFig,pos,type,icon,varargin)
% Parse the inputs to ADDTOOLBARBTN.
%
%   Outputs:
%      pos    - Scalar
%      type   - String or cell array of button types
%      icon   - Icon Cdata (3-D matrix)
%      cbs    - String or cell array of callbacks 
%      tags   - String or cell array of tags 
%      sep    - String or cell array of separators 
%      ttip   - String or cell array of ToolTipStrings
%
%   Additional Outputs (used only if type == 'TOGGLE'):
%      offcbs - String or cell array of OffCallBacks 
%      oncbs  - String or cell array of OnCallBacks

% Defaults (of the right size) for optional input parameters
if iscell(type),
    cellsz   = cell(size(type));
    defaults = {cellsz,cellsz,cellsz,cellsz,cellsz,cellsz};
    for n = 1:length(defaults),
        if n == 3,
            s = 'Off'; % Separator flag default 
        else
            s = '';    % All other defaults
        end
        [defaults{n}{:}]   = deal(s);    
    end
else
    defaults = {...
            '',...    % Separator flag
            '',...    % CallBacks
            'Off',... % Tags
            '',...    % ToolTipStrings
            '',...    % OffCallBack
            ''};      % OnCallBack
end

% Creates defaults only when not specified in varargin
[cbs,tags,sep,ttip,offcbs,oncbs] = deal(varargin{:},defaults{length(varargin)+1:end});


%----------------------------------------------------------------------
function [newHndls, hnewbtn] = setNewToolbar(hparent,pos,type,icon,cbs,tags,sep,ttip,offcbs,oncbs)
% Render the new button and set it in the toolbar.
%
%   Outputs:
%     newHndls - New handles to the original toolbar buttons
%     hnewbtn  - Handle to the new button(s)

% Get the number of toolbar buttons.  For a standard figure window, this does 
% not include the New, Open, Save, and Print buttons.
hbtns = flipud(get(hparent,'Children'));

% Add 1 to acknowledge that we are adding one or more buttons to the existing list
% and allow us to properly index into the original list of button handles
numofbtns = length(hbtns)+1;
for n = 1:numofbtns, 
    if (n ~= pos),
        if n < pos,      
            tmp = n;
        elseif n > pos,
            % Subtract one to continue copying and deleting original buttons
            tmp = n - 1;
        end
        % Copy the old btn and delete
        newHndls(n) = copyobj(hbtns(tmp),hparent);
        delete(hbtns(tmp));
    elseif n == pos,
        % Render the new toolbar button
        hnewbtn = render_newbtn(hparent,type,icon,cbs,tags,sep,ttip,offcbs,oncbs);
    end
end

% Return only the new handles for the original buttons.
newHndls = [newHndls(1:pos-1) newHndls(pos+1:end)];

%----------------------------------------------------------------------
function hnewbtn = render_newbtn(hparent,type,icon,cbs,tags,sep,ttip,offcbs,oncbs)
% Render the new toolbar button (toggle or push). 

for n = 1:length(type),
    % Common button properties
    btn_props = {...
            'Parent',hparent,...
            'CData',icon{n},...
            'Tag',tags{n}, ...
            'ClickedCallback',cbs{n},...
            'ToolTipString',ttip{n},...
            'Separator',sep{n}};    
        
    if strcmpi(type{n},'toggle'),        
        % Render the toggle button
        hnewbtn(n) = uitoggletool(btn_props{:},...
            'OffCallBack',offcbs{n},...   
            'OnCallBack', oncbs{n});
    else
        % Render the push button
        hnewbtn(n) = uipushtool(btn_props{:});
    end
end

% [EOF]
