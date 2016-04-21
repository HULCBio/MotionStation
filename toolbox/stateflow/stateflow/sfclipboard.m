function [sfClipboard] = sfclipboard
%SFCLIPBOARD Returns the Stateflow Clipboard object.
%   [SFCLIPBOARD] = SFCLIPBOARD 
%   Returns the one-and-only Stateflow Clipboard object.
%
%   See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFROOT, SFHELP.

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $


    % Ensure that the Stateflow module is loaded into memory.
    v = sf('Version');

    % Acquire a reference to the Clipboard object.
    sfClipboard = Stateflow.Clipboard;
