function out = worldlo(request)
% WORLDLO Return data from the WORLDLO or OCEANLO atlas data files.
%   WORLDLO types a list of the atlas data variables in the WORLDLO Mat-file to
%   the screen.
%   
%   S = WORLDLO('REQUEST') returns the requested variable.  Valid requests 
%   are 'POline', 'POpatch', 'POtext', 'PPpoint', 'PPtext', 'DNline', 
%   'DNpatch', 'oceanmask' and 'gazette'.  This command can be used as an 
%   argument to other commands, such as DISPLAYM(WORLDLO('POline')).
%  
%   The WORLDLO atlas data file contains vector data equivalent to a scale 
%   of 1:30,000,000 covering drainage, political/ocean boundaries and 
%   populated places. The data is in Geographic Data Structures for 
%   four types of objects: patches, lines, points and text. It is suitable
%   for global continental displays.
%
%   See also WORLDHI, COAST, USAHI, USALO, WORLDLO.MAT, OCEANLO.MAT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/08/01 18:23:21 $

if nargin == 0
	load('worldlo','description')

	disp('    ')
	disp('WORLDLO atlas data:')
	disp('    ')
	disp(description)
	disp('    ')
	disp('  Geographic Data Structures: ')
	disp('    ')
	disp('    POline        - Political Boundaries and coastlines as lines')
	disp('    POpatch       - Countries as patches')
	disp('    POtext        - Names of countries as text')
	disp('    PPpoint       - Major Cities as points')
	disp('    PPtext        - Major Cities as text labels')
 	disp('    DNline        - Major rivers as lines')
	disp('    DNpatch       - Major lakes as patches')
	disp('    oceanmask     - Oceans as patches')
	disp('    gazette       - Country and City names')
	disp('    ')
	return
end

switch request
    case 'oceanmask'
        matfile = 'oceanlo';
    otherwise
        matfile = 'worldlo';
end

data = load(matfile,request);
if ~isfield(data,request)
    error('%s not found in %s.MAT',request,matfile);
end
out = data.(request);
