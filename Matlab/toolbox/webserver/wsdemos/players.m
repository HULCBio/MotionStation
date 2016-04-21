function str = players(h, outfile)
%PLAYERS sample display of softball statistics file.
%   STR = PLAYERS(H, OUTFILE) opens text file players.txt
%   and puts the contents into HTML output string STR and
%   into file OUTFILE.
%   STR = PLAYERS(H) performs the same functions but does not
%   put the output into OUTFILE.
%

%   Author(s): M. Greenstein, 04-01-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.6 $   $Date: 2001/04/25 18:49:26 $

% Set working directory.
cd(h.mldir);

% Put data into MATLAB structure x.
x.date = date;
x.players = wstextread('players.txt');

% Put the data into the HTML document for output.
templatefile = which('players.html');
if (exist('outfile', 'var') == 1)
   str = htmlrep(x, templatefile, outfile);
else
   str = htmlrep(x, templatefile);
end



