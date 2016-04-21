function varargout = emlnew(machineName)
%EMLNEW Temporary m-file that creates a new model
% with a single eML block in it. MUST BE REMOVED ONCE
% EML BLOCK IS PART OF SIMULINK.

% Copyright 2002-2004 The MathWorks, Inc.


error(nargchk(0,1,nargin));
error(nargchk(0,2,nargout));

METHOD = sf('method','method');
GET = sf(METHOD,'get');
SET = sf(METHOD,'set');

% If a name was passed in, use it. 
if nargin==1,
	if ~isstr(machineName), warning('Bad input to emlnew command!'); return; end;
	h = new_system(machineName);
else,
	h = new_system;
end
modelName = get_param(h,'name');
newMachineH = sf('new', 'machine', '.name', modelName, '.simulinkModel', h);

if(isempty(sf('find',sf('MachinesOf'),'machine.name','emllib')))
   eml_lib([],[],[],'load');
end
open_system(h);
name = get_param(h,'Name');
emlLong = ['Embedded' 10 'MATLAB Function'];
sfBlk = [name,'/', emlLong ];
add_block(['eml_lib/', emlLong], sfBlk);

sfBlkH = get_param(sfBlk, 'handle');


if nargout>0
   varargout{1} = h;
   if(nargout>1)
      varargout{2} = newMachineH;
   end
end


