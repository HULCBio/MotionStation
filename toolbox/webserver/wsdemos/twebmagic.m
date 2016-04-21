function twebmagic()
%TWEBMAGIC Example standalone test of webmagic function.
%   TWEBMAGIC Does setup and calls webmagic.  Creates
%   the output file, twebmagic.html.
%

%   Author(s): M. Greenstein, 11-10-97
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.5 $   $Date: 2001/04/25 18:49:28 $

% Set up input variables.
s = {};
s = wssetfield(s, 'mlmfile', 'webmagic');
s = wssetfield(s, 'msize', '5');
s = wssetfield(s, 'mldir', '.');

% Create an output test file.
str = webmagic(s, 'twebmagic.html');

% Send output to the screen.
disp(str);
