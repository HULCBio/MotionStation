function [out,hCodeTree] = makemcode(varargin)
% This undocumented function may change in a future release.

%MAKEMCODE Generates readable m-code function based on input object(s)
%
%  MAKEMCODE(H) Generates m-code for re-creating the input handle
%               and its childen. 
%
%  MAKEMCODE(H,'Output','-editor') Display code in the desktop editor
%  
%  STR = MAKEMCODE(H,'Output','-string') Output code as a string variable
%
%  MAKEMCODE(H,'Output','D:/Work/mycode.m') Output code as a file
%
%  MAKEMCODE(H,...,'ShowProgressBar',[true]/false) Displays status bar
%
%  Use PRINTDMFILE, SAVE, and/or HGSAVE for full object serialization.
%
%  Limitations
%  Using MAKEMCODE to generate code for graphs containing a large
%  number (e.g., greater than 20 plotted lines) of graphics objects 
%  may be impractical.
%
%  Example:
%
%  surf(peaks);
%  makemcode(gcf);

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.11 $  $Date: 2004/03/19 17:49:20 $

% Additional undocumented syntax (this might change):
% MAKEMCODE(H,param,val,...) 
%   'OutputTopNode'   true/[false]
%   'ReverseTraverse' true/[false]

hwait = [];
[h,options] = local_parse_input(varargin{:});
show_editor = strcmp(options.Output,'-editor');
show_status_bar = options.ShowStatusBar;
uion = show_status_bar;

h = handle(h);
ERROR_ID = 'MATLAB:codetools:makemcode';
             
if length(h)~=1 || isempty(h) || ~ishandle(h) 
    error(ERROR_ID,'Valid input object required');
end

if ~local_does_support_codegen(h)
   error(ERROR_ID,'This object does not support code generation');
end

% HG seems to connect graphics objects in a backwards way with respect
% to connectivity, so reverse traversal if this is not an HG hierarchy
if ~isa(h,'hg.GObject')
   options.ReverseTraverse = ~(options.ReverseTraverse);
end

% Flush graphics queue before inspecting objects
drawnow 

% Display wait bar for status feedback
if show_status_bar, 
    hwait = waitbar(.1,...
                    'Traversing object hierarchy, please wait...',...
                    'Name','M-Code Generation'); 
end
  
% Traverse object hierarchy and create a parellel
% hierarchy of momento objects which encapsulate visible, 
% non-default properties that will be represented in the
% final auto-generated m-code.
try
   [momento_tree] = local_generate_momento_recurse(h,options);
catch
   local_handle_error(uion,hwait);
   return;
end

% Update wait bar
if show_status_bar, 
    waitbar(.25,hwait,'Generating syntax tree, please wait...'); 
    drawnow; 
end

% Traverse momento tree and create a syntax tree of code blocks, where
% each code block represnts the creation of an object. Within a code block
% object there will generally be one constructor object and helper 
% function object placed before or after the constructor.  
try
  [hCodeTree] = local_generate_codetree_recurse(momento_tree);
catch
   local_handle_error(uion,hwait);
   return;
end

% Update wait bar
if show_status_bar, 
    waitbar(.65,hwait,'Generating variable list, please wait...'); 
    drawnow; 
end
  
% Traverse code block tree and convert various datatypes withing code block
% objects into text representation. Note that we are not creating another 
% tree here, but just converting all datatips into text. For example, a 
% matrix instance will be converted into a text representation such 
% as "[3, 4, 2]". A variable table is used here to keep track of 
% variables names and their mapping to actual datatypes.
try
   [hVarTable] = local_generate_text_representation_recurse(hCodeTree);
catch
   local_handle_error(uion,hwait);
   return;
end

% Update wait bar
if show_status_bar, 
  waitbar(.95,hwait,'Generating final text representation, please wait...'); 
  drawnow; 
end

% Traverse code block tree and build up the final text that represents
% the generated code. 
try
   mcode_str = local_generate_mcode(hCodeTree,hVarTable,options);
catch
   local_handle_error(uion,hwait);
   return;
end

% Close wait bar
if show_status_bar, close(hwait); end

% Display to command window or widget
try 
   local_display_mcode(mcode_str,options);
catch
   local_handle_error(uion,hwait);
   return;
end

if strcmp(options.Output,'-string') && nargout>0
    out = [];
    for n = 1:length(mcode_str)
        out = [out,mcode_str{n},sprintf('\n')];
    end
end

%----------------------------------------------------------%
function local_handle_error(uion,hwait)

if uion
   if ishandle(hwait)
       delete(hwait);
   end
   errordlg(lasterr,'Code Generation Error');
   return;
else
   disp(lasterr) 
end
  
%----------------------------------------------------------%
function [h,options] = local_parse_input(varargin) 
% Parse input arguments
h = [];
options.Output = '-editor';
options.OutputTopNode = false;
options.ReverseTraverse = false;
options.ShowStatusBar = true;
options.MFileName = '';

if nargin==0, 
   h = gcf;
elseif nargin==1
   arg1 = varargin{1};
   if ishandle(arg1)
       h = arg1;
   elseif isstr(arg1)
       h = gcf;
       option.Display = arg1;
   end
elseif nargin==2
   error('MATLAB:codetools:makemcode','Incorrect number of input arguments.');    
elseif nargin>2
    h = varargin{1}; 
    varargin(1) = [];
    while ~isempty(varargin)
       switch lower(varargin{1})
          case 'outputtopnode'
             options.OutputTopNode = varargin{2};
             varargin(1:2) = [];
          case 'reversetraverse'
             options.ReverseTraverse = varargin{2};
             varargin(1:2) = [];  
          case 'showstatusbar'
             options.ShowStatusBar = varargin{2};
             varargin(1:2) = [];
          case 'output'
             options.Output = varargin{2};
             varargin(1:2) = [];
             if ~isstr(options.Output)
                error('MATLAB:codetools:makemcode','Invalid filename');
             end
             if ( ~strcmp(options.Output,'-editor') && ...
                  ~strcmp(options.Output,'-string') && ...
                  ~strcmp(options.Output,'-cmdwindow') )
                     options.MFileName = local_get_mfilename(options.Output);
             end             
          otherwise
             error('MATLAB:codetools:makemcode','Invalid input');
             varargin(1) = [];
       end % switch
    end % while
end % elseif

%----------------------------------------------------------%
function [mfile_name] = local_get_mfilename(full_filename)
% Determine function name from full file name

[dir_name, mfile_name, ext_name] = fileparts(full_filename);

%----------------------------------------------------------%
function local_display_mcode(mcode_str,option)
% Display code

% Display in command window
if strcmp(option.Output,'-cmdwindow')
   str = strvcat(mcode_str);
   disp(str);

% Display in the editor   
elseif strcmp(option.Output,'-editor')
  
    % Throw to command window if java is not available
    err = javachk('mwt','The MATLAB Editor');
    if ~isempty(err)
      local_display_mcode(mcode_str,'cmdwindow');
    end
    % Convert to char array, add line endings
    % ToDo: Vectorize this loop
    str = [];
    for n = 1:length(mcode_str)
        str = [str,mcode_str{n},sprintf('\n')];
    end
    com.mathworks.mlservices.MLEditorServices.newDocument(str)
    
elseif strcmp(option.Output,'-string')

% Write to a file
else
    fid = fopen(option.Output,'w');
    if(fid<0)
       error('MATLAB:codetools:makemcode',['Could not create file: ',option.Output]);
    end
    % Convert to char array, add line endings
    % ToDo: Vectorize this loop
    str = [];
    for n = 1:length(mcode_str)
        str = [str,mcode_str{n},sprintf('\n')];
    end
    fprintf(fid,'%s',str);
    fclose(fid);
end

%----------------------------------------------------------%
function [out] = local_generate_momento_recurse(h,options,momento_parent)
% Traverse UDD hierarchy and create a parellel
% hierarchy of momento objects which encapsulate visible, 
% non-default properties

if nargin<3
    momento_parent = codegen.momento;
end

% Get this object's children
h = handle(h);

if ~local_does_support_codegen(h)
    return;
end

if isa(h,'hg.GObject')
   % ToDo: Remove double cast to double after HG seg-v's are fixed.
   kids = findall(double(h),'-depth',1);
elseif ishandle(h)
   kids = find(h,'-depth',1);
else
   error('Invalid handle')
end

% Determine traversal direction
if options.ReverseTraverse
    start = 2;
    stop = length(kids);
    increment = 1;
else
    start = length(kids);
    stop = 2;
    increment = -1;
end

% Recurse down to the children, ignoring this object
for n = start:increment:stop
     kid = kids(n);
     
     % If object wants its child to be represented in m-code, then 
     % recurse down. 
     if ~local_mcodeIgnore(h,kid)
       
        % Create momento object
        momento_kid = codegen.momento;
   
        % Add momento object to hierarchy
        connect(momento_kid,momento_parent,'up');
        
        % Recurse down to children
        local_generate_momento_recurse(kid,options,momento_kid);
     end
     
end % for

if ~local_mcodeIgnore(h,h)
   % Populate momento object with visible non-default 
   % properties corresponding to object, h
   local_populate_momento_object(h,momento_parent);
end

if nargout==1
   out = momento_parent;
end

%----------------------------------------------------------%
function [out] = local_generate_codetree_recurse(momento,code_parent)
% Recursively traverse momento hierarchy and create a parellel
% hierarchy of code objects. Each code object encapsulates 
% the constructor and helper functions.

if nargin==1
    code_parent = codegen.codeblock('MomentoRef',momento);
end

% Get children first
momento_kids = find(momento,'-depth',1);

% First kid is always self, so ignore index 1
for n = length(momento_kids):-1:2
   
   % Create code object
   code_kid = codegen.codeblock('MomentoRef',momento_kids(n));

   % Add code object to hierarchy
   connect(code_kid,code_parent,'up');
   
   % Recurse down to children
   local_generate_codetree_recurse(momento_kids(n),code_kid);
end

hObj = get(momento,'ObjectRef');
if ~isempty(hObj) && ishandle(hObj)
    local_populate_code_object(hObj,code_parent);
end

if nargout==1
   out = code_parent;
end

%----------------------------------------------------------%
function [hVarTable] = local_generate_text_representation_recurse(syntax_tree,hVarTable)
% Pre-order recursion of (root first, then children) syntax tree and convert 
% all arguments to a text representation. Output argument is list of all 
% variables defined in code. We want to use a pre-order traversal so we
% can define variables 

if nargin==1
   hVarTable = codegen.variabletable;
end

% Get children first
syntax_kids = find(syntax_tree,'-depth',1);

local_code2text(syntax_tree,hVarTable);

% First kid is always self, so ignore index 1
for n = length(syntax_kids):-1:2  
   % Recursion
   local_generate_text_representation_recurse(syntax_kids(n),hVarTable);
end


%----------------------------------------------------------%
function local_code2text(hCode,hVariableTable)
% Determines text representation

% Pre-Constructor Functions
hFuncList = get(hCode,'PreConstructorFunctions');
n_funcs = length(hFuncList);
for n = 1:n_funcs
   hFunc = hFuncList(n);
   local_function2text(hFunc,hVariableTable);
end

% Constructor
hConstructor = get(hCode,'Constructor');
local_function2text(hConstructor,hVariableTable);

% Post-Constructor Functions
hFuncList = get(hCode,'PostConstructorFunctions');
n_funcs = length(hFuncList);
for n = 1:n_funcs
   hFunc = hFuncList(n);
   local_function2text(hFunc,hVariableTable);
end

%----------------------------------------------------------%
function local_function2text(hFunc,hVariableTable)
% Determine text representation

% Only input arguments marked as parameters will be 
% represented as variables
hArginList = get(hFunc,'Argin');
for n = 1:length(hArginList)
   hArgin = hArginList(n);
   % Convert data type into text representation
   err = local_argin2text(hArgin,hVariableTable);
   
   % If an error occurred converting the argument into text
   % then ignore this property. If the argument is part of
   % parameter-value syntax, then be sure to ignore its
   % corresponding parameter name.
   if (err)
       set(hArgin,'Ignore','true');
       type = get(hArgin,'ArgumentType');
       if strcmpi(type,'PropertyValue')
           if (((n-1)>0) && ...
               strcmpi(get(hArginList(n-1),'ArgumentType'),'PropertyName'))
                 set(hArginList(n-1),'Ignore','true');
           end
       end
   end
   
   % Suppply default comment with format 
   % 'myfunction mypropertname', for example 'surface xdata'
   if ~err && get(hArgin,'IsParameter') && isempty(get(hArgin,'Comment'))
        func_name = get(hFunc,'Name');
        var_name = get(hArgin,'Name');
        if ~isempty(func_name) && ~isempty(var_name)
            set(hArgin,'Comment',[func_name, ' ', var_name]);
        end
   end
end

% All output arguments must be represented as variables
hArgoutList = get(hFunc,'Argout');
for n = 1:length(hArgoutList)
   local_table_add(hVariableTable,hArgoutList(n));

   % Flag output variables
   set(hArgoutList(n),'IsOutputArgument',true);
end

%----------------------------------------------------------%
function [err] = local_argin2text(hArg,hVariableTable)
% Determine text representation

err = false;

% If parameter, then create variable representation
if get(hArg,'IsParameter')
   local_table_add(hVariableTable,hArg);

% otherwise, generate text value representation
else
   val = get(hArg,'Value');
   [str, err]= local_type2text(val);
   if ~err
     set(hArg,'String',str);
   end
end

%----------------------------------------------------------%
function local_table_add(hVariableTable,hArg)
% Add the argument object, hArg, to the variable
% table which maps arguments to variable string names

% Get list of variables in table
hVarList = get(hVariableTable,'VariableList');
n_var = length(hVarList);
found_match = false;

% Loop through and see if argument object is equal to any
% of the previously defined variables.
for n = 1:n_var
   hCandidateArg = hVarList(n); 
   
   % If we find a match...
   if local_arg_isequal(hArg,hCandidateArg)
      
      % Assign the input variable the string of the variable in
      % the table
      str = get(hCandidateArg,'String');
      set(hArg,'String',str);
      found_match = true;
      
      % If the argument is an output argument, mark the argument in
      % the variable as an output argument too, so that we can keep
      % track of how many variables are getting created.
      if get(hArg,'IsOutputArgument')
          set(hCandidateArg,'IsOutputArgument',true);
      end
      break;
   end
end


% If this variable is not already in the table, then add it
% by creating a table entry and assigning the variable a 
% text name that will be used in the generated code.
if ~found_match

    % Add argument to variable list
    hVarList = [hArg, get(hVariableTable,'VariableList')];
    set(hVariableTable,'VariableList',hVarList);

    % Assign the variable a name not already in use.
    % Variable name has the following template: 
    % <class>n
    % Examples: figure1, data2, axes5
    val = get(hArg,'Value');
    
    % Convert to handle if numeric handle
    if ishandle(val), val = handle(val); end
    
    % Generate string name for variable
    thisname = get(hArg,'Name');
    if isempty(thisname)
       % Create string representing the variable "type"
       if isnumeric(val)
          thisname = 'data';
       else
          thisname = class(val);  
       end
    end
    
    % Remove '.' characters from variable name 
    thisname = strrep(thisname,'.','_');
              
    % Force all variables to be lowercase. This ensures generated
    % code has a consistent look and feel.
    thisname = lower(thisname);
    
    % See if this variable type is already present in the 
    % variable list
    namelist = get(hVariableTable,'VariableNameList');
    namelistcount = get(hVariableTable,'VariableNameListCount'); 
    ind = find(strcmpi(namelist,thisname)==true);
    
    % If it is not in the list, then add it
    if isempty(ind) 
        count = 1;
        newname = sprintf('%s%d',thisname,count);
        set(hVariableTable,'VariableNameList',{namelist{:},thisname});
        set(hVariableTable,'VariableNameListCount',[namelistcount,count]);
    
    % If it is in the list, increment variable count
    else
        count = namelistcount(ind(1))+1;
        namelistcount(ind(1)) = count;
        set(hVariableTable,'VariableNameListCount',namelistcount);
        newname = sprintf('%s%d',thisname,count);
    end
    set(hArg,'String',newname);
end

%----------------------------------------------------------%
function local_populate_momento_object(h,momento)
% Add property info to momento object

constr = h.classhandle.Name;
set(momento,'Name',constr);
set(momento,'ObjectRef',h);

cls = classhandle(h);
allprops = get(cls,'Properties');

% Loop through property objects
for n = 1:length(allprops)
   prop = allprops(n);
   prop_name = get(prop,'Name');
   is_visible = strcmp(get(prop,'Visible'),'on');
   is_public_set = strcmp(prop.AccessFlags.PublicSet,'on');
   is_public_get = strcmp(prop.AccessFlags.PublicGet,'on');
   
   % Ignore properties that are not visible and public settable
   if is_visible && is_public_get && is_public_set 
           
       % If object says its okay to store this property
       if ~(local_mcodeIgnoreProperty(h,prop))
           
          prop_val = get(h,prop_name);
          
          % Determine if the property should be an input argument to
          % the function
          is_parameter = local_mcodeIsParameter(h,prop);
          
          % Store property info
          pobj = codegen.momentoproperty;
          set(pobj,'Name',prop_name);
          set(pobj,'Value',prop_val);
          set(pobj,'Object',prop);
          set(pobj,'IsParameter',is_parameter);
          tmp = get(momento,'PropertyObjects');
          set(momento,'PropertyObjects',[tmp,pobj]);
       end
   end % if
end % for

%----------------------------------------------------------%
function [out] = local_generate_mcode(hCodeRoot,hVarTable,options)

% Buffer used to store final text representation of code
hText = codegen.stringbuffer;

% Generate function decleration, H1 line, and comments
local_generate_function_header(hCodeRoot,hText,hVarTable,options)

% Traverse hierarchy and add code to root's mcode property
local_generate_mcode_recurse(hCodeRoot,hText);

out = get(hText,'Text');

%----------------------------------------------------------%
function local_generate_function_header(hCodeRoot,hText,hVarTable,options)
% Generate first line of code in the following form:
% function [h] = create<ObjectName> (<property_name>_in, ...)

% Determine m-file name
if isempty(options.MFileName)
    name = get(hCodeRoot,'Name');
    if isempty(name)
       name = 'plot';
    end
    function_name = sprintf('create%s',name);
    name = strrep(name,'.','_');   % Avoid use of dots in function name
else
    name = options.MFileName;
    function_name = name;
end

% Generate output variable
output_variable = [];
if (options.OutputTopNode)
    % Loop through argument list and find first argument that is flagged
    % as an output variable
    hVarList = get(hVarTable,'VariableList');
    for n = 1:length(hVarList)
        hVar = hVarList(n);
        if get(hVar,'IsOutputArgument')  
            output_variable = get(hVar,'String');
        end
    end
end

% Add function name 
if (options.OutputTopNode) && ~isempty(output_variable)
    str = ['function [',output_variable,'] = ',function_name]; 
else 
    str = ['function ',function_name];
end
local_text_addln(hText,str);

% Get the number of input arguments
% ToDo: this needs to be optimized for performance
hVarList = get(hVarTable,'VariableList');
count = 0;
inputInd = [];
for n = 1:length(hVarList)
    hVar = hVarList(n);
    % Only consider variables marked as parameters
    if get(hVar,'IsParameter') & ~get(hVar,'IsOutputArgument')      
        count = count + 1;
        inputInd = [inputInd,n];
    end
end

% Get list of input argument objects
hInputVarList = hVarList(inputInd);

% Flags
is_first = true;

% Add function input arguments
for n = length(hVarList):-1:1
    hVar = hVarList(n);
    
    % Only show input arguments marked as parameters
    if get(hVar,'IsParameter') & ~get(hVar,'IsOutputArgument')
        str = get(hVar,'String');
        if isempty(str), error('assert'); end % should never get here
        if is_first
           local_text_add(hText,sprintf('(%s',str)); 
           is_first = false;
        else
           tmp = sprintf(', %s',str);
           local_text_add(hText,tmp); 
        end
    end
end

% Close out parenthesis for function input arguments
if count > 0
    local_text_add(hText,')');
end

% Standard H1 line
str = sprintf('%%%s',upper(function_name));
local_text_addln(hText,str);

% Add input variables to H1 line
len = length(hInputVarList);
for n = len:-1:1
    hVar = hInputVarList(n);
    if(n==len)
       local_text_add(hText,'(');      
    end 
    str = get(hVar,'String');
    local_text_add(hText,upper(str));
    if (n==1)
       local_text_add(hText,')');
    else
       local_text_add(hText,',');
    end
end

% Create comments for each input argument
for n = length(hInputVarList):-1:1
    hVar = hInputVarList(n);
    comment = get(hVar,'Comment');
    str = get(hVar,'String');
    if ~isempty(comment) && isstr(comment)
        % Force variable description to use upper/lower case format
        % MYVARIABLE myvariable description
        local_text_addln(hText,['%  ',upper(str),':  ',lower(comment)]);
    else
        local_text_addln(hText,['%  ',upper(str)]);
    end
end

% Internal comment
local_text_addln(hText,' ');
local_text_addln(hText,'%  Auto-generated by MATLAB on ');
local_text_add(hText,datestr(now));
local_text_addln(hText,' ');

%----------------------------------------------------------%
function local_generate_mcode_recurse(hCode,hText)
% Creates m-code text based on input mcode object
% The code will adhere to the following template:
%
%  pre_function1(...)
%  pre_function2(...)
%  h = constructor_name(...)
%  post_function1(...)
%  post_function2(...)

code_name = get(hCode,'Name');

% Generate code for pre constructor helper functions
hPreFuncList = get(hCode,'PreConstructorFunctions');
for n = length(hPreFuncList):-1:1
   local_function2mcode(hPreFuncList(n),hText);  
end

% Generate code for constructor
hConstructor = get(hCode,'Constructor');
constructor_name = get(hConstructor,'Name');
if ~isempty(constructor_name)
   if isempty(get(hConstructor,'Comment'))
       % Use double '%' for desktop editor code cell support
       comment = sprintf('%%%% Create %s',code_name);
       set(hConstructor,'Comment',comment);
   end
   local_function2mcode(hConstructor,hText);
end

% Generate code for post constructor helper functions
hPostFuncList = get(hCode,'PostConstructorFunctions');
for n = length(hPostFuncList):-1:1
   local_function2mcode(hPostFuncList(n),hText);  
end

% Add blank line if we generated code for this object
if ( length(hPostFuncList)>0 | ...
     length(hPreFuncList)>0 |...
     ~isempty(hConstructor))
   local_text_addln(hText,' ');
end

% Recurse down to this node's children
kids = find(hCode,'-depth',1);
n_kids = length(kids);
for n = n_kids:-1:2
   local_generate_mcode_recurse(kids(n),hText);
end

%----------------------------------------------------------%
function [hroot] = getroot(obj)
% Get root object of UDD hierarchy

hroot = obj;
while(1)
  hc = up(hroot);
  if isempty(hc)
    break;
  end
  hroot = hc;
end

%----------------------------------------------------------%
function [str, err] = local_type2text(val)
% Converts arbitrary input type to suitable input string
% If the type cannot be converted to a string, an error is thrown.

err = false;
str = '';
ERRSTR = 'error, unable to convert type to text';

if ischar(val) 
    
    [m,n] = size(val);
    
    % If string is multi-line text, then add a 'char(10)' between
    % each new line to preserve the original format.
    if(m>1)
        cell_str = {''};
        for j =1:m
           % Replace ' with '' 
           cell_str{j} = strrep(val(j,:),'''','''''');
           if (j==1)
               cell_str{j} = ['[''',cell_str{j},''',char(10),'];
           elseif (j==m)
               cell_str{j} = [str,'''',cell_str{j},''']'];
           else
               cell_str{j} = [str,'''',cell_str{j},''',char(10),'];
           end
        end 
        % Convert cell string into char array
        str = strvcat(cell_str);
        [m,n] = size(str);
        str = reshape(str',1,m*n);
        
    % Single line text    
    else
      % Replace ' with '' 
      val = strrep(val,'''','''''');
      
      % Replace new line with a 'char(10)'
      n_newline = find(val==char(10));
      if ~isempty(n_newline)
          val = strrep(val,char(10),[''',char(10),''']);
      end
   
      % Wrap text with quotes and a bracket if necessary
      str = ['''',val,''''];      
      if ~isempty(n_newline)
         str = ['[',str,']'];
      end
    end
    
% cell array of strings
elseif iscellstr(val) 
    str = '{';
    len = length(val);
    for n = 1:len
        % Replace ' with '' 
        val{n} = strrep(val{n},'''','''''');
        str = [str,'''',val{n},''''];
        if n < len
            str = [str,','];
        end
    end
    str = [str,'}'];
    
% logical
elseif isscalar(val) && islogical(val)
    if val, str = 'true'; else, str = 'false'; end
     
% number    
elseif isnumeric(val)
    % ToDo: support mutli-dim arrays
    if (size(val,1) > 1 && size(val,2) > 1) || ndims(val) > 2 || length(val)>10
       str = ERRSTR;
       err = true;
    else
       str = mat2str(val,4); % 4 units of precision
    end
    
% otherwise
else
    str = ERRSTR;
    err = true;
end

%----------------------------------------------------------%
function [bool] = local_mcodeIsParameter(hObj,hProp)
% Determine whether the property should be a parameter

% Delegate to object if it implements interface
if ismethod(hObj,'mcodeIsParameter')
    bool = mcodeIsParameter(hObj,hProp);
else
    bool = mcodeDefaultIsParameter(hObj,hProp);
end

%----------------------------------------------------------%
function [bool] = local_mcodeIgnore(h1,h2)
% Determine whether we should query object
    
% If HGObject, delegate to behavior object 
flag = true;
if ishghandle(h1)
   hb = hggetbehavior(h1,'MCodeGeneration','-peek');
   fcn = get(hb,'MCodeIgnoreHandleFcn');
   if ~isempty(fcn) 
      bool = hgfeval(fcn,h1,h2);
      flag = false;
   end
end

% Delegate to object if it implements interface
if flag
   if ismethod(h1,'mcodeIgnoreHandle') 
      bool = mcodeIgnoreHandle(h1,h2);
   else
      bool = mcodeDefaultIgnoreHandle(h1,h2);
   end
end

%----------------------------------------------------------%
function local_populate_code_object(hObj,hCode)
% Generate constructor 

% If HGObject, delegate to behavior object 
flag = true;
if ishghandle(hObj)
   hb = hggetbehavior(hObj,'MCodeGeneration','-peek');
   fcn = get(hb,'MCodeConstructorFcn');
   if ~isempty(fcn) 
      hgfeval(fcn,hObj,hCode);
      flag = false;
   end
end

% work around for method dispatching bug geck 200436
if isa(hObj,'graph2d.lineseries')
    local_workaround_for_g200436(hObj,hCode);
    flag = false;
end

% Delegate to object if it implements interface
if flag  
  if ismethod(hObj,'mcodeConstructor')
      mcodeConstructor(hObj,hCode);
  else
      % private function
      mcodeDefaultConstructor(hObj,hCode); 
  end
end


%----------------------------------------------------------%
function [retval] = local_mcodeIgnoreProperty(hObj,hProp)
% Determine whether we should serialize property to the 
% momento object

retval = false;
prop_name = get(hProp,'Name');

% Special case for GObjects
if isa(hObj,'hg.GObject') && local_mcodeIgnoreHGProperty(hObj,hProp)
    retval = true;

% Ignore properties that have default factory values
elseif isequal(get(hObj,prop_name),get(hProp,'FactoryValue'))
    retval = true;

% Delegate to object if it implements interface
elseif ismethod(hObj,'mcodeIgnoreProperty') &&  mcodeIgnoreProperty(hObj,hProp);
    retval = true;
    
% Do the default   
else
    retval = mcodeDefaultIgnoreProperty(hObj,hProp);
end

%----------------------------------------------------------%
function [bool] = local_mcodeIgnoreHGProperty(hObj,hProp)
% Ignore HG properties generic to all GObjects

bool = false;

prop_name = get(hProp,'Name');
instance_value = get(hObj,prop_name);
obj_name = get(hObj,'Type');
default_prop_name = ['Default',obj_name,prop_name]; 
    
% If the object is an hg primitive (or subclass), ignore 
% the value of the property if it is an HG root default. 
if ~isa(hObj,'hg.hggroup') && ~isa(hObj,'hg.hgtransform') 
     % Can't use FINDPROP here to test for property since some 
     % root properties are not registered with UDD. 
     % When that is fixed, the try/end can be removed. 
     orig_lasterr = lasterr;
     try,
         default_value = get(0,default_prop_name);
         bool = isequal(default_value,instance_value);
     catch
         lasterr(orig_lasterr); % avoids lasterr cruft
     end
end

% Ignore property if value is UDD default 
if ~bool
   factory_value = get(hProp,'FactoryValue');
   bool = isequal(factory_value,instance_value);    
end  
 
%----------------------------------------------------------%
function local_function2mcode(hFunc,hText)
% Generate text (m-code) from function object

% Generate comment before we call generate function
comment = get(hFunc,'Comment');
if ~isempty(comment) && isstr(comment) && length(comment) > 1
   % Prefix comment with a '%' character if not already
   if isequal(comment(1),'%')
      local_text_addln(hText,comment);    
   else
      local_text_addln(hText,['% ',comment]);          
   end
end

%---OUTPUT ARGUMENTS---%
% If function name empty, return early
func_str = get(hFunc,'Name');
if isempty(func_str)
  return;
end

% Get output arguments
hArgoutList = get(hFunc,'Argout');
n_argout = length(hArgoutList);

% No output arguments
if n_argout<1
  str = sprintf('%s',func_str);
  local_text_addln(hText,str);
  
% One output argument
elseif n_argout==1
  argout_str = get(hArgoutList,'String');
  if isempty(argout_str)
    argout_str = 'errornoargout';
  end
  str = sprintf('%s = %s',argout_str,func_str);
  local_text_addln(hText,str);

elseif n_argout==2
  argout1_str = get(hArgoutList(1),'String');
  argout2_str = get(hArgoutList(2),'String');
  str = sprintf('[%s, %s] = %s',argout1_str,argout2_str,func_str);
  local_text_addln(hText,str);
  
% More than two output arguments  
else
  error('MATLAB:CODETOOLS:MAKEMCODE',...
        'MAKEMCODE,Can not generate more than two output arguments');
end

%---INPUT ARGUMENTS---%
hArginList = get(hFunc,'Argin');

% Filter out objects that should be ignored
ind_remove = []; 
for n = 1:length(hArginList)
    if get(hArginList(n),'Ignore')
        ind_remove = [n,ind_remove];
    end
end
hArginList(ind_remove) = [];

n_argin = length(hArginList);

% No input arguments
if n_argin < 1
  local_text_add(hText,';');

% One input argument
elseif n_argin==1
  
  % If no output arguments and only one string input 
  % argument then don't wrap input arg with quotes. This 
  % is a very "MATLABley" syntax that seems to make the 
  % code generation appear more natural.
  str = get(hArginList(1),'String');
  val = get(hArginList(1),'Value');
  if n_argout==0 && isstr(val)
      local_text_add(hText,[' ',val]);
  else   
      local_text_add(hText,['(',str,');']);
  end
% Two input arguments
elseif n_argin==2
  str1 = get(hArginList(1),'String');
  str2 = get(hArginList(2),'String');
  local_text_add(hText,['(',str1,',',str2,');']);

elseif n_argin==3
  str1 = get(hArginList(1),'String');
  str2 = get(hArginList(2),'String');
  str3 = get(hArginList(3),'String');
  local_text_add(hText,['(',str1,',',str2,',',str3,');']);

elseif n_argin==4
  str1 = get(hArginList(1),'String');
  str2 = get(hArginList(2),'String');
  str3 = get(hArginList(3),'String');
  str4 = get(hArginList(4),'String');
  local_text_add(hText,['(',str1,',',str2,',',str3,',',str4,');']);
  
% Five or more input arguments
else
  
  % If there is an odd number of input arguments, then 
  % place first argument on same line as function
  % call. This insures that everyline thereafter will 
  % have two input arguments.
  iseven = mod(n_argin,2)==0;
  if iseven
     local_text_add(hText,'(...'); 
     n = 1; 
  else
     str = get(hArginList(1),'String');
     local_text_add(hText,sprintf('(%s,...',str));
     n = 2;   
  end
  
  % Loop through and add two input arguments per line
  while n < n_argin
     str = get(hArginList(n),'String');
     
     % two arguments per line
     if n+1 <= n_argin
        str2 = get(hArginList(n+1),'String');
        local_text_addln(hText,sprintf('  %s,%s',str,str2));
        if n+1 < n_argin
           local_text_add(hText,',...');
        else
           local_text_add(hText,');');
        end
        n = n + 2;
        
     % one argument on last line
     else
        str = get(hArginList(n),'String');
        local_text_addln(hText,sprintf('%s);',str));
        n = n + 1;
     end
  end % while
end

%----------------------------------------------------------%
function [bool] = local_arg_isequal(hArg1,hArg2)
% Return true if both input args have equivalent value

val1 = get(hArg1,'Value');
val2 = get(hArg2,'Value');

% Cast to handle if old style double handle type
if ishandle(val1)
    val1 = handle(val1);
end
if ishandle(val2)
    val2 = handle(val2);
end

bool = all(isequal(val1,val2));


%----------------------------------------------------------%
function local_text_add(hText,str)
% Append text to last line of text

if iscellstr(str)
  error('Cell string not supported')
end

t = get(hText,'Text');
t{end} = [t{end},str];
set(hText,'Text',t);

%----------------------------------------------------------%
function local_text_addln(hText,str)
% Append new line of text 

t = get(hText,'Text');

% Convert to cell string if not already
if ~iscellstr(str)
   str = {str};
end

if length(t)>0
    set(hText,'Text',{t{:},str{:}});
else
    set(hText,'Text',str);
end

%----------------------------------------------------------%
function [retval] = local_does_support_codegen(h)
% Object must be an HG primitives or implement the mcode generation
% interface

retval = true;
if ishandle(h)
   package_name = get(get(classhandle(h),'Package'),'Name');
   if ~strcmp(package_name,'hg') && ...
      ~ismethod(h,'mcodeConstructor') && ...
      ~ismethod(h,'mcodeIgnoreHandle')
         retval = false;
   end
end

%----------------------------------------------------------%
function local_workaround_for_g200436(hObj,hCode)
% This is a work around specific to generating code for lineseries
% objects. See geck 200436. Method dispatching doesn't work for
% objects defined in C++ via UDD API, so we define it here in m-code.
% See toolbox/matlab/graph2d/src/lineseriesmex.cpp

is3D = ~isempty(get(hObj,'ZData'));

% Generate call to 'plot3', 'plot', 'loglog', 'semilogx', or 'semilogy'
if is3D
  setConstructorName(hCode,'plot3');
else
  hAxes = ancestor(hObj,'axes');
  is_logx = strcmpi(get(hAxes,'XScale'),'log');
  is_logy = strcmpi(get(hAxes,'YScale'),'log');
  % The axes mcodeConstructor method will ignore the XScale and YScale
  % properties if it is a simple log plot.
  if (is_logx && is_logy)
      setConstructorName(hCode,'loglog');      
  elseif (is_logx)
      setConstructorName(hCode,'semilogx');   
  elseif (is_logy)
      setConstructorName(hCode,'semilogy');
  else
      setConstructorName(hCode,'plot');
  end
end

plotutils('makemcode',hObj,hCode);

% Make 'XData' default input argument
ignoreProperty(hCode,'XData');
ignoreProperty(hCode,'XDataMode');
if strcmp(hObj.XDataMode,'manual')
   arg = codegen.codeargument('Name','X',...
                              'Value',hObj.XData,...
                              'IsParameter',true,...
                              'Comment','vector of x data');
   addConstructorArgin(hCode,arg);
end

% Make 'YData' default input argument
ignoreProperty(hCode,'YData');
arg = codegen.codeargument('Name','Y',...
                           'Value',hObj.YData,...
                           'IsParameter',true,...
                           'Comment','vector of y data');
addConstructorArgin(hCode,arg);

% If 3-D plot, make 'ZData' default input argument
if is3D
   ignoreProperty(hCode,'ZData');
   arg = codegen.codeargument('Name','Z',...
                           'Value',hObj.ZData,...
                           'IsParameter',true,...
                           'Comment','vector of z data');
   addConstructorArgin(hCode,arg);
end

if strcmp(hObj.codeGenColorMode,'auto')
    ignoreProperty(hCode,'Color')
end
if strcmp(hObj.codeGenLineStyleMode,'auto')
    ignoreProperty(hCode,'LineStyle')
end
if strcmp(hObj.codeGenMarkerMode,'auto')
    ignoreProperty(hCode,'Marker')
end
      
generateDefaultPropValueSyntax(hCode);
