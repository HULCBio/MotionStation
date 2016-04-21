function varargout = mdbstatus(filename)
%MDBSTATUS  dbstatus for the Editor/Debugger
%   MDBSTATUS receives dbstatus output for a file and displays resulting
%   line numbers separated by a semicolon and with condition surrounded by
%   the character "1".   For example, 
%       70 (1 == 1) ;55  ; (spaces are the non-printable character "1")  
%   indicates a breakpoint at line 70 with condition (1 == 1) and a
%   breakpoint at line 55 with no condition.
% 
%   If no arguments are given, it returns the status of each
%   debug condition separated by a semicolon.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $ 

n = nargin;
error(nargchk(0,1,n));

origw = warning('off');
try
   if n == 0
      result = localGetConditions;
   else
      result = localGetFileBreakpoints(filename);
   end
catch	
   warning(origw);
   rethrow(lasterror);
end
warning(origw);

if nargout == 0
   if ~isempty(result), disp(result); end
else
   varargout{1} = result;
end

%-------------------------
function result = localGetConditions	
try
  s=dbstatus;
catch
  s='';
end

result='';
for i=1:size(s,1) 
   if size(s(i).cond,2) ~= 0
      % cond is 'error', warning', 'naninf', or 'caught error'
      result=[ result sprintf('%s',s(i).cond) ';' ]; 
      % each cond (except naninf) may have identifiers
      identifier = s(i).identifier;
      if length(identifier) > 0
          if strcmp(identifier{1}, 'all') == 1
              result = [result 'all;'];
          else
              % Add identifiers and separate them with a comma
              % and end all of them with a semicolon
              for j = 1:length(identifier)
                  result = [result sprintf('%s', s(i).identifier{j}) ','];
              end
              result = [result ';'];
          end
          
      end
   end 
end


%-------------------------
function result = localGetFileBreakpoints(arg)	
% For files that aren't on the path, suppress the 
% error that dbstatus would generate.
try
   savedErr = lasterror;
   if length(arg) < 3
      s = '';
   elseif isequal(arg(length(arg)-1:end), '.m')
      s=dbstatus(arg);
   else
      s = '';
   end;
catch
  s='';
  lasterror(savedErr);
end

result='';
for i=1:size(s,1) 
   if isempty(strfind(s(i).name,'>@'))
      for j=1:size(s(i).line,2)
         cond = s(i).expression{j};
         result=[ sprintf('%d',s(i).line(j)) 1 cond 1 ';' result]; 
      end 
   end
end
