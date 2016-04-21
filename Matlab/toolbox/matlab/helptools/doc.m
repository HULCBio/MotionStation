function doc(topic, displayInBrowser)
%DOC Display HTML documentation in the Help browser.
%
%   DOC, by itself, displays the start page for the online doc.
%
%   DOC FUNCTION displays the HTML documentation for the MATLAB
%   function FUNCTION. If FUNCTION is overloaded, doc 
%   lists the overloaded functions in the MATLAB command
%   window.
%
%   DOC TOOLBOX/FUNCTION displays the HTML documentation for 
%   the specified toolbox function.
%
%   DOC TOOLBOX/ displays the documentation roadmap page for 
%   the specified product.
%
%   Examples:
%      doc eig
%      doc symbolic/eig
%      doc comm

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.7 $  $Date: 2004/04/06 21:53:17 $

% Get root directory of MATLAB Help
help_path = docroot;

% Show error if help docs not found 
if (isempty(help_path))
   
   % If m-file help is available for this topic, call helpwin to display that 
   % help info plus the warning about null docroot.
   if exist('topic')
      helpStr = help(topic);
      if length(helpStr) > 0
         helpwin(topic);
         return;
      end
   end
   
   % Otherwise show the appropriate error page.
   if isstudent
      html_file = fullfile(matlabroot,'toolbox','local','sr_helperr.html');
   else
      html_file = fullfile(matlabroot,'toolbox','local','helperr.html');
   end
   if exist(html_file) ~=2
      error(sprintf(['Could not locate help system home page.\n' ...
               'Please make sure the help system files are installed.']));
   end
   displayFile(html_file);
   return
end

% Case no topic specified.
if nargin == 0
   if usejava('mwt')
      % Display the begin here page in the help browser.
      html_file = fullfile(help_path, 'begin_here.html');
   else
      html_file = fullfile(help_path, 'helpdesk.html');
      if exist(html_file) ~= 2
        error(sprintf(['Could not locate help desk page.\n' ...
               'Please make sure the help system files are installed.']))
      end
   end
   displayFile(html_file);
   return
end

% Optional second argument provided to prevent the topic from displaying. 
% Check that correct argument was given.
if nargin>1 && ~strcmp(displayInBrowser,'-nodisplay')
   warning('MATLAB:doc:SecondArgInvalid', ...
      'Second argument should be ''-nodisplay'' to prevent the topic from displaying in browser');
end


% Make note of trailing slash and strip it.
if (topic(end)=='/') || (topic(end)=='\')
   specified_as_dir = 1;
   topic = topic(1:end-1);
else
   specified_as_dir = 0;
end

% Split up the topic's parts
[topic_dir topic_name] = getTopicParts(topic);
topic_file = [topic_name '.html'];

% Case topic path specified, e.g., symbolic/diag.
if (~isempty(topic_dir))
   if usejava('mwt')
      % Special cases: These refer to pages in MATLAB's reference section.
      if (strcmp(topic_dir,'serial') || strcmp(topic_dir,'com') || strcmp(topic_dir,'ftp'))
         topic_help_file = ['matlab/' strrep(topic_file, '.html', [topic_dir '.html'])];
      else
         topic_help_file = [topic '.html'];
      end
      
      result = char(com.mathworks.mlservices.MLHelpServices.showReferencePage(topic_help_file));
      if ~strcmp(result, '-1')
         % The help browser found and displayed the page, so we're done.
         return;
      end
   else
      % Get the product's toplevel help directory.
      product_dir = getProductHelpDir(topic_dir);
   
      % Special cases: These refer to pages in MATLAB's reference section.
      if (strcmp(topic_dir,'serial') || strcmp(topic_dir,'com') || strcmp(topic_dir,'ftp'))
         topic_file = strrep(topic_file, '.html', [topic_dir '.html']);
      end
   
      % Get the reference directory for this product directory
      reference_dir = getReferenceDir(product_dir);
      
      % Get the absolute path of this file
      html_file = fullfile(help_path, reference_dir, topic_file);
      
      if (exist(html_file) == 2)
         if (nargin == 1)
            displayFile(html_file);
         end
         return;
      end
   end
   
   if exist(topic)
      topic_name = topic;  % If qualified topic is recognized, use it instead of just the name.
   end
   if exist(topic_name) && nargin == 1
      helpwin(topic_name);
      return
   elseif exist(fullfile(help_path,'nofunc.html'))==2
      html_file = fullfile(help_path,'nofunc.html');
   else
       error('Invalid Documentation Topic: %s', topic);        
   end
   if nargin == 1
      displayFile(html_file);
   end
   return
end


% Case toolbox path not specified.
% Check for product page first.  Otherwise,
% search for all instances of this topic in the help hierarchy.
% Display the first instance found and list the others
% in the MATLAB command window.
topic_files = {};

if usejava('mwt')
   % Show the product page if that's what they're asking for...
   result = com.mathworks.mlservices.MLHelpServices.showProductPage(topic);
   if (result == 1)  % success
      return
   end
else
   % Check if matching product page first
   if strcmp(topic,'matlab')
      html_file = fullfile(help_path, 'techdoc', 'matlab_product_page.html');
   elseif strcmp(topic,'mech')
      html_file = fullfile(help_path, 'toolbox', 'physmod', topic, [topic '_product_page.html']);
   else
      html_file = fullfile(help_path, 'toolbox', topic, [topic '_product_page.html']);
   end
   if exist(html_file) == 2
      % Show it.  However, in the case where name is both directory and function, 
      % check for trailing slash; if absent, fall through and treat as function.
      if ((exist(topic)~=2) && (exist(topic)~=5)) || (specified_as_dir == 1)
         if (nargin == 1)
            displayFile(html_file);
         end
         return
      end
   end
end

if usejava('mwt')
   overloaded = char(com.mathworks.mlservices.MLHelpServices.showReferencePage(topic_file));
   if ~strcmp(overloaded,'-1')
      if ~isempty(overloaded)
          header = sprintf(' Overloaded functions or methods (ones with the same name in other directories)\n');
          overloaded = [header overloaded];
          if usejava('desktop')
            overloaded = makehelphyper('doc', topic_dir, topic, overloaded);
          end
          disp(overloaded);
      end
      return;
   end
else
   % Check MATLAB html file directory.
   html_file = fullfile(help_path, 'techdoc', 'ref', topic_file);
   if (exist(html_file) == 2)
      topic_files = [topic_files {html_file}];
   end
   % Also check for overloaded variants
   suffix = {'com' 'ftp' 'serial'};
   for i = 1:length(suffix)
      html_file = fullfile(help_path, 'techdoc', 'ref', topic_file);
      html_file = strrep(html_file, '.html', [char(suffix(i)) '.html']);
      if (exist(html_file) == 2)
         topic_files = [topic_files {html_file}];
      end
   end
   
   
   % Check toolbox help directories
   toolbox_path = fullfile(help_path, 'toolbox');
   if (exist(toolbox_path) == 7)
      toolbox_dirs = dir(toolbox_path);
      for i = 1:length(toolbox_dirs)
         toolbox = toolbox_dirs(i);
         if ~isempty(toolbox.name) && toolbox.name(1)~='.' && toolbox.isdir
            toolbox.name = getReferenceDir(toolbox.name);
            html_file = fullfile(toolbox_path, toolbox.name, topic_file);
            if (exist(html_file) == 2)
               topic_files = [topic_files {html_file}];
            end      
         end
      end
   end
end

% No help for this topic anywhere.
if (isempty(topic_files))
   if (exist(topic_name))
      helpwin(topic_name);
      return;
   elseif exist(fullfile(help_path,'nofunc.html'))==2
      html_file = fullfile(help_path,'nofunc.html');
   else
       error('Invalid Documentation Topic: %s', topic);            
   end
   if nargin == 1
      displayFile(html_file);    
   end
   return
end

% Display first topic file found.
if (nargin == 1)
   displayFile(topic_files{1});
end

% If additional topic files found, list them in the MATLAB command window.
s = size(topic_files,2);
if (s > 0)
   if (s>1)
      disp(' ');
      disp(' Overloaded functions or methods (ones with the same name in other directories)');
   end
   for i = 1:s
      [path, name, unused, unused] = fileparts(topic_files{i});
      origPath = path;
      path = getProductDir(path);
      if path(end)==filesep
         path(end)=[];
      end
      k = find(path==filesep);
      if ~isempty(k)
         tbxname = path(k(end)+1:end);
      else
         tbxname = path;
      end
      if i>1
         if (strcmp(name, [topic_name 'serial']))
            disp(['   doc serial' '/' topic_name]);
         elseif (strcmp(name, [topic_name 'com']))
            disp(['   doc com' '/' topic_name]);
         elseif (strcmp(name, [topic_name 'ftp']))
            disp(['   doc ftp' '/' topic_name]);
         else
            disp(['   doc ' tbxname '/' name]);
         end
      end
      
      helpfilename = [origPath filesep name];
   end
   if s>1
      disp(' ');
   end
end


%------------------------------------------
% Helper function that splits up the topic into a topic directory, and a
% topic name.
function [topic_dir, topic_name] = getTopicParts(topic)

k = [find(topic == '/') find(topic == '\')];
if isempty(k), k = 0; end
if length(k)>1, 
    error('Invalid Documentation Topic: %s', topic);        
end
topic_dir = topic(1:k-1);
topic_name = topic(k+1:end);
topic_name = lower(topic_name);
topic_name = strrep(topic_name, ' ', '');
topic_name = strrep(topic_name, '-', '');
topic_name = strrep(topic_name, '(', '');
topic_name = strrep(topic_name, ')', '');
if (length(topic_name)>2) && strcmp(topic_name(end-1:end),'.m')
   topic_name = topic_name(1:end-2);
end


%------------------------------------------
% Helper function that figures out where the reference directory
% is for a given product directory.  By default the reference
% directory is the same as the product directory, but some products
% have a separate reference directory (in most cases a subdirectory
% underneath the product directory).
function reference_dir = getReferenceDir(product_dir)

if (strcmp(product_dir,'simulink'))
   reference_dir = fullfile('toolbox', product_dir, 'slref');
elseif (strcmp(product_dir,'control'))
   reference_dir = fullfile('toolbox', product_dir, 'ref');
elseif (strcmp(product_dir,'commblks'))
   reference_dir = fullfile('toolbox', product_dir, 'ref');
elseif (strcmp(product_dir,'mech'))
   reference_dir = fullfile('toolbox', 'physmod', product_dir);
elseif (strcmp(product_dir,'techdoc'))
   reference_dir = fullfile('techdoc', 'ref');
else
   reference_dir = fullfile('toolbox', product_dir);
end

%------------------------------------------
% Helper function that gets the product's toplevel help directory.  In most
% cases, this is the same as the directory passed in, but there are some
% exceptions.
function product_help_dir = getProductHelpDir(product_dir)

if (strcmp(product_dir,'mech'))
   product_help_dir = fullfile('physmod', 'mech');
elseif (strcmp(product_dir,'serial'))
   product_help_dir = 'techdoc';
elseif (strcmp(product_dir,'com'))
   product_help_dir = 'techdoc';
elseif (strcmp(product_dir,'ftp'))
   product_help_dir = 'techdoc';
else
   product_help_dir = product_dir;
end


%------------------------------------------
% Helper function that figures out where the product directory
% is for a given reference directory.
function product_dir = getProductDir(reference_dir)

if (strcmp(reference_dir,['simulink' filesep 'slref']))
   product_dir = 'simulink';
elseif (strcmp(reference_dir,['control' filesep 'ref']))
   product_dir = 'control';
elseif (strcmp(reference_dir,['commblks' filesep 'ref']))
   product_dir = 'commblks';
else
   product_dir = reference_dir;
end

%------------------------------------------
% Helper function that displays the html_file in the appropriate browser.
function displayFile(html_file)

if (usejava('mwt') == 1)
   % Display the file inside the help browser.
   web(html_file, '-helpbrowser');
else
   % Load the correct HTML file into the user's system browser.
   web(html_file, '-browser');
end
