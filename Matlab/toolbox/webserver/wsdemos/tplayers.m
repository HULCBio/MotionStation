function tplayers
%TPLAYERS standalone test driver for players.
%   TPLAYERS creates test output file tlpalyers.html.
%   Creates a matweb substitute structure to pass to players.
%   Displays the HTML output.
%

%   Author(s): M. Greenstein, 04-01-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.4 $   $Date: 2001/04/25 18:49:27 $

h.mldir = '.';
str = players(h, 'tplayers.html');
disp(str);
