function retst = p_parser(typeobj,cdecl)
% P_PARSER (Private) C Declaration Parser for 'Link for Code Composer®'
%   I = P_PARSER(DEC) - Accepts ANSI-style C declarations and
%   converts it into a structure of information that describes the
%   declaration.  The resulting structure will be multi-layered to describe
%   declarations such as function arguments or pointer definitions.
%
%  Function Declaration
%    retst.name      - Name of the function
%    retst.uclass    - 'function'
%    retst.argument  - Cell array of input parameters (Variable decls.)
%    retst.returnvar - Return type declaration (Variable decl.)
%
%  Variable Declarations
%    retst.name - Name of 
%
% Notes 
%  - Handles both Function Declarations and Variable
%  - Arrays/Scalar - The parse differentiates between the following C 
%       C Declaration    ->  Matlab Parsed Size
%       'int x[10][];'   ->  retst.size = [10 0]  - 2-D array with 1 unknown
%       'int x;'         ->  retst.size = []      - Scalar
%       'int x[4][2][1]; ->  retst.size = [4 2 1] - 3-D array
%  - Unnamed input parameters are have a null name 
%  - Ignores standard C/C++ comments, both // and /* XX */
%  - 
%  - Does NOT support C&K style Function Definitions such as 
%      int foo(x)
%      int x;
%      { ...
%  - C compilers convert passed arrays to pass-by-reference.  However, this
%  parser does NOT make this adjustment.  Arguments to functions are described 
%   as indicated in the declaration.
%
%  See also PARSE, ADD.

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/01 16:03:52 $

error(nargchk(2,2,nargin));

% First remove comments, then YACC parser
try
    iswrapped = 0;
    cdecl = ccommentripper(cdecl);
    checkforellipsis(cdecl);
    cdecl = checkforCCSkeywords(cdecl);
    raw = ccscdeclparsermex(cdecl);
catch
    if strcmp(lasterr,'failed to recover from syntax error')
        % variable name might not be specified, wrap a function around cdecl
        cdecl_wrapped = ['void foo(' cdecl ')']; iswrapped = 1;
        raw = ccscdeclparsermex(cdecl_wrapped);
    else
        rethrow(lasterror);
    end
end
tokens = tokenall(raw);  % Convert raw column-separated string into 2d cell-array

% Start at LAST occurance of 'OUTPUT' in tokens
tokensize = size(tokens);
linesn = tokensize(1);  % Total number of rows in token array

lineslastoutput = max( find( strcmp(tokens,'OUTPUT') ) );
iline = lineslastoutput+1;
if iline > linesn,
    error('Unexpected failure in parsing, incomplete token list from parser');
end
% Ok let's strip off any preamble (seems to be unnecessary)
tokens = tokens(iline:end,:);
iline = 1;
% The next line after last 'OUTPUT' should always be a DECLARE.
%  At this point it could be either a function declaration or
%  a variable/data declaration
%
if ~strcmp( tokens{iline,2},'DECLARE'),
    error('Unexpected failure in parsing, no declaration in tree');
end
% OK, at this point we need to check for 
%  'DECLARE'        [] , which indicates a we have an C&K style 
%   c-declaration (assume 'int')
%
retst = struct('name','','type','','qualifier',[],'size',[],'uclass','');
retst.qualifier = {};
% Check for special case: NO return type == Int (C&K) 
% We do this here, because it's the only place we make this assumption
if isempty( tokens{iline,3} ),   % assume int as return type 
    iline = index2linenumber(tokens,tokens{iline,4});  % After Declare...      
    retst.type = 'int'; 
    retst.uclass = 'numeric';
else % OK we have an explicit return type
    linetype = index2linenumber(tokens,tokens{iline,3});  % After Declare...
    if isempty( tokens{iline,4}),
        retst = dosequence(tokens,linetype,retst);
        return;
        % error('There was a reason for this, but damned if I can remember');
    else
        iline = index2linenumber(tokens,tokens{iline,4});
    end
    % This routine will handle any qualifiers, struct
    retst = dosequence(tokens,linetype,retst);
end
while ~isempty(strmatch(tokens{iline,2},{'[','*'})),
    if strcmp(tokens{iline,2},'['),  % Is it an array?
        [iline,retst.size] = doarray(tokens,iline);
    elseif strcmp(tokens{iline,2},'*'),  % Pointer
        [iline,retst] = dopointer(tokens,iline,retst);
    end
end
% At this point we separate the data declaration from the function
% declarations.  

if strcmp(tokens{iline,2},'IDENTIFIER'),  % Data declaration! 
    retst.name = tokens{iline,6};   % we are done (We don't support multiple data declarations)
    return;
end
  
if ~strcmp(tokens{iline,2},'('),  % ? function declaration or possibly a function pointer
    error(['Unexpected token: "' tokens{iline,2} '" after data declaration']);
end
% Ok we have either a function decl or a function pointer, lets look beyond
% the '(' token and see what we have
lineid = index2linenumber(tokens,tokens{iline,3});
if strcmp(tokens{lineid,2},'IDENTIFIER'),  % Now we know, it's a function declaration! 
    retst = struct('name','','uclass','function','argument',[],'returnvar',retst);
    retst.name = tokens{lineid,6};
    % OK now parse the input parameters
     retst.argument = dofuncparams(tokens,iline);
     %
 elseif tokens{lineid,2} == '*' % OK, we're looking at function pointer OR a function that returns a function pointer
    retst = struct('name','','uclass','function','argument',[],'returnvar',retst);
    % Ok First, handle parameter list
    retst.argument = dofuncparams(tokens,iline);
    % OK , now we need to deal with the pointer
    
    [iline,retst] = dopointer(tokens,lineid,retst);
    % So retst has the return type of the function pointer
    % Next we need to decode the input parameters to the function pointer
    if strcmp(tokens{iline,2},'IDENTIFIER'),  % Name of the function pointer!
        retst.name = tokens{iline,6};   % we are done!
        return;
    elseif tokens{iline,2} == '(';
        % Wait It's NOT  function pointer, but a function that returns a
        % function pointer.  Here we go again!
        % Should really be recursive, but that is of limited value....  
        retst = struct('name','','uclass','function','argument',[],'returnvar',retst);
        retst.argument = dofuncparams(tokens,iline);   
        if strcmp(tokens{iline,2},'IDENTIFIER'),  % Name of the function pointer!
          retst.name = tokens{iline,6};   % we are done!
          return;        
      end
    end
else 
    error('Looks like a poorly formed function pointer');
end

% Remove irrelevant information if wrapped
if iswrapped
    retst = retst.argument{1};
end


%------------------------------------------------------------------------==
function y = ccommentripper(x)
% Y = CCOMMENTRIPPER(X) Removes all comments from C expression
%  The C expression in X is stripped of all standard C comments
%  and returned.  This method handles both ANSI C comments, for 
%  example: /* ANSI Comment */  It also removes new C++ Style 
%  comments that begin with //
%  
while(1),
    startcom = min(strfind(x,'/*'));
    dualcom = min(strfind(x,'//'));
    if isempty(startcom) && isempty(dualcom),
       break;  % No more, lets go
    end
    if ~isempty(startcom) && (isempty(dualcom) || (startcom < dualcom)),  % We have a /* */
        % Remove '/* type comment
         stopcom = strfind(x(startcom:end),'*/') + startcom;  % Get all possible closing braces
         if isempty(stopcom),
             error('Incomplete comment: a "/*" does not have a matching "*/"');
         end
         x = [x(1:startcom-1) x(stopcom+1:end)];
     else % We have a real //
         stopcom = strfind(x(dualcom:end),char(10)) + dualcom;  % Get all possible closing braces
         if isempty(stopcom),
            % We will toss out the rest
            x = x(1:dualcom-1);
            break;
         else
            x = [x(1:dualcom-1) x(stopcom-1:end)];
        end
    end
end
y = x;

%------------------------------------------------------------------------==
function tokens = tokenall(s)
% TOKENS = TOKENALL(S) Converts raw string into 2-D array of tokens
%   The raw output from YACC-based parser is a single large string.  This string
%   is converted into a 2-D cell array of tokens.  Furthermore, the routine converts
%   any index values in Columns 1,3 and 4 to numeric values.  A similar
%   conversion is applied to Column 5.  
linebrks = findstr(s,char(10));
linesn = length(linebrks);
tokens = cell(linesn,6);

firstchar = 1;
for ilines=1:linesn,
    sline = s(firstchar:linebrks(ilines));
    % disp(sline);
    firstchar =linebrks(ilines)+1;
    for itoken = 1:6,
        inx =find( (sline~=0) & ~isspace(sline) );  % Jump over blanks
        if isempty(inx)
            break;
        end
        sline = sline(inx:end);
        if sline(1) == '<',
            tokens{ilines,itoken} = sline(1:5);
            if sline(6) == ':',
                sline = sline(7:end);
            else
                sline = sline(6:end);
            end
        else
            inx =find( (sline==0) | isspace(sline) );  % find end of token (space or end)
            if isempty(inx)
                tokens{ilines,itoken} = sline(1:end);
                break;
            end
            tokens{ilines,itoken} = sline(1:inx-1);
            sline = sline(inx:end);
        end
    end
end
% Post processing to do numeric conversion on columns 1,3,4 and 5
tokensize = size(tokens);
linesn = tokensize(1);
for ilines=1:linesn,
    % Check column 1 for numeric values
    for col = [1 3 4],
        if ~isempty(tokens{ilines,col}) && (tokens{ilines,col}(1) == '<'),
            tokens{ilines,col} = str2num(tokens{ilines,col}(2:4));
        end
        if strcmp(tokens{ilines,col},'NULL'),
            tokens{ilines,col} = [];  % converts 'NULL' to []
        end
    end
    col = 5;
    if ~isempty(tokens{ilines,col}),
        tokens{ilines,col} = str2num(tokens{ilines,col});
    end
end

%------------------------------------------------------------------------==
function line = index2linenumber(tokens,index)
% INDEX2LINENUMBER takes an index and find the approriate line number.
%   LINE = INDEX2LINENUMBER(INDX) - The index value from columns 3 or 4 of
%   the token array should passed in (INDX).  The resulting LINE value
%   indicates the LINE number referenced by the INDX value.  This method is
%   used to traverse the token tree.
line = [];  % Null return if we can't find index this index in the tokens
for iline = 1:length(tokens(:,1)),
    testv = tokens{iline,1};
    if isnumeric(testv) && testv == index,
        line = iline;
        break;
    end
end
%------------------------------------------------------------------------==
function [iline,decst] = dopointer(tokens,iline,decst)
% DOPOINTER Extract the sequence of pointers references
%  [ILINE,DST] = DOPOINTER(TOKENS,ILINE,DST) - Accepts the TOKENS cell
%   and a line number (ILINE) that indicates the start of a pointer
%   sequence.  This handles multiple pointer sequences such as 'int ***x'. 
%  The ILINE input should point at the first line in TOKENS that contains
%  '*'.  This routine will modify DST to indicate the pointer sequence. 
%
if tokens{iline,2} ~= '*',
    error('Parse:Pointer','Called pointer parse, but pointer token was not found');
end
while (tokens{iline,2} == '*'),
    if isfield(decst,'type'),  % Data/Variable is referent 
        pdecst = struct('name','',...
                   'type',[decst.type ' *'],...
                   'qualifier',[],...
                   'size',[],...
                   'uclass','pointer',...
                   'referent',decst,...
                   'reftype',decst.type);
    else  % Referent is a function
        pdecst = struct('name','',...
                   'type','function *',...
                   'qualifier',[],...
                   'size',[],...
                   'uclass','pointer',...
                   'referent',decst,...
                   'reftype','function');
    end
    pdecst.qualifier = {}; %This twist seems to be necessary
    decst = pdecst;  % Make decst this the top again
    if isempty(tokens{iline,4}),
        iline = -1;
        break; % end of the road, 
    else
        iline = index2linenumber(tokens,tokens{iline,4});  % go to next (possible) pointer location    
    end
end
%------------------------------------------------------------------------==
function params = dofuncparams(tokens,iline)
% DOFUNCPARAM  Extracts arguments of functions
%   PARAM = DOFUNCPARAM(TOKENS,ILINE ) - Converts function input parameters 
%   into a cell array of structures that describe each passed type.  The order 
%   in the cell array matches the pass order.
%
if tokens{iline,2} ~= '(',
    error('Parse:Function','Function return ');
end

if isempty( tokens{iline,4} ) % Easy one, ( ) => 'void' input paramer
    params = { struct('name','','type','void','qualifier',[],'size',[],'uclass','void') };
    params{1}.qualifier = {};
    return
end
iline = index2linenumber(tokens,tokens{iline,4});  
% Ok, next we expect DECLARE or ','
params = {};
flagDONE = false;
while ~flagDONE,
    param = struct('name','','type','','qualifier',[],'size',[],'uclass','');
    param.qualifier = {};
    % We traverse the parameter list using ',' 
    % If we don't have a ',' then there is only a single parameter
    if strcmp(tokens{iline,2},','),
        % We need to keep added parameters until the token{..,4} does not
        % point at another ','
        linenext = index2linenumber(tokens,tokens{iline,3});  % Next ',', or is it?   
        iline = index2linenumber(tokens,tokens{iline,4});  % Next parmeter, or is it?
    else
        flagDONE =  true;  % Single input parameter, on looping required. 
    end
    
    if ~strcmp(tokens{iline,2},'DECLARE'),  
        error(['Unexpected token '  tokens{iline,2} ' in function parameter list']);
    end
    % weed out some pass through 'DECLARE's, why? I don't know
    while isempty( tokens{iline,4}) && strcmp(tokens{iline,2},'DECLARE'),
        iline =  index2linenumber(tokens,tokens{iline,3});
    end
    
    if strcmp(tokens{iline,2},'DECLARE'),  % If it's a declare, it's a full one
        linetype = index2linenumber(tokens,tokens{iline,3});  % After Declare...
        iline = index2linenumber(tokens,tokens{iline,4});
    else % We fell off the end with no extra index, so next (iline) is null
        linetype = iline;
        iline =[];
    end
    
    % This routine will handle any qualifiers, struct, types
    param = dosequence(tokens,linetype,param);
    % Ok, we have the base type, now handle any * or [, etc
    if ~isempty(iline),
        while ~isempty(strmatch(tokens{iline,2},{'[','*'})),
            if strcmp(tokens{iline,2},'['),  % Is it an array?
                [iline,param.size] = doarray(tokens,iline);
            elseif strcmp(tokens{iline,2},'*'),  % Pointer
                [iline,param] = dopointer(tokens,iline,param);
            end
            if iline<0,  % Necessary for identifier-free declarations 
                break;
            end
        end
        if (iline>0),
            if strcmp(tokens{iline,2},'IDENTIFIER'),  % Data declaration! 
                param.name = tokens{iline,6};   % we are done (We don't support multiple data declarations)
            elseif tokens{iline,2} == '(' % OK, we're looking at function pointer as an argument,
                lineft = iline;
                % at this point, since we are doing function arguments and
                % NOT declaration, a function MUST be a pointer.  (A
                % function can NOT have a function as an argument, but it
                % can have a function pointer as an argument).
                iline = index2linenumber(tokens,tokens{iline,3});
                if  tokens{iline,2} ~= '*',
                    error(' Function arguments can NOT be functions (a function pointer is OK!)');
                end
                % that we are dealing with a pointer to a variable, i.e.
                % the function operation has a high precedecnce
				param = struct('name','','uclass','function','argument',[],'returnvar',param);
				% Ok First, Next we need to decode the input parameters to the function pointer
                % Note we are now recursive
				param.argument = dofuncparams(tokens,lineft);                
                [iline,param] = dopointer(tokens,iline,param);
                % OK , now we need to deal with the pointer
              %  [iline,retst] = dopointer(tokens,lineid,retst);                
				if strcmp(tokens{iline,2},'IDENTIFIER'),  % Name of the function pointer!
				    param.name = tokens{iline,6};   % we are done!
                end
			end            
        end      
	end
    params = { param params{1:end} };
   %     disp('one Down');
   if flagDONE,  % Only one, so we are done
       break;
   else
      iline = linenext;
  end
end
%------------------------------------------------------------------------==
function decst = dosequence(tokens,iline,decst)
% DOSEQUENCE Extract the sequence of labels that define a type name
%   DST = DOSEQUENCE(TOKENS,ILINE,DST) - Accepts the TOKENS cell array
%   and a line number (ILINE) that indicates the start of a type
%   sequence.  For example 'const unsigned int'.  The ILINE input should point 
%   at the line number in TOKENS that defines the start of a type sequence.  
%   This occurs immediately after a 'DECLARE', but this fact is not verified.  The
%   information about type, uclass and qualifiers is applied to the DST
%   structure and returned.  
%
%   DST.type = 'int', 'unsigned long', 'double', 'xxx' (if istypdef == 1), 'struct mytag', etc
%   DST.qualifier = { 'const', 'extern' } % or whatever 
%   DST.uclass =  'numeric', 'structure', 'typedef' or 'enum'   % 'pointer' is handled somewhere else
%
validButnotuseful = {'typedef'};
validIntTypes = { 'char','short', 'int' };   % These could include an optional unsigned, short or long 
validIntQual = { 'long','signed','unsigned'};
validFloatTypes = { 'double','float'};  % Simply types
validVoidTypes = 'void';  
validCompTypes = {'union','struct'}; % These must be followed by a TAG
validEnumTypes = {'enum'};  % These must be followed by a TAG
validQualifiers = { 'extern', 'static', 'auto', 'interrupt', 'volatile','const','register'};
typedefDeclare = 'TYPENAME';

decst.qualifier = {};
if ~strcmp(tokens{iline,2},'SEQUENCE'), % OK, its not a sequence, so let's check the  possibilities
    if strmatch( tokens{iline,2}, validQualifiers, 'exact'),  % Look for valid qualifiers
        error(['Qualifier "' tokens{iline,2} '"requires an explicit type']);
    elseif ~isempty(strmatch( tokens{iline,2}, validIntTypes, 'exact'))  || ...
        ~isempty(strmatch( tokens{iline,2}, validFloatTypes, 'exact')) || ...
        ~isempty(strmatch( tokens{iline,2}, validIntQual, 'exact')),
        decst.type = tokens{iline,2};
        decst.uclass =  'numeric';
    elseif strcmp(tokens{iline,2},validVoidTypes), 
        decst.type = 'void';        
        decst.uclass =  'void';        
    elseif strcmp(tokens{iline,2},typedefDeclare),
        decst.type = tokens{iline,6};
        decst.uclass =  'typedef';
    elseif ~isempty(strmatch( tokens{iline,2}, validCompTypes , 'exact')), 
        decst.type = [tokens{iline,2} ' ' tokens{index2linenumber(tokens,tokens{iline,3}),6}];
        decst.uclass = 'structure';
    elseif ~isempty(strmatch( tokens{iline,2}, validEnumTypes , 'exact')),
       decst.type = [tokens{iline,2} ' ' tokens{index2linenumber(tokens,tokens{iline,3}),6}];
       decst.uclass = 'numeric';      % Enums are just integers                
    end
    return;
end
% We have a sequence, now things get more complicated
% First, just unwrap the sequence and make simply assignments
flagNEEDTAG = false;  % Indicates the need for a tag to match a struct/union/enum
flagDONE =  false; % Indicates when we are on the last loop
linenext = index2linenumber(tokens,tokens{iline,3} );  % could be another sequence
iline = index2linenumber(tokens,tokens{iline,4} ); % This is the stuff we need to look at
while 1,
    if strmatch( tokens{iline,2}, validQualifiers, 'exact'),  % Look for valid qualifiers
         if isempty(decst.qualifier),
            decst.qualifier =  tokens(iline,2);
         else
            decst.qualifier =  {decst.qualifier{1:end}, tokens{iline,2}};
         end
    elseif ~isempty(strmatch( tokens{iline,2}, validIntTypes, 'exact'))  || ...
        ~isempty(strmatch( tokens{iline,2}, validFloatTypes, 'exact')),
        if isempty(decst.type),
            decst.type = tokens{iline,2};
        else
            decst.type = [decst.type ' ' tokens{iline,2}];
        end
        decst.uclass =  'numeric';
    elseif strcmp(tokens{iline,2},validVoidTypes),
    % We allow 'static void' becuase we need to allow 'interrupt void', but
    % maybe we should check a bit more (TBD)
        decst.type = 'void';        
        decst.uclass =  'void';  
    elseif ~isempty(strmatch( tokens{iline,2}, validIntQual, 'exact')),
        if isempty(decst.type),
            decst.type = tokens{iline,2};
        else
            decst.type = [tokens{iline,2} ' ' decst.type];  % These go first
        end
        decst.uclass =  'numeric';        
    elseif strcmp(tokens{iline,2},typedefDeclare),
        decst.type = tokens{iline,6};
        decst.uclass =  'typedef';
    elseif ~isempty(strmatch( tokens{iline,2}, validCompTypes , 'exact')), 
        decst.type = tokens{iline,2};
        decst.uclass = 'structure';
        flagNEEDTAG = true;
    elseif ~isempty(strmatch( tokens{iline,2}, validEnumTypes , 'exact')),
       decst.type = tokens{iline,2};
       decst.uclass = 'numeric';      % Enums are just integers 
       flagNEEDTAG = true;       
    elseif flagNEEDTAG,   % We simply are looking for a tag in the next slot
        decst.type = [decst.type ' ' tokens{iline,2}];
        flagNEEDTAG = false;  % Ok we got the tag! (Checking is not needed (already done in parser))
    end
    if flagDONE,
        break;
    elseif strcmp( tokens{linenext,2}, 'SEQUENCE'),  % WE are still doing sequences!
        iline = index2linenumber(tokens,tokens{linenext,4} ); % This is the stuff we need to look at  
        linenext = index2linenumber(tokens,tokens{linenext,3} );  % could be another sequence
    else % Sequence is done, but we have one last valid type string to handle
        iline = linenext; % This is the stuff we need to look at  
        flagDONE = true;
    end
end
%------------------------------------------------------------------------
function [iline,asize] = doarray(tokens,iline )
% DOARRAY
%
if tokens{iline,2} ~= '[',
    error('Parse:Array','Called array create, but array token was not found');
end
asize = [];
while (tokens{iline,2} == '['),
    if isempty( tokens{iline,4} ),
        asize = [0 asize];
    else
        % Go to constant entry and append
        constline = index2linenumber(tokens,tokens{iline,4});
        asize = [tokens{constline,5} asize];
    end
    index = tokens{iline,3};
    if isempty(index),  % For this case: foo(int []) - The end!
        iline = -1;
        break;
    end
    iline = index2linenumber(tokens,tokens{iline,3});
end
%------------------------------------------------------------------------
function checkforellipsis(cdecl)
if ~isempty(strfind(cdecl,'...'))
    errid = ['MATLAB:TYPE_' mfilename '_m:EllipsisNotAllowedInDecl'];
    error(errid,sprintf('Functions with variable number of inputs, denoted by an ellipsis in the function declaration, are not supported.'));
end
%------------------------------------------------------------------------
% Look for CCS keywords:
%  cregister - not supported
%  near, far, interrupt - remove from declaration
%  volatile - ignored
function cdecl = checkforCCSkeywords(cdecl)
CCS_keywords = {'interrupt',9,'near',4,'far',3,'restrict',8,'cregister',9}; % keywords & their lengths
for i=1:2:length(CCS_keywords),
    idx = strfind(cdecl,CCS_keywords{i});
    for j=idx,
        % Check if string is a CCS keyword or part of another word
        if j==1, % if found at the beginning, pass only 1 character to isAlphaNum
            charc = cdecl(1+CCS_keywords{i+1});
        elseif (j+CCS_keywords{i+1})>length(cdecl) % if found at the end, only 1 character to isAlphaNum
            charc = cdecl(j-1);
        else % if found within declaration, pass 2 characters to isAlphaNum
            charc = [cdecl(j-1); cdecl(j+CCS_keywords{i+1})];
        end
        if ~isAlphaNum(charc),
            if i==9  % 'cregister'
                errid = ['MATLAB:FUNCTION_' mfilename '_m:cregisterKeywordNotSupported'];
                error(errid,'Declarations with CCS keyword ''cregister'' are not supported.');
            else
                cdecl(j:j+CCS_keywords{i+1}-1) = ''; % if valid keyword, remove from declaration
            end
        end
    end
end

%------------------------------------------------------------------------
% Check if charc is alphanumeric.
function resp = isAlphaNum(charc)
asciival = double(charc);
if sum((asciival>=48 & asciival<=57))  ||... % numeric
   sum((asciival>=97 & asciival<=122)) ||... % upper caps
   sum((asciival>=65 & asciival<=90))  ||... % lower caps
   sum(asciival==95),                        % underscore (_)   
   resp = 1;
else
    resp = 0;
end

% [EOF] p_parser.m