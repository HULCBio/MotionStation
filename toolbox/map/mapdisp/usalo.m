function out = usalo(request)

% USALO returns data from the USALO atlas data file
% 
%   USALO types a list of requests for the USALO Mat-file to the screen.
%   
%   s = USASLO('request') returns the requested data.  Valid requests for two 
%   column vectors are 'conusvec', 'statebvec' and 'gtlakevec'.  Valid 
%   requests for geographic data structures are 'conus', 'state', 
%   'stateborder' and 'greatlakes'.  This command can be used as an argument 
%   to other commands, such as DISPLAYM(USALO('conus')).
%  
%   See also COAST, WORLDLO, USAHI, USALO.MAT

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/08/01 18:23:09 $

if nargin == 0
	disp('USALO atlas data:')
	disp('    ')
	disp('  Vector data: Two-column vectors of lat and long')
	disp('    ')
	disp('    conusvec       - Conterminous United States outline')
	disp('    statebvec      - Borders between states')
	disp('    gtlakevec      - Great Lakes outlines')
	disp('    ')
	disp('  Geographic Data Structures: ')
	disp('    ')
	disp('    conus          - Conterminous United States outline')
	disp('    state          - State outlines')
	disp('    stateborder    - Borders between states')
	disp('    greatlakes     - Great Lakes outlines')
	disp('    ')
	return
end

switch request
case 'conusvec'
	load('usalo','uslat')
	load('usalo','uslon')
	out = [uslat uslon];
case 'statebvec'
	load('usalo','statelat')
	load('usalo','statelon')
	out = [statelat statelon];
case 'gtlakevec'
	load('usalo','gtlakelat')
	load('usalo','gtlakelon')
	out = [gtlakelat gtlakelon];
otherwise

	load('usalo',request)
	if exist(request) ~= 1
		error([ request ' not found in USALO.MAT'])
	end
	
	eval(['out = ' request ';'])

end

