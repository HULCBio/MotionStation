function disp(ff)
%DISP Display properties of Link to Code Composer Studio(R) IDE.
%   DISPLAY(CC) displays a formatted list of values that describe 
%   the CC object.  

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.9.2.3 $ $Date: 2004/04/08 20:46:05 $

fprintf('\nFUNCTION Object\n');
fprintf('  Function name       : %s\n',ff.name);
%--------------
if ~isempty(ff.filename)
fprintf('  File found          : %s\n',ff.filename);
end
%---------------
if ~isempty(ff.address.start)
fprintf('  Start address       : ');
fprintf('[%s %s]\n',num2str(ff.address.start(1)),num2str(ff.address.start(2)));
end
%------------
% if ~isempty(ff.address.end)
% fprintf('  End address       : ');
% fprintf('[%s %s]\n',num2str(ff.address.end(1)),num2str(ff.address.end(2)));
% end
%------------
fprintf('  All variables       : ');
if length(ff.variables)==0
    fprintf('Info not available\n');
else
	for i=1:length(ff.variables)
        if i==length(ff.variables),
            fprintf('%s\n',ff.variables{i});
        else        
            fprintf('%s, ',ff.variables{i});    
        end        
	end
    
end
%------------
fprintf('  Input variables     : ');
if length(ff.inputnames)==0 & isempty(ff.funcdecl)
    fprintf('Info not available\n');
elseif length(ff.inputnames)==0 & ~isempty(ff.funcdecl)
    fprintf('None\n');
else
    
	for i=1:length(ff.inputnames)
        if i==length(ff.inputnames),
            fprintf('%s\n',ff.inputnames{i});
        else        
            fprintf('%s, ',ff.inputnames{i});    
        end        
	end
    
end
%------------
fprintf('  Allocated variables : ');
allocatedvarnames = ff.stackallocation.varnames;
if isempty(allocatedvarnames) & isempty(ff.funcdecl)
    fprintf('Info not available\n');
elseif isempty(allocatedvarnames) & ~isempty(ff.funcdecl)
    fprintf('None\n');
else
    
    for i=1:length(allocatedvarnames)
        if i==length(allocatedvarnames),
            fprintf('%s\n',allocatedvarnames{i});
        else        
            fprintf('%s, ',allocatedvarnames{i});    
        end        
    end
    
end

% %------------
% fprintf('  Local variables   : ');
% if length(ff.localvars)==0
%     fprintf('Information not available\n\n');
% else
%     
% 	for i=1:length(ff.localvars)
%         if i==length(ff.localvars),
%             fprintf('%s\n\n',ff.localvars{i});
%         else        
%             fprintf('%s, ',ff.localvars{i});    
%         end        
% 	end
%     
% end
%------------
if ~isempty(ff.type)
fprintf('  Return type         : %s\n',ff.type);
else
fprintf('  Return type         : Info not available\n');
end
%--------------
fprintf('\n');

%[EOF] disp.m