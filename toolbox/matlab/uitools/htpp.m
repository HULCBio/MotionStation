function strout=htpp(cmd,link);
%HTPP   Hypertext preprocessor for HTHELP.
%   STR = HTPP(CMD, LINK) creates an HTML string (STR) for HTHELP.
%   This function is not intended to be called directly by users.
%
%   Valid CMD strings are 'main', 'contents', and 'function' which
%   indicate the type of text file that is to be converted to HTML.
%
%   HTPP by itself or HTPP('main') creates an HTML string for the main
%   MATLAB help screen.
%
%   HTPP('contents', LINK) creates an HTML string for the Contents.m
%   file of the topic contained in the LINK string.
%
%   HTPP('function', LINK) creates an HTML string for the help text
%   of the m-file contained in the LINK string.
%
%   Proper HTML hypertext links are set up in the output file so that
%   HTHELP can access topics related to the one being displayed.
%
%   See also HTHELP and LOADHTML.
%
%   This function is OBSOLETE and may be removed in future versions.

%   P. Barnard 12-28-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.32.4.2 $  $Date: 2004/04/10 23:33:52 $

if nargin < 2
   link = 'matlab_help';
   if nargin < 1
      cmd = 'main';
   end
end

% Initializations for all options.
tab='     '; % Tab character.

% Process path into a general help file.
if strcmp(cmd,'main')
   % Initialization
   p=1; % Position in current path string.
   pthp=1; % Position in total path string.

   % Find the correct path and file separtors based on the platform.
   pathsep = ':';
   filesep = '/';
   c = computer;
   if strcmp(c(1:2),'PC')
      pathsep = ';';
      filesep = '\';
   end

   % Parse the 'path' command to get all paths.
   pth=path;
   if strcmp(c(1:2),'PC')
      indx=find(pth=='/');  % For PC, make all slashes '\'.
      if ~isempty(indx), pth(indx) = char(ones(1,length(indx))*real('\')); end
   end
   pthln=length(pth);
   p=find(pth==pathsep);
   if pth(1)==pathsep
      pth(1)=[];   % Remove the first character if
      p(1)=[];     % it is a colon.
      p=p-1;
      pthln=length(pth);
   end
   curpth=pth(1:p(1)-1);

   % Begin the output text string with some header information.
   stro=sprintf('%s',[link '|']);

   % Write out the header information for this help screen.
   pgttl='MATLAB HELP';
   stro=[stro sprintf('%s\n',['<title>' pgttl '</title>'])];
   whtspc=blanks(floor((55-1.27*length(pgttl))/2));
   stro=[stro sprintf('%s\n',[' <p><tt><h4>' whtspc pgttl '</h4><br><pre>'])];

   % Loop through each of the topics.
   while ~isempty(curpth)
      % Find the topic name in the current path.
      p=find(curpth==filesep);
      if isempty(p)
         p=0;
      else
         p=p(length(p));
      end
      ln=length(curpth);
      topic=curpth(p+1:ln);
      filesep1 = filesep;


      % Try to open the Contents.m file.
      cfid=fopen([curpth filesep1 'Contents.m']);

      % If successful file open:
      if cfid~=-1
         % Find the descriptive first line.
         cstr=fgetl(cfid);
         if ~isempty(cstr)
             cstr(1)=[]; % Remove the '%'.
         end
         fclose(cfid);
         callback = ['<a cont="' curpth filesep1 'Contents.m">' topic '</a>'];

      else
         % File not found.
         cstr='(No table of contents file)';
         callback = ['< >' topic '< >'];

      end

      % Create the description spacing over to the right the number of spaces necessary to
      % line up all descriptions.
      desc=[blanks(10-length(topic)) '- ' cstr];

      % Write out a line in the string with the topic and built-in link to the correct 
      % Contents.m file.
      stro=[stro sprintf('%s\n',[tab callback desc])];

      % Get the next topic and path.
      pthp=pthp+ln+1; % add 1 to skip over ':'
      if pthp <= pthln
         p=find(pth(pthp:pthln)==pathsep);
      else
         p=[];
      end
      if isempty(p)
         curpth=pth(pthp:pthln);
      else
         curpth=pth(pthp:pthp+p(1)-2);
      end

   end % end while
   stro=[stro sprintf('%s\n',['</pre>'])];

% Process a Contents.m file.
elseif strcmp(cmd,'cont')
   % Open the output string.
   stro=sprintf('%s',[link '|']);

   % Parse the correct Contents.m file.
   fid2=fopen(link,'r');
   if fid2==-1 strout=[link '| ']; return; end

   % Begin reading the Contents.m file.
   str=fgetl(fid2);

   % Write out the header information for this help screen.
   pgttl=str(2:length(str));
   pgttl(pgttl=='.')=[];
   stro=[stro sprintf('%s\n',['<title>' pgttl '</title>'])];
   whtspc=blanks(floor((55-1.27*length(pgttl))/2));
   stro=[stro sprintf('%s\n',[' <p><tt><h4>' whtspc pgttl '</h4><br><pre>'])];

   % Loop through the contents.
   while isstr(str) & (str(1)=='%')
      % Write out a text file with sub-topics and built-in links to the correct m-files.
      str(1)=[];
      ln=length(str);
      if ~isempty(findstr(str,' - '))
         % Build a link to an m-file.
         for p=1:ln
            if ~isspace(str(p)) break; end
         end % end for   
         for q=p:ln
            if isspace(str(q)) break; end
         end % end for
         mfn=str(p:q-1);
         desc=str(q:ln); % Note: last character is a line feed.
         stro=[stro sprintf('%s',[str(1:p-1) '<a func="' mfn '.m">' mfn '</a>' desc])];
               
      else
         % Just spit out the line turning special characters & and < into escape codes.
         amploc=find(str=='&');
         p=0; % Counter for each of the ampersands.
         if ~isempty(amploc) tmpstr=str(1:amploc(1)-1); end
         while ~isempty(amploc)
            p=p+1;
            if p==length(amploc)
               if amploc(p)==ln
                  tmpstr=[tmpstr '&amp;'];
               else
                  tmpstr=[tmpstr '&amp;' str(amploc(p)+1:ln)];
               end
               str=tmpstr;
            else
               tmpstr=[tmpstr '&amp;' str(amploc(p)+1:amploc(p+1)-1)];
            end
            amploc(p)=0;
         end % end while
         p=find(str=='<');
         while ~isempty(p)
            if p(1)+1 < length(str)
               str=[str(1:p(1)-1) '&lt;' str(p(1)+1:length(str))];
            else
               str=[str(1:p(1)-1) '&lt;'];
            end
            p=find(str=='<');
         end % end while

         stro=[stro sprintf('%s',str)];

      end % end if

      % Get the next line.
      str=fgets(fid2);

   end % end while

   stro=[stro sprintf('%s\n',['</pre>'])];
  
% Process a m-file.
elseif strcmp(cmd,'func')
   % Open the output string.
   stro=sprintf('%s',[link '|']);

   % Parse the correct m-file.
   fid2=fopen(link,'r');
   if fid2==-1 strout=[link '| ']; return; end

   % Begin reading the .m file.
   str=fgets(fid2);
   while str(1)~='%'
      str=fgets(fid2); % Skip down until we reach a '%'
   end

   % Write out the header information for this help screen.
   ln=length(str);
   for p=1:ln
      if isletter(str(p))
         for q=1:ln-p
            if isspace(str(p+q-1)) break; end
            pgttl(q)=str(p+q-1);
         end
         break;
      end
   end   
   stro=[stro sprintf('%s\n',['<title>' pgttl '</title>'])];
   whtspc=blanks(floor((55-1.27*length(pgttl))/2));
   stro=[stro sprintf('%s\n',[' <p><tt><h4>' whtspc pgttl '</h4><br><pre>'])];

   % Loop through the file.
   LinkFound = 0;
   while isstr(str) & ~isempty(find(str(1)=='%'))
      % Write out a text string containing the m-file help and links to other m-files.
      str(1)=[];
      ln=length(str);
      p=findstr(lower(str),'see also');
      if ~isempty(p)
         p=min(p)+8;
      elseif LinkFound,
         p = 1;
      end
      if ~isempty(p)
         % Build a link to an m-file.
         tmpstr=str(1:p-1); % Begin the output string.
         while p<=ln
            if abs(str(p))>=65 & abs(str(p))<=90 % if uppercase
               q=p+min([min(find(str(p:ln)==',')),min(find(str(p:ln)==' ')),...
                      min(find(str(p:ln)=='.')),(ln-p+1)])-1;
               mfn=str(p:q-1);
               tmpstr=[tmpstr '<a func="' lower(mfn) '.m">' mfn '</a>'];
               p=q;
            else
               tmpstr=[tmpstr str(p)];
               p=p+1;
            end % end if
         end % end while
         if findstr(tmpstr,'a func')
            LinkFound = 1;
         else
            LinkFound = 0;
         end
         stro=[stro sprintf('%s',tmpstr)]; % Print out the full line.
      else
         % Just spit out the line turning special characters & and < into escape codes.
         %amploc=find(str=='&');
         %p=0; % Counter for each of the ampersands.
         %if ~isempty(amploc)
         %   tmpstr=str(1:amploc(1)-1);
         %end
         %while ~isempty(amploc)
         %   p=p+1;
         %   if p==length(amploc)
         %      if amploc(p)==ln
         %         tmpstr=[tmpstr '&amp;'];
         %      else
         %         tmpstr=[tmpstr '&amp;' str(amploc(p)+1:ln)];
         %      end
         %      str=tmpstr;
         %   else
         %      tmpstr=[tmpstr '&amp;' str(amploc(p)+1:amploc(p+1)-1)];
         %   end
         %   amploc(p)=0;
         %end % end while
         %p=find(str=='<');
         %while ~isempty(p)
         %   if p(1)+1 < length(str)
         %      str=[str(1:p(1)-1) '&lt;' str(p(1)+1:length(str))];
         %   else
         %      str=[str(1:p(1)-1) '&lt;'];
         %   end
         %   p=find(str=='<');
         %end % end while
         str=strrep(strrep(str,'&','&amp;'),'<','&lt;');
         stro=[stro sprintf('%s',str)];
      end % end if

      % Get the next line.
      str=fgets(fid2);

   end % end while

   stro=[stro sprintf('%s\n',['</pre>'])];
   fclose(fid2);
  
end % end if

if nargout~=0
   strout=stro;
end


