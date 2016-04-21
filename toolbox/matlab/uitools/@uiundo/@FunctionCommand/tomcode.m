function [str] = tomcode(hThis)

% Copyright 2002 The MathWorks, Inc.

strFunction = func2str(hThis.Function);
strArgs = locGenArgStr(hThis);
strComment = sprintf('%% Called by %s',lower(hThis.Name));

str = sprintf('%s(%s); %s',strFunction,strArgs,strComment);

% ---------------------------------------- %
function [strArgs] = locGenArgStr(hThis)
% Generates string representing command input arguments

strArgs = '';

% traverse each input argument and add to output 
vargin = hThis.Varargin;

for k = 1:length(vargin)
   arg = vargin{k};
   str = '...';
 
   % If it is a handle, then make the output
   % variable appear as 'h_myclassname'
   if ishandle(arg) & arg~=0
      h = handle(arg);  
      str = sprintf('h_%s',h.classhandle.Name); 
      
   % If it is numeric, display number
   elseif isnumeric(arg)
     
      [s] = size(arg);
      
      % For now, only display 1-d arrays
      if ndims(s) <= 2
         str = num2str(arg,' %0.5g,');
      end
      
      str = sprintf('[%s]',str);
   
   % If it is a char array, display it as is
   elseif ischar(arg)
      str = ['''',arg,''''];    
      
   % For now, don't support other types like structures or cell arrays      
   else
     error('Assert');
   end
   
   % Concatenate input arguments with a comma
   if k > 1
      strArgs = sprintf('%s, %s',strArgs,str);
   else
      strArgs = str;
   end
   
end

