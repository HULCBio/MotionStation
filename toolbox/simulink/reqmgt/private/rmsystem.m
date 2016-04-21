function result = rmsystem(filename)
%RMSYSTEM returns the system name from a a filename.
%   result = RMSYSTEM(FILENAME) returns the
%   Simulink system name, which is the name of the file without
%   path and extension.  For example,
%      s = rmsystem('c:\matlab\toolbox\simulink\simdemos\clutch.mdl');
%   returns 'clutch' in s.  
%   If FILENAME is an M-file, the file extension is retained.
%   For example, 
%      s = rmsystem('c:\matlab\toolbox\simulink\simdemos\test.m');
%   returns 'test.m' in s.
%
%   result = RMSYSTEM() does the thing as RMSYSTEM(FILENAME) but
%   uses the current system (gcs).
%
%   The file must exist.  A Simulink system will be opened if it isn't.
%
%   Returns: result on success.  All errors are thrown.
%

%  Author(s): M. Greenstein, 11/05/98
%  Copyright 1998-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $   $Date: 2004/04/15 00:36:46 $

% dboissy says:
% Implemented the described functionality in a simpler,
% more concise, form.
[pathStr, nameStr, extStr, versionStr] = fileparts(filename);
if strcmp(extStr, '.mdl')
	open_system(filename);
end
result = nameStr;

% Validate argument.
% if (~exist('filename'))
%     error('Missing filename input argument.');
% end
% 
% if (length(filename))
%     % Error if not .mdl file or .m file
%     s = lower(filename);
%     if (~strcmp(s(end - 1:end), '.m') & ~strcmp(s(end - 3:end), '.mdl'))
%         error('Invalid file type.  Must be .mdl or .m.');
%     end
% else
%     % Use the current system root.
%     filename = gcs;
%     if (isempty(filename))
%         error('There is no system currently opened.');
%     end
%     en = findstr(filename, '/');
%     if (~isempty(en))
%         en = min(en) - 1;
%     else
%         en = length(filename);
%     end
%     result = filename(1:en);
%     return;
% end
% 
% % Does file actually exist?
% s = exist(filename);
% if (~length(s))
%     error('File not found or is not on the MATLAB path.');
% end
% 
% % Assume filename is a fully qualified filename if it
% % has a dot anywhere.  Use which to validate. 
% dot = findstr(filename, '.');
% if (isempty(dot))
%     error('Invalid file name.');
% else
%     dot = dot(end);
%     s = lower(filename);
%     en = findstr(s(end - 1: end), '.m');
%     if (isempty(en)) 
%         en = dot - 1;
%     else
%         en = dot + 1;
%     end
%     be = findstr(filename, filesep);
%     if (~isempty(be))
%         be = max(be) + 1;
%     else
%         be = 1;
%     end
% end
% 
% result = filename(be:en);
% 
% % Open a system if it's not opened.
% if (strcmp(s(end - 3:end), '.mdl'))
%     a = find_system(0, 'blockdiagramtype', 'model');
%     b = get_param(a, 'name');
%     if (isempty(b))
%         open_system(s);
%     else % See if it's among the opened.   
%         c = strcmp(result, b);
%         r = sum(c);
%         if (~r)
%             open_system(s);
%         end
%     end
% end
% 
% %end function result = rmsystem(filename)
