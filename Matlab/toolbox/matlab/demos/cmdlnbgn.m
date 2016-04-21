%CMDLNBGN Sets up for calling command line demos from DEMO.
%
%   See also CMDLNEND, DEMO

%   Ned Gulley, 6-21-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 03:32:35 $

% Here's the idea: we only want to have ONE unassigned, unnamed command line
% demo figure running around in order to avoid window proliferation. So since
% every other Expo demo figure has a name, before we run any of the old demos
% we'll first check to see if an unnamed figure is lying around.

if figureNeededFlag,
    oldFigNumber=watchon;

    figNumber=findobj('Type', 'figure', 'Name', []);
    
    if isempty(figNumber),
        pos=get(0,'DefaultFigurePosition');
    % Adjust the window down and to the left so that it doesn't
    % completely obscure the Expo Map window.
        pos=pos+[-50 -50 0 0];
        figNumber=figure('Position',pos);
    else
        figNumber=figNumber(1);
    end

    figure(figNumber);

    clear figNumber

end

clc

