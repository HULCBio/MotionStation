function schema
%SCHEMA  Schema for the Open-Loop Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:03:12 $

% Register class 
sisopack = findpackage('sisogui');
c = schema.class(sisopack,'bodeditorOL',findclass(sisopack,'bodeditor'));

% Plot attributes
p = schema.prop(c,'MarginVisible','on/off'); % Stability margin visibility
schema.prop(c,'ShowSystemPZ','on/off');    % Visibility of system pole/zero
% Defaults
set(p,'AccessFlags.Init','on','FactoryValue','on');
    
