function dealloc(cc,objname)
% DEALLOC(Private) Deallocate an object from the stack.
%  DEALLOC(CC) deallocates a block of data that is recently allocated on
%  the stack through ALLOC.
%
%  DEALLOC(CC,'all') deallocates all data previously allocated on the
%  stack.
%
%  Example:
% 	>> createmem(cc,'400',10)
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA, end=0x40A
%       Objects allocated  : 0
%       Top of stack       : 0x400
% 	>> alloc(cc,3*ones(1,3),'int',3)
% 	>> cc.stack
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA, end=0x40A
%       Objects allocated  : 1
%       Top of stack       : 0x403
% 	>> alloc(cc,1*ones(1,3),'int',5)
% 	>> cc.stack
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA, end=0x40A
%       Objects allocated  : 2
%       Top of stack       : 0x408
% 	>> dealloc(cc)
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA, end=0x40A
%       Objects allocated  : 1
%       Top of stack       : 0x403
% 	>> dealloc(cc,'all')
% 	Stack Object: 
%       Stack area defined : start=0x400, length=0xA, end=0x40A
%       Objects allocated  : 0
%       Top of stack       : 0x400
%
%  See also ALLOC, CREATEMEM.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/11/30 23:06:58 $

error(nargchk(1,2,nargin));

stk = cc.stack;
PopTopOfStack = 0;

if stk.numofstackobjs == 0
    warning('No action is taken, there are no objects allocated on the stack.');
    return;
end

if nargin == 2
    if ~ischar(objname)
        error(generateccsmsgid('InvalidInput'),'Second parameter must be a string.');
    end
    if ~strcmpi(objname,'all')
        % Comment deallocating specific objects - only allow 'all'
        error(generateccsmsgid('InvalidInput'),...
            ['Invalid option ''' objname ''', the only option recognized is ''all''.']);
		%         sobjsfields = fieldnames(get(stk,'stackobjects'));
		%         ndx = find(strcmpi(objname, sobjsfields));
		%         if isempty(ndx)
		%             error(generateccsmsgid('InvalidInput'),['Specified object name ''' objname ''' does not point to any allocated data.']);
		%         elseif ndx == stk.numofstackobjs
		%             PopTopOfStack = 1;
		%         end   
    end
else
    sobjsfields = fieldnames(get(stk,'stackobjects'));
    objname = sobjsfields{end};
    PopTopOfStack = 1;
end

if strcmpi(objname,'all')
    % clean up SP list
    stk.stacksplist = [];
    stk.toslist = stk.toslist(1);
    stk.storageUnitsLeft = stk.size;
    % set new top of stack value
    set(stk, 'topofstack', [stk.toslist,stk.topofstack(2)]);
    % update number of stack objects
    set(stk,'numofstackobjs',0);
    % remove all objects
    set(stk, 'stackobjects', struct([]));
else
    if PopTopOfStack 
        % set new top of stack value
        set(stk, 'topofstack', [stk.toslist(end-1),stk.topofstack(2)]);
        % truncate SP list
        set(stk, 'stacksplist', stk.stacksplist(1:end-1));
        % truncate TOS list
        set(stk, 'toslist', stk.toslist(1:end-1));
        % re-adjust number of storage units left
		if cc.stack.growsToLowAddr
            cc.stack.storageUnitsLeft = cc.stack.topofstack(1) - cc.stack.startaddress(1) + 1;
		else
            cc.stack.storageUnitsLeft = cc.stack.endaddress(1) - cc.stack.topofstack(1) + 1;
		end
    end
    % update number of stack objects
    stackobjsize = get(stk,'numofstackobjs');
    set(stk,'numofstackobjs',stackobjsize - 1);
    % remove field of popped object
    sobjs = get(stk,'stackobjects');
    ndx = find(strcmpi(objname, fieldnames(sobjs)));
    poppedfield = sobjsfields{ndx};   
    sobjs = rmfield(sobjs,poppedfield);  
    set(stk,'stackobjects',sobjs);
end

disp(cc.stack);

% [EOF] dealloc.m