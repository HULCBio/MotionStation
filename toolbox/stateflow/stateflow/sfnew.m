function varargout = sfnew(machineName)
%SFNEW Creates a new SIMULINK model and Stateflow diagram.
%        SFNEW ('MACHINENAME') creates a new Simulink model with the specified
%        name containing an empty Stateflow diagram (block) with the name 'Chart'
%        SFNEW without any arguments uses 'untitled' as the name of the new Simulink model.
%        See also STATEFLOW, SFSAVE, SFPRINT, SFEXIT, SFHELP.

%
%	 Jay R. Torgerson
%   E. Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.19.2.3 $  $Date: 2004/04/15 01:01:41 $

if ~sf('License', 'basic'),    
    open_system('sf_examples');
    sf('Private', 'sf_demo_disclaimer');
    return;
end;

error(nargchk(0,1,nargin));
error(nargchk(0,2,nargout));

METHOD = sf('method','method');
GET = sf(METHOD,'get');
SET = sf(METHOD,'set');

% If a name was passed in, use it. 
if nargin==1,
	if ~isstr(machineName), warning('Bad input to sfnew command!'); return; end;
	h = new_system(machineName);
else,
	h = new_system;
end
modelName = get_param(h,'name');
newMachineH = sf('new', 'machine', '.name', modelName, '.simulinkModel', h);

mustClose = 0;
if(isempty(sf('find',sf('MachinesOf'),'machine.name','sflib')))
    mustClose = 1;
   sflib([],[],[],'load');
end
open_system(h);
name = get_param(h,'Name');
sfBlk = [name,'/Chart'];
add_block('sflib/Chart',sfBlk);

sfBlkH = get_param(sfBlk, 'handle');


if nargout>0
   varargout{1} = h;
   if(nargout>1)
      varargout{2} = newMachineH;
   end
end

if(mustClose)
    bdclose('sflib');
end
