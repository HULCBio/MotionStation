function html = findhtmllinks(h,stream)
%  FINDHTMLLINKS  
%  This function will find all html links for diagnostic viewer
%  Copyright 1990-2004 The MathWorks, Inc.
  
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:21 $

  
  % first find the links
  [s, e, types] = find_links_l(h, stream);
  % Process the link and hyperlink them
  html = process_text(h, s, e, types, stream);

%--------------------------------------------------------------------------
function [S, E, linkTypes] = find_links_l(h,stream)
%
%
%
contents = h.Contents;
switch contents.type,
case {'Lex', 'Parse'}, findFiles = 0;
otherwise,             findFiles = 1;
end;

S = [];
E = [];
linkTypes = {};
numFound = 0;

if ~ischar(stream), error('bad input'); end;
if nargin < 4, nag=[]; end;

prevLastErr = lasterr;
try,
    %
    % match standard Stateflow Ids
    % suppress multibyte character warnings
    %
    warningState = warning;
    warning('off', 'REGEXP:multibyteCharacters');
    pattern = '#\d+(\.\d+)*';
    [sv,ev] = regexp(stream, pattern);
    warning(warningState);
    for i=1:length(sv),
        s = sv(i);
        e = ev(i);
        if s>0 & s<e,
            S = [S;s];
            E = [E;e];
            linkTypes{numFound+1} = 'id';
            numFound = numFound + 1;
        end;
    end;
    
    if (0 & findFiles & ~isempty(nag) & contents.preprocessedFileLinks & ~isempty(nag.msg.links))
        % all the file links should be preprocessed so we should do it
        % again! Instead just return the preprocessed links
        s = [contents.links(:).si]';
        S = [S;s-1];
        
        e = [contents.links(:).ei]';
        E = [E;e+1];
        linkTypes = {linkTypes{:},contents.links(:).type};
    elseif findFiles
        %
        % match file/system paths in double or single quotes
        %
        [sv,ev] = find_quoted_patterns_l( stream );
        for i=1:length(sv),
            s = sv(i);
            e = ev(i);
            if s>0 & s<e,
                si = s+1;
                ei = e-1;
                if si<ei,
                    txt = stream(si:ei);
                    if is_absolute_path_l(txt)
                        [isFile, fileType] = is_a_file_l(txt);
                    else
                        fullFileName = fullfile(h.HyperRefDir,txt);
                        [isFile, fileType] = is_a_file_l(fullFileName);
                    end
                    if isFile,
                        S = [S; s];
                        E = [E; e];
                        linkTypes{numFound+1} = fileType;
                        numFound = numFound + 1;
                    end;
                end;
            end;
        end;
    end;
catch
    lasterr(prevLastErr);
    %%%% Error in hyperlink detection %%%% do not display thiss
end;

if ~isempty(S),
    S = S - 1;
    if any(S < 0) error('bad'); end;
end;
%------------------------------------------------------------------------
function [si,ei] = find_quoted_patterns_l( stream )
%Find all quoted strings with their start and end indices.
%These constitute potential file links.
si=[]; ei=[];
delim = find(stream<' ');
s2 = find(stream=='"');
s1 = find(stream=='''');
if isempty(s1) & isempty(s2)
    return;
end
us = [s2,delim,s1];
ubs = [ones(size(s2)),zeros(size(delim)),-ones(size(s1))];
[s,indx] = sort(us);
bs = ubs(indx);
good = find((bs(1:end-1)==bs(2:end)) & (bs(1:end-1)~=0));
si = s(good);
ei = s(good+1);
%-------------------------------------------------------------------------    
function htmlText = process_text(h, sv,ev,typesv,infoText)
htmlBegin = '<html>';
htmlText = '';

[b indx] = sortrows(sv);
sv = sv(indx);
ev = ev(indx);
typesv = typesv(indx);

if (length(sv) == 0)
    htmlText = infoText;
else
    for i=1:length(sv),
        s = sv(i)+1;
        e = ev(i);
        linkType = typesv{i};
        
        % this makes the first part of the string
        if (i == 1)
            if (s ~= 1)
                firstPart = infoText(1:(s-1));
            else
                firstPart = '';
            end
        else
            firstPart = infoText(ev(i-1)+1:(s-1));
        end
        
        % This makes the link text part of the message
        linkText = infoText(s:e);
        linkOp = '';
        linkEnd = '</a>';
        linkBegin = '<a meval=';
        t = linkText;
        
        % remove all spaces
        if (isspace(t(1)))
            t(1)= [];
        end
        
        % Here deal with the first and or last
        % character
        if (isequal(linkType,'id'))
            t(1) = [];
        else  
            t([1 end]) = []; %remove quotes
        end
        % If you are dealing with a file
        % see if you have to use the full path
        % here
        if ((isequal(linkType,'txt')))
            if (is_absolute_path_l(t) ~= 1)
                t = [h.HyperRefDir,filesep,t];
            end
        end
        t = ['''',t,'''']; %put back in single quotes
        linkOp = ['"das_dv_hyperlink(''',linkType,''',',t,')"'];
        link = [linkBegin,linkOp,'>',linkText];
        
        % Here append all the necessary parts of this text
        %include 1) firstPart
        %        2) link
        %        3) linkEnd
        %htmlText = [htmlText, htmlBegin, link, linkEnd];
        if (i == 1)
            htmlText = [htmlBegin, firstPart, link, linkEnd];
        else
            htmlText = [htmlText, firstPart, link, linkEnd];
        end;    
    end  
end
if (length(sv) > 0)
    lastLinkIndex = ev(end);
else
    lastLinkIndex = 0;
end

if (lastLinkIndex > 0 & lastLinkIndex < length(infoText))
    htmlText = [htmlText, infoText((lastLinkIndex+1):end)];    
end    
     
 %htmlText = [htmlText,'</html>'];
 
 %--------------------------------------------------------------------------
function [isFile, fileType] = is_a_file_l(file),
%
%
%
isFile = 0;
fileType = '';
oldWarn=warning;
warning('off');
file = fliplr(deblank(fliplr(deblank(file))));
switch exist(file,'file'),
case 0, % does not exist
    isFile = (exist(file, 'file') ~= 0 & file_has_good_extension(file));
    
    if isFile, 
        fileType = 'txt';
    else,
        prevLastErr = lasterr;
	prevslLastError = sllasterror;
        try,
          get_param(file, 'handle');
          isFile = 1;
          fileType = 'mdl';
        catch,
          lasterr(prevLastErr);
          sllasterror(prevslLastError);
          if (evalin('base', ['exist(''' file ''', ''var'')']))
            if (evalin('base', ['isa(' file ', ''Simulink.Bus'')']))
              isFile = 1;
              fileType = 'bus';
            end
          end
        end;
    end;
case 2, % is a file
    if file_has_good_extension(file) & ~isequal(exist(file),5), 
        isFile = 1;
        fileType = 'txt';
    end;
case 4, % is a MDL file on the path
    isFile = 1;
    fileType = 'mdl';
case 7, % is a directory
    x = dir(file);
    if ~isempty(x), % check that the system also thinks this is a directory 
    isFile = 1;
    fileType = 'dir';
    end;
end;

warning(oldWarn);


%--------------------------------------------------------------------------
function goodExt = file_has_good_extension(file),
%
%
%
goodExt = 1;
if length(file) > 4,
    k = findstr(file,'.');
    if (k > 0),
        ext = file(k+1:end);
        switch ext,
        case {'exe', 'dll', 'obj', 'lib', 'ilk', 'mat', 'fig', 'exp', 'res', 'zip'}, % add to exclude
            goodExt = 0;
        end;
    end;    
end;
%--------------------------------------------------------------------------
function isAbsPath = is_absolute_path_l(fileName)
isAbsPath = 0;
if(length(fileName)>=2)
    if(fileName(2)==':' | fileName(1)==filesep)
        isAbsPath = 1;
    end
    
else
    if( length(fileName)>=1 & (fileName(1)=='/' | fileName(1) == '\'))
        isAbsPath = 1;
    end
end

