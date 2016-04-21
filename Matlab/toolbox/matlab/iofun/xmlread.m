function [parseResult,p] = xmlread(fileName,varargin)
%XMLREAD  Parse an XML document and return a Document Object Model node.
%   DOMNODE = XMLREAD(FILENAME) reads a URL or filename and returns
%   a Document Object Model node representing the parsed document.
%
%   See also XMLWRITE, XSLT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/06/17 13:27:31 $

% Advanced use:
%   Note that FILENAME can also be an InputSource, File, or InputStream object
%   DOMNODE = XMLREAD(FILENAME,...,P,...) where P is a DocumentBuilder object
%   DOMNODE = XMLREAD(FILENAME,...,'-validating',...) will create a validating
%             parser if one was not provided.
%   DOMNODE = XMLREAD(FILENAME,...,ER,...) where ER is an EntityResolver will
%             will set the EntityResolver before parsing
%   DOMNODE = XMLREAD(FILENAME,...,EH,...) where EH is an ErrorHandler will
%             will set the ErrorHandler before parsing
%   [DOMNODE,P] = XMLREAD(FILENAME,...) will return a parser suitable for passing
%             back to XMLREAD for future parses.
%   

p = locGetParser(varargin);
locSetEntityResolver(p,varargin);
locSetErrorHandler(p,varargin);

if ischar(fileName)
    fileName = xmlstringinput(fileName,logical(1));
elseif isa(fileName,'org.xml.sax.InputSource') | ...
        isa(fileName,'java.io.File') | ...
        isa(fileName,'java.io.InputStream')
    %noop - DocumentBuilder.parse accepts all these data types directly,
    %so we don't need to alter the input if it is one of these classes
else
    error('Input must be a file name or URL');
end

if isa(fileName,'java.io.File')
    %Xerces is happier when UNC filepaths are sent as a
    %FileReader/InputSource than a File object
    %Note that FileReader(String) is also valid
    fileName = org.xml.sax.InputSource(java.io.FileReader(fileName));
end

parseResult = p.parse(fileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = locGetParser(args)

p = [];
for i=1:length(args)
    if isa(args{i},'javax.xml.parsers.DocumentBuilderFactory')
        javaMethod('setValidating',args{i},locIsValidating(args));
        p = javaMethod('newDocumentBuilder',args{i});
        break;
    elseif isa(args{i},'javax.xml.parsers.DocumentBuilder')
        p = args{i};
        break;
    end
end

if isempty(p)
    parserFactory = javaMethod('newInstance',...
        'javax.xml.parsers.DocumentBuilderFactory');
        
    javaMethod('setValidating',parserFactory,locIsValidating(args));
    %javaMethod('setIgnoringElementContentWhitespace',parserFactory,1);
    %ignorable whitespace requires a validating parser and a content model
    p = javaMethod('newDocumentBuilder',parserFactory);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf=locIsValidating(args)

tf=any(strcmp(args,'-validating'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetEntityResolver(p,args);

for i=1:length(args)
    if isa(args{i},'org.xml.sax.EntityResolver')
        p.setEntityResolver(args{i});
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function locSetErrorHandler(p,args);

for i=1:length(args)
    if isa(args{i},'org.xml.sax.ErrorHandler')
        p.setErrorHandler(args{i});
        break;
    end
end
