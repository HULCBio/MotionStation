function rtw_expand_template1(inFileName, outFileName)
% RTW_EXPAND_TEMPLATE Expands a code generation template file to a executable
% TLC file (Real-Time Workshop Embedded Coder feature).
%
% Arguments:
%   inFileName:  Name of a code generation template file to be expanded (.cgt)
%   outFileName: Name of the resulting TLC file (.tlc)
%
% For more details, see the Real-Time Workshop Embedded Coder
% User's guide for code generation template files.

%   Copyright 1994-2004 The MathWorks, Inc.
%
%   $Revision: 1.1.6.7 $
%   $Date: 2004/05/03 01:39:09 $

% Only expand .cgt files
[pathstr,file,ext] = fileparts(inFileName);
if ~isequal(ext,'.cgt')
  error(['The file ', inFileName, ' is not a code generation template ', ...
         '(i.e., a .cgt file)'])
end

% Canned tokens used for the banner
bannerTokens = {...
    {'FileName'}, {'FileType'}, {'FileTag'}, {'ModelName'},...
    {'ModelVersion'}, {'RTWFileVersion'}, {'RTWFileGeneratedOn'},...
    {'TLCVersion'}, {'SourceGeneratedOn'}};

% Required tokens
requiredTokens = {...
    {'Includes'}, {'Defines'}, {'Types'}, {'Enums'},...
    {'Definitions'}, {'Declarations'}, {'Functions'}};

inId  = -1;
outId = -1;

try,

  % Open input file
  inId = fopen(inFileName,'r');
  if inId < 0
    error(['Unable to open input template file: ', inFileName]);
  end
  
  % Load the file into a temporary buffer
  buffer = cell(2,2);
  lineCount = 0;
  rowCount = 0;
  while true
    str = fgetl(inId);
    if ~ischar(str), break, end % EOF
    lineCount = lineCount + 1;
    
    oldStyleIncStr = regexp(str,'^\s*%include\s+"rtwec_code.tlc"');
    if ~isempty(oldStyleIncStr)
      % Exapand old style %include to tokens
      for i = 1 : length(requiredTokens)
        rowCount = rowCount + 1;
        buffer{rowCount}{1} = lineCount;
        buffer{rowCount}{2} = ['%<',requiredTokens{i}{1},'>'];
      end
    else
      rowCount = rowCount + 1;
      buffer{rowCount}{1} = lineCount;
      buffer{rowCount}{2} = str;
    end
  end

  % The pattern to find a token or an escaped token
  tokenPattern = '%<(\S\w*)>';

  % Variable to detect out of order or missing required tokens
  prevReqToken = '';

  % Need to store custom tokens in a list
  custTokenBuf = cell(1);
  custTokenIdx = 0;
  
  for rowCount = 1 : length(buffer)
    lineNo = buffer{rowCount}{1};
    istr = buffer{rowCount}{2};
    ostr = istr;
    
    % Skip TLC comments or lines without any tokens to expand
    if ~isempty(regexp(istr,'^\s*%%')) | isempty(regexp(istr,'%<.*>'))
      continue;
    end

    % Extract all tokens on this line (there may be more than one)
    [s,f,t] = regexp(istr,tokenPattern);
    
    nTokens = size(t,2);
    
    for i = 1 : nTokens
      token = istr(t{i}(1):t{i}(2));
      if token(1) == '!'
        % Escaped token (remove the escape '!' character)
        ostr = regexprep(ostr,'%<!','%<','once');
      elseif LocIsTokenInList(token,bannerTokens)
        % Recognized banner token (do nothing)
      elseif LocIsTokenInList(token,requiredTokens)
        % Recognized reqired token
        if nTokens > 1
          % Detected multiple tokens on a line containing a required token.
          % This is not permitted (to keep it simple and robust).
          error(sprintf([...
              'Invalid template file: %s.\n',...
              'Token ''%s'' must be on its own line.\n',...
              'Error on line %d:\n%s\n'],inFileName,token,lineNo,istr))
        end
        ostr = regexprep(ostr,tokenPattern,[...
            '%<LibGetSourceFileSection(fileIdx,"',token,'")>'],'once');
        e = false;
        switch token
         case 'Includes'
          if ~isempty(prevReqToken), e = true;, end;
         case 'Defines'
          if ~strcmp(prevReqToken,'Includes'), e = true;, end;
         case 'Types'
          if ~strcmp(prevReqToken,'Defines'), e = true;, end;
         case 'Enums'
          if ~strcmp(prevReqToken,'Types'), e = true;, end;
         case 'Definitions'
          if ~strcmp(prevReqToken,'Enums'), e = true;, end;
         case 'Declarations'
          if ~strcmp(prevReqToken,'Definitions'), e = true;, end;
         case 'Functions'
          if ~strcmp(prevReqToken,'Declarations'), e = true;, end;
         otherwise
          error(['Unknown required token: ', token])
        end
        
        if e
          LocOutOfOrderError(token,inFileName,istr,lineNo,requiredTokens);
        end
        
        prevReqToken = token;
      else
        % Custom token
        ostr = regexprep(ostr,tokenPattern,[...
            '%<LibGetSourceFileCustomSection(fileIdx,"',token,'")>'],'once');
        custTokenBuf{custTokenIdx+1} = token;
        custTokenIdx = custTokenIdx + 1;
      end
    end
    
    % Write token expanded line.  Specific tokens are special handled.
    if strcmp(token,'Includes')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s',...
                  LocWriteFileGuard('#if'),...
                  LocWriteRTWToken('Includes'));
    elseif strcmp(token,'Types')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('IntrinsicTypes'),...
                  LocWriteRTWToken('PrimitiveTypedefs'),...
                  LocWriteRTWToken('UserTop'),...
                  LocWriteRTWToken('Typedefs'));
    elseif strcmp(token,'Declarations')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('ExternData'),...
                  LocWriteRTWToken('ExternFcns'),...
                  LocWriteRTWToken('FcnPrototypes'),...
                  LocWriteRTWToken('Declarations'));
    elseif strcmp(token,'Functions')
      buffer{rowCount}{2} = ...
          sprintf('%s\n%s\n%s\n%s\n%s\n%s',...
                  LocWriteRTWToken('Functions'),...
                  LocWriteRTWToken('CompilerErrors'),...
                  LocWriteRTWToken('CompilerWarnings'),...
                  LocWriteRTWToken('Documentation'),...
                  LocWriteRTWToken('UserBottom'),...
                  LocWriteFileGuard('#endif'));
    else
      buffer{rowCount}{2} = ostr;
    end
    
  end
  
  % Ensure that 'Functions' was the last required token
  if ~strcmp(prevReqToken,'Functions')
    txt = sprintf([...
        'Invalid template file: %s.\n',...
        'The required ''Functions'' token is missing.\n'],inFileName);
    error(txt)
  end
  
  % Open output file
  outId = fopen(outFileName,'w');
  if outId < 0
    error(['Unable to open output template file: ', outFileName]);
  end
  
  % Write a timestamp on the top of the file.
  timestampstr = sprintf([...
      '%%%%\n',...
      '%%%% Auto generated by Real-Time Workshop on %s from file:\n',...
      '%%%% %s\n',...
      '%%%%\n'],datestr(now),which(inFileName));
  fprintf(outId,'%s',timestampstr);

  % Write all the custom tokens that were found
  if ~isempty(custTokenBuf{1})
    fprintf(outId,'%%%% Identified custom tokens in code generation template:\n');
    fprintf(outId,'%%%%\n');
    custTokenBuf = sort(custTokenBuf);
    fprintf(outId,'%s\n',LocTokenFoundStr(custTokenBuf{1}));
    for idx = 2 : length(custTokenBuf)
      if ~isequal(custTokenBuf{idx},custTokenBuf{idx-1})
        fprintf(outId,'%s\n',LocTokenFoundStr(custTokenBuf{idx}));
      end
    end
    fprintf(outId,'%%%%\n');
  end
      
  % Write all the contents of the expanded file
  for rowCount = 1 : length(buffer)
    fwrite(outId,uint8(buffer{rowCount}{2}), 'uint8');
    fprintf(outId,'\n');
  end

  % Write EOF comment
  fprintf(outId,'%%%% [EOF]\n');
  LocCloseFiles(inId,outId);

catch

  % Clean up files and throw last error
  LocCloseFiles(inId,outId);
  error(lasterr)
  
end


% Close files
function LocCloseFiles(fid1,fid2)
  if fid1 ~= -1
    fclose(fid1);
  end
  if fid2 ~= -1
    fclose(fid2);
  end
  

% Find a token in a list of tokens
function value = LocIsTokenInList(token,tokenList)
  for i = 1 : length(tokenList)
    if strcmp(token,tokenList{i})
      value = true;
      return;
    end
  end
  value = false;
  
  
% Write a required token with its appropriate expansion
function str = LocWriteRTWToken(token)
  str = sprintf('%%<LibGetSourceFileSection(fileIdx,"%s")>\\',token);
  

% Write that a custom token was found
function str = LocTokenFoundStr(token)
  str = ['%<SLibSetSourceFileCustomTokenInUse(fileIdx,"',token,'")>'];
  
% Write the header file guard 
%   mode: #if    (top)
%         #endif (bottom)
function str = LocWriteFileGuard(mode)
  if strcmp(mode,'#if')
    str = sprintf([...
        '%%assign needGuard = LibGetModelFileNeedHeaderGuard(fileIdx)\n',...
        '%%if needGuard\n\n',...
        '  #ifndef _RTW_HEADER_%%<FileTag>_\n',...
        '  #define _RTW_HEADER_%%<FileTag>_\n',...
        '%%endif']);
  elseif strcmp(mode,'#endif')
    str = sprintf([...
        '%%if needGuard\n\n',...
        '  #endif /* _RTW_HEADER_%%<FileTag>_ */\n',...
        '%%endif']);
  else
    error(['Unknown mode: ', mode])
  end


% Report an error for out of order or missing tokens.
function LocOutOfOrderError(token,fname,str,count,reqtokens)
  txt = '';
  for i = 1 : length(reqtokens)
    txt = sprintf('%s  %s\n',txt,reqtokens{i}{1});
  end
  error(sprintf([...
      'The ''%s'' token is out of order in template file: %s.\n',...
      'Be sure to include all the required tokens in the following order:\n',...
      '%s',...
      'Error on line %d in %s:\n%s is out of order.\n'],...
                token,fname,txt,count,fname,str))
