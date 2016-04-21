function uiWidth = largestuiwidth(strs,uiStyle)
% LARGESTEUIWIDTH Return the uicontrol extent width of the largest string in
%                 the input cell array of strings.  
%                 A fudge factor is added for popups and radio buttons to 
%                 compensate for the triangle on the popup and the circle on 
%                 the radio button.
% Inputs:
%   strs - cell array of strings.
%   uiStyle - uicontrol style.
%
% Output:
%   uiWidth -  the uicontrol extent width.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/13 00:32:00 $ 

if nargin == 1, uiStyle = 'Text'; end

% Get the current figure from the root object that does not use the default
% menubar.  If the default menubar is on a figure and we add then delete a
% control the menubar will flicker. g
hFig = findall(0, 'type','figure', 'menubar','none');
delete_fig = false;

% If there is no figure available create an invisible one and change the
% delete flag to true.
if isempty(hFig),
    delete_fig = true;
    hFig = figure('visible', 'off');
else
    hFig = hFig(1);
end

% Determine the uiextent for the largest (or only) string.
temp_h = uicontrol(hFig, 'style','Text','visible','off','string',strs);
uiExtent = get(temp_h,'extent');
uiWidth  = uiExtent(3);
delete(temp_h);

switch uiStyle
case {'popup','radiobutton','checkbox'},
    % Add 21 to the width because these uis have part of the control
    % that doesn't display the text, e.g. the triangle in the popup.
    uiWidth = uiWidth+21; 
case 'pushbutton',
    % Add a fudge factor to the width so that the string doesn't end at
    % the very edge of the pushbuton.
    uiWidth = uiWidth+4;
end

% If we created the figure, delete it.
if delete_fig, delete(hFig); end

% [EOF] largestuiwidth.m
