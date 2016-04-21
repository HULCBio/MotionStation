function [sfRoot] = sfroot
%SFROOT Returns the Stateflow Root object.
%   [SFROOT] = SFROOT 
%   Returns the one-and-only Stateflow Root object.
%
%   See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFCLIPBOARD, SFHELP.

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.2 $

    % Ensure that the Stateflow module is loaded into memory.
    sf('lock');

    % Acquire a reference to the Root object.
    sfRoot = Stateflow.Root;
