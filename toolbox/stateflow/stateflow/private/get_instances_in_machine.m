function instances = get_instances_in_machine( machine, varargin )
% return a vector of all instances in this machine
% as a necessary side effect, load them in memory (silently)
% it is also possible to pass a vector of SL links as a 
% second argument. in this case, the first argument is ignored

%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.10.2.2 $ $Date: 2004/04/15 00:58:03 $

instances = [];
if nargin <= 1
   chartLinks = machine_bind_sflinks(machine);
else
   chartLinks = varargin{1};
end

for i = chartLinks
   ref = get_param(i, 'ReferenceBlock');
   % can't use bdroot, because we dont know if the model is loaded.
   % usually, it is, when user opens a model, however, it is not,
   % if he opens and closes the library.
   %rt = bdroot(ref);
   
   % since model name cannot contain slashes, model name is
   % part of blk name before the first slash
   slashes = find ( ref == '/' );
   if ~isempty( slashes )
      rt = ref (1:slashes(1)-1);
      sf_load_model( rt );
      % now do the jay's trick to silently load sf block to memory
      lockval = get_param( rt, 'lock' );
      set_param( rt, 'lock','off' );  %this loads it
      set_param( rt, 'lock',lockval );%this restores the lock value (usually on)
      % end of jay's trick
      
      refH = get_param(ref, 'handle');
      thisInstanceId = sf('find','all','instance.simulinkBlock',refH);
      instances = [ instances thisInstanceId ];
   end
end
