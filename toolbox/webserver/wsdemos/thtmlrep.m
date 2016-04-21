function str = thtmlrep
% THTMLREP Test of the HTMLREP function.
%   THTMLREP creates some MATLAB variables in a MATLAB
%   structure, TESTSTRUCT. It calls HTMLREP with this
%   structure, an HTML template file, THTMLREP1.HTML,
%   and the name of a file to be generated, THTMLREP2.HTML.
%   Also returns the generated output in STR.
%   (Open THTMLREP2.HTML in a web browser to see the results.)
%

%       Author(s): M. Greenstein, 11-10-97
%       Copyright 1998-2001 The MathWorks, Inc.
%       $Revision: 1.5 $   $Date: 2001/04/25 18:49:26 $

% Create test variables in teststruct.
teststruct.msize = 5;
teststruct.msquare = magic(teststruct.msize);
d = sum(teststruct.msquare, 1); 
teststruct.msum = d(1,1);
teststruct.abc = {'aaaaa' 'bbbbb' 'cccc' 'sssss'; 'ddddd' ...
      'eeeee' 'fff' 'xxxxxxxxxxx'; 'ggggggg' 'hhhhhhhhhhh' ...
      'iiiiii' 'yyyyyyyyy'; 'jjjjjj' 'kkkkkk' 'lll' '7777777'};
teststruct.select1 = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
teststruct.select2 = wstextread('players.txt');
teststruct.xyz = {'aaa' 'bbb'; 7 'ccccc'; 'ddddd' 898 };

% Create thtmlrep2.html from thtmlrep1.html and teststruct.
str = htmlrep(teststruct, 'thtmlrep1.html', 'thtmlrep2.html');



