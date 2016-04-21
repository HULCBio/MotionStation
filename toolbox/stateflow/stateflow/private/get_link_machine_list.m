function	[sfLinkMachines,sfLinkMachineFullPaths,sfLinkLibFullPaths]  = get_link_machine_list(machineName,targetName)
%
%
%	Copyright 1995-2002 The MathWorks, Inc.
%	$Revision: 1.9.2.1 $

	if ~ischar(machineName)
		machineId = machineName;
		machineName = sf('get',machineId,'machine.name');
	else
		machineId = sf('find','all','machine.name',machineName);
	end

	sfLinkMachines = [];
   sfLinkMachineFullPaths = [];
   sfLinkLibFullPaths = [];
   linkCharts = sf('get',machineId,'machine.sfLinks');
	if(length(linkCharts)==0 | sf('get',machineId,'machine.isLibrary'))
		return;
	end
	linkMachineHandles = [];
	for i = 1:length(linkCharts)
      linkChart = linkCharts(i);
      refChart = get_param(linkChart,'referenceblock');
      refMachineHandle = get_root_handle(refChart);
      if(isempty(linkMachineHandles))
         linkMachineHandles = refMachineHandle;
      else
         linkMachineHandles = [linkMachineHandles;refMachineHandle];
      end
	end
	linkMachineHandles = unique(linkMachineHandles);

	numMachines = length(linkMachineHandles);
	if(numMachines>1)
		sfLinkMachines = get_param(linkMachineHandles,'name');
	else
		sfLinkMachines{1} = get_param(linkMachineHandles,'name');
	end

	sort(sfLinkMachines);
	for i=1:numMachines
		try
			sfLinkMachineFullPaths{i} = get_param(sfLinkMachines{i},'filename');
		catch,
      	sfLinkMachineFullPaths{i} = which([sfLinkMachines{i},'.mdl']);
		end
	end
	if(isunix)
	  libext = 'a';
	else
	  libext = 'lib';
	end
	for i=1:length(sfLinkMachineFullPaths)
		linkMachineFullPath = sfLinkMachineFullPaths{i};
		sfLinkLibFullPaths{i} = fullfile(pwd,[sfLinkMachines{i},'_',targetName,'.',libext]);
	end

	return;

   
   
function str = get_root(blkName)

	e = min(find(blkName=='/'));
   if(~isempty(e))
      str = blkName(1:e-1);
   else
      str = blkName;
   end

function rootHandle = get_root_handle(blkName)

	e = min(find(blkName=='/'));
   if(~isempty(e))
      str = blkName(1:e-1);
   else
      str = blkName;
   end
   try,
      rootHandle = get_param(str,'handle');
   catch,
      feval(str,[],[],[],'load');
      rootHandle = get_param(str,'handle');
   end
	
function s1 = strip_trailing_new_lines(s)

if isempty(s)
    s1 = s;
else
  % remove trailing blanks
  [r,c] = find( s ~= ' ' & s ~= 10 & s ~= 0);
  s1 = s(:,1:max(c));
  if isempty(s1) 
    s1 = '';
  end
end



