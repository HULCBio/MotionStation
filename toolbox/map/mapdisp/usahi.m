function out = usahi(request)

% USAHI returns data from the USAHI atlas data file
% 
%   USAHI types a list of the atlas data variables in the USAHI Mat-file to 
%   the screen.
%   
%   s = USASHI('request') returns the requested variable.  Valid requests are 
%   'stateline','statepatch', and 'statetext'.  This command can be used as 
%   an argument to other commands, such as DISPLAYM(USAHI('statepatch')).  
%  
%   See also COAST, WORLDLO, USALO, USAHI.MAT

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/08/01 18:23:08 $


if nargin == 0
	disp('USAHI atlas data:')
	disp('    ')
	disp('  Geographic Data Structures: ')
	disp('    ')
	disp('    stateline      - State outline as filled patches')
	disp('    statepatch     - State outlines as lines')
	disp('    statetext      - State names as text')
	disp('    ')
	return
end

load('usahi',request)
if exist(request) ~= 1
	error([ request ' not found in USAHI.MAT'])
end

eval(['out = ' request ';'])

