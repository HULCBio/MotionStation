function update_fvtool(hFVTs, filtStruc, msg, filtIndex)
%UPDATE_FVTOOL(hFVTs, filtStruc, varargin)
% Function for Updating the FVTools opened from SPTool
% 
% Inputs:
%    hFVTs - FVTool object handles opened from SPTool
%    
%    filtStruc - Filter structure(s) to be updated in FVTool
%    1. When called from the Pole-zero editor function, the 'filtStruc'
%       variable would contain only one filter structure element.
%    2. When called from the filtview function, the 'filtStruc' variable
%       could contain more than one structure element.
%    
%    msg - Message to be used for updating FVTool
%          This message facilitates in updating FVTool faster
%    1. msg = 'pzedit' => call from fdpzedit function
%    2. msg ~= 'pzedit' => call from filtview function
%     
%    filtIndex - Index of the filter
%    1. filtIndex = 0 => call from filtview function 
%    2. filtIndex ~= 0 => call from fdpzedit function
%    
%    When called from the Pole-Zero editor filtIndex would be 
%    the Index of the filter in FVTool to be updated (on the fly).
%    Otherwise look up for the Filter Index.


%   Author: R. Malladi
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/08/12 19:38:22 $ 

error(nargchk(4,4,nargin));

[boolUpdate,Opts]...
    = parse_inputs(hFVTs(1),filtStruc,msg,filtIndex);

if boolUpdate,
    filtObj = create_dfsobj(hFVTs(1),filtStruc,msg,Opts.index);
    lclupdatefvtool(hFVTs,filtObj,msg,Opts);
end


% -------------------------------------------------------------------------
% --------------------------- Local Functions -----------------------------
% -------------------------------------------------------------------------
function [boolUpdate,Opts]...
    = parse_inputs(hFVT,filtStruc,msg,filterIndex)
%PARSE_INPUTS Parse the inputs for update_fvtool function and also
% determine if FVTool needs an update or not (call to updatechk function)
%
% Inputs
%  hFVT - FVTool handle
%  filtStruc - SPTool filter structure or PZEditor filter structure
%  msg - Message for updating FVTool
%  filterIndex - Index information of the filter
%  
% Outputs:
%  boolUpdate - Flag to indicate if FVTool to be updated
%  boolUpdate = 1 implies FVTool needs to be updated
%  Opts - Opts structure containing the filter index information
%       - Opts structure should contain an 'index' field (since 
%         FVTool setfilter method requires this format)
%
if strcmpi(msg,'pzedit'),
    boolUpdate = 1;
    Opts.index = filterIndex;
else
    % filterIndex = 0, when no specific index is specified
    %  In this case the index is to be obtained by calling the updatechk
    %  function which returns the indicies of the filters to be updated.
    [boolUpdate, Opts.index] = updatechk(hFVT,filtStruc,msg);
end


% -------------------------------------------------------------------------
function filtObj = create_dfsobj(hFVT,filtStruc,msg,filterIndex)
%CREATE_DFSOBJ Create dfiltwfs object(s) from SPTool Filter structure(s)
%
% Inputs
%  hFVT - FVTool handle
%  filtStruc - SPTool filter structure or PZEditor filter structure
%  msg - Message for updating FVTool
%  filterIndex - Index information of the filter
%
% Outputs:
%  filtObj - Vector of dfiltwfs objects
%
filtObj = [];
if isempty(filtStruc)
    return;
end

% Obtain the indicies ('Indx') of the filter objects to be created
if strcmpi(msg,'pzedit')
    % Execute this code when called from pole-zero editor
    % Update the filter object of hFVT that is current in the PZEditor
    filtStruc.label = hFVT.Filters(filterIndex).Name;
    filtStruc.Fs = hFVT.Filters(filterIndex).Fs;
    Indx = 1;
    kLim = 1;
else
    % This code is executed when called from the filtview function
    if isempty(filterIndex)
        % If the filterIndex is not specified, blindly update FVTool
        Indx = 1 : length(filtStruc);
        kLim = length(filtStruc);
    else
        % If the filterIndex is specified, update those filters only
        Indx = filterIndex;
        kLim = length(filterIndex);
    end
end

k = 1;
% Create the dfiltwfs objects from the dfilt.df1 objects
while k <= kLim
    dFiltDf1 = dfilt.df1(filtStruc(Indx(k)).tf.num,...
        filtStruc(Indx(k)).tf.den);
    filtObj = [filtObj dfilt.dfiltwfs(dFiltDf1,...
            filtStruc(Indx(k)).Fs,...
            filtStruc(Indx(k)).label)];
    k = k + 1 ;
end


% -------------------------------------------------------------------------
% Function to check if FVTool needs to be updated
% -------------------------------------------------------------------------
function [boolUpdate, filterIndex] = updatechk(hFVT,filtStruc,msg)
%UPDATECHK Check if FVTool needs an update or not
% This function compares the hFVT filter objects with the filtStruc and
% returns a flag boolUpdate and the index of the filter to be updated.
% 
% Inputs:
%  hFVT - FVTool handle
%  filtStruc - SPTool filter structure or PZEditor filter structure
%  msg - Message for updating FVTool
%  
% Outputs:
%  boolUpdate = 0 => Do not update FVTool
%  boolUpdate = 1 => Update FVTool
%  
%  filterIndex - Index of the filter to be updated (if boolUpdate = 1)
%  filterIndex = [] and boolUpdate = 1 => Update all the filters
%  filterIndex = [] and boolUpdate = 0 => FVTool need not be updated
%  
% NOTE: Multiple filter objects are compared.
%  
filterIndex = [];
boolUpdate = 0;
% Obtain the filter objetcs in FVTool (to check if FVTool needs an update)
filtObj = hFVT.Filters;

% Update FVTool if the number of currently selected filters changes.
% This takes care of the case 'clear' (the number of filters decreases).
if isempty(filtStruc) || length(filtObj) ~= length(filtStruc),
    boolUpdate = 1;
    return;
end

% Check if the filters have been modified or if the selection has changed
% If yes set the boolUpdate falg to 1 & also obtain their indicies.
switch msg
    case {'new'}
        for k = 1 : length(filtObj),
            fsFlag = ~isequal(filtObj(k).Fs,filtStruc(k).Fs);
            nameFlag = ~isequal(filtObj(k).Name,filtStruc(k).label);
            
            numFlag = ...
                ~isequal(filtObj(k).Filter.Numerator,filtStruc(k).tf.num);
            denFlag = ...
                ~isequal(filtObj(k).Filter.Denominator,filtStruc(k).tf.den);
            % If a filter has been modified, get its index
            if fsFlag || nameFlag || numFlag || denFlag
                filterIndex = [filterIndex k];
            end
        end
    case {'Fs'}
        for k = 1 : length(filtObj),
            fsFlag = ~isequal(filtObj(k).Fs,filtStruc(k).Fs);
            % If the Fs has been modified
            if fsFlag
                filterIndex = [filterIndex k];
            end
        end
    case {'label','value'}
        for k = 1 : length(filtObj),
            nameFlag = ~isequal(filtObj(k).Name,filtStruc(k).label);
            % If the label has been modified
            if nameFlag
                filterIndex = [filterIndex k];
            end
        end
    case 'dup'
        % For this case, only a name change to an existing filter is needed
        filterIndex = 1;
end
if ~isempty(filterIndex), boolUpdate = 1; end


% -------------------------------------------------------------------------
% Local function for updating FVTool
% -------------------------------------------------------------------------
function lclupdatefvtool(hFVTs,filtObj,msg,optsStruc)
%LCLUPDATEFVTOOL Update the FVTools (hFVTs) launched from SPTool
% 
% Inputs:
%  hFVTs - FVTool object handles
%  filtObj - Filter objects for FVTool
%  msg - Message for updating the hFVTs filter object
%  optsStruc - structure containing 'index' field
%
for k = 1 : length(hFVTs),
    % If no filter is selected in SPTool, render FVTool empty.
    setfilter(hFVTs(k),filtObj,optsStruc)
end

% Force FVTool graphic update
drawnow;
