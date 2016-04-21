function id = hostid
%HOSTID MATLAB server host identification number.
%       It usually returns a single element cell array
%       containing the identifier as a string. UNIX systems
%       may have more than one identifier. In this case,
%       HOSTID returns a cell array with an identifier in
%       each cell.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11.2.1 $  $Date: 2002/08/25 10:33:35 $

com = computer;
if strcmp(com(1:2),'PC')
   idc{1} = license;
else % Unix or VMS
%
% ---------------------------------------------------------
% Handle colon separated list on Unix. Values returned
% will be either:
%
%    hostid             - 'SERVER', hostid and 'MATLAB'
%    license            - 'Linux' or 'linux', 'siteID:',
%                          siteid and 'MATLAB'
%    port@host          - not 1700@BOGUS
%    'DEMO'             - 'DEMO' and 'MATLAB'
%    'server_no_matlab' - 'SERVER', hostid and no 'MATLAB'
%    'demo_no_matlab'   - 'DEMO' and no 'MATLAB'
%    'other_matlab'     - none of the above and 'MATLAB'
%    'unknown_contents' - none of the above and no 'MATLAB'  
%    'no_file'          - file does not exist
% ---------------------------------------------------------
%
   if isunix
      rt = getenv('LM_LICENSE_FILE');
      rt = files2cell(rt);
   else % VMS
      rt{1} = 'LM_LICENSE_FILE:';
   end
%
   idc{1} = [];
   nf = length(rt);
   i = 0;
   for iloop = 1:nf
      fid = fopen(rt{iloop},'r');
      if fid == -1
 	 if port_at_host(rt{iloop}) & ~strcmp(rt{iloop},'1700@BOGUS')
             i = i + 1;
	     idc{i} = rt{iloop};
	 elseif ~strcmp(rt{iloop},'1700@BOGUS')
             i = i + 1;
             idc{i} = 'no_file';
	 end
      else 
         i = i + 1;
         k = []; d = []; m = []; l = []; l2 = [];
         while 1
            s = fgetl(fid); 
            if ~isstr(s), break, end    
            if isempty(k)
               k = findtok(s,'SERVER');
               if ~isempty(k), break, end
            end
            if isempty(d)
                d = findtok(s,'DEMO');
            end
            if isempty(m)
                m = findtok(s,'MATLAB');
            end
            if isempty(l)
                l = findtok(s,'Linux');
                if isempty(l)
                    l = findtok(s,'linux');
                end
            else
                l2 = findtok(s,'SiteID:');
                if ~isempty(l2), break, end
            end
         end
%
% look for MATLAB in the rest of the file if not found earlier
%
         if isempty(m)
            while isempty(m)
               s2 = fgetl(fid); 
               if ~isstr(s2), break, end        
               m = findstr('MATLAB',s2);
            end
         end
         fclose(fid);
         if ~isempty(k) & ~isempty(m)
%
% hostid case
%
            t = nthstrtok(s,3);
            if ~isempty(t)
               idc{i} = t;
            else
               idc{i} = 'unknown_contents';
            end
         elseif ~isempty(l) & ~isempty(l2) & ~isempty(m)
%
% siteid case (old style Linux)
%
            t = nextstrtok(s,'SiteID:');
            if ~isempty(t)
               idc{i} = t;
            else
               idc{i} = 'unknown_contents';
            end
         elseif ~isempty(d) & ~isempty(m)
%
% 'DEMO'
% 
            idc{i} = 'DEMO';
         elseif ~isempty(k) & isempty(m)
%
% 'server_no_matlab'
%
            t = nthstrtok(s,3);
            if ~isempty(t)
               idc{i} = 'server_no_matlab';
            else
               idc{i} = 'unknown_contents';
            end
         elseif ~isempty(d) & isempty(m)
%
% 'demo_no_matlab'
%
            idc{i} = 'demo_no_matlab';
         elseif ~isempty(m)
%
% 'other_matlab'
%
            idc{i} = 'other_matlab';
         else
            idc{i} = 'unknown_contents';
         end
      end
   end
end
if nargout == 0
   disp(idc)
else
   id = idc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c = files2cell(p)
%FILES2CELL Split files into cell.
%   FILES2CELL(files) returns a cell array of strings
%   containing the individual file elements.

seps = [0 find(p==':') length(p)+1];

c = cell(length(seps)-1,1);
for i=1:length(seps)-1,
  c{i} = p(seps(i)+1:seps(i+1)-1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ix = findtok(s,tok)
%FINDTOK Return indices of token in string.
%   FINDTOK(string,token) returns a vector of starting
%   indices of the token in the string. A token is
%   found if it surrounded by whitespace. The
%   beginning and end of the string is considered
%   whitespace.

ix = findstr(s,tok);
if isempty(ix), return, end
tix = [];
sl = length(s); tl = length(tok); ixl = length(ix);
for j = 1:ixl
   if (ix(j) == 1 | isspace(s(ix(j)-1))) & ...
      (ix(j)+tl-1 == sl | isspace(s(ix(j)+tl)))
      tix = [ tix ix(j) ];
   end
end
ix = tix;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = nthstrtok(s,n)
%NTHSTRTOK Returns the n-th token t in the string s.

t = [];
for i=1:n
   [t,s] = strtok(s);
   if isempty(t), return, end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function t = nextstrtok(s,tok)
%NEXTSTRTOK Returns the next token t after the first
%   occurrence of tok in s.

t = [];
ix = findtok(s,tok);
if isempty(ix), return, end
t = nthstrtok(s(ix(1):length(s)),2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = port_at_host(s)
%PORT_AT_HOST Is s of the form port@host?
%   PORT_AT_HOST(s) returns 1 if s of the form
%   port@host where port is a number else it returns 0

status = 0;

atvec = find(s=='@');
if length(atvec) == 1
    port = s(1:atvec(1)-1);
    if length(port) == length(find(port=='0'|...
			           port=='1'|...
				   port=='2'|...
				   port=='3'|...
				   port=='4'|...
				   port=='5'|...
				   port=='6'|...
				   port=='7'|...
				   port=='8'|...
				   port=='9'))
	status = 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
