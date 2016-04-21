function [xResultURI,xProcessor]=xslt(varargin)
%XSLT  Transform an XML document using an XSLT engine.
%   RESULT = XSLT(SOURCE,STYLE,DEST) transforms an XML document using
%   a stylesheet and returns the resulting document's URL.  The
%   function uses these inputs, the first of which is required:
%     SOURCE is the filename or URL of the source XML file.  SOURCE
%       can also be a DOM node.
%     STYLE is the filename or URL of an XSL stylesheet
%     DEST is the filename or URL of the desired output document; if
%       DEST is absent or empty, the function uses a temporary filename.
%       If DEST is '-tostring', the output document will be returned
%       as a MATLAB string.
%
%   [RESULT,STYLE] = XSLT(...) returns a processed stylesheet
%   appropriate for passing to subsequent XLST calls as STYLE.
%   This prevents costly repeated processing of the stylesheet.
%
%   XSLT(...,'-web') displays the resulting document in a
%   Web Browser.
%
%   Example:
%   This will convert a file "info.xml" to a temporary file
%   using the stylesheet "info.xsl" and launch the result
%   in the help browser.  MATLAB has several info.xml files
%   which are used by the Start Button.
%
%   xslt info.xml info.xsl -web
%    
%   See also XMLREAD, XMLWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/10 23:29:49 $

% Advanced use:
%   SOURCE can also be a XSLTInputSource
%   STYLE can also be a StylesheetRoot or XSLTInputSource
%   DEST can also be an XSLTResultTarget.  Note that RESULT may be
%      empty in this case since it may not be possible to determine
%      a URL.
%   ; if STYLE
%       is absent or empty, the function uses the stylesheet
%       named in the xml-stylesheet processing instruction in the
%       SOURCE XML file.  (This does not always work)

[isView,isToString,errorListener,uriResolver,varargin]=locFlags(varargin);
xUtil = 'com.mathworks.xml.XMLUtils';

%------------ Find Source ----------
if ischar(varargin{1})
    %varargin{1}=file2urn(varargin{1},logical(1));
    varargin{1} = xmlstringinput(varargin{1},true,false);
end
xSource=javaMethod('transformSourceFactory',xUtil,varargin{1});

%------------ Find Result ----------
if isToString
    stringWriter = java.io.StringWriter;
    xResult = stringWriter;
else
    if length(varargin)<3 | isempty(varargin{3})
        xResult = java.io.File([tempname,'.html']);
    else
        xResult = varargin{3};
        if ischar(xResult)
            %xResult = file2urn(xResult);
            xResult = xmlstringinput(xResult,false,false);
        end
    end
    
    if ischar(xResult)
        xResultURI = xResult;
    elseif isa(xResult,'java.io.File')
        xResultURI = xmlstringinput(char(xResult.getCanonicalPath),false,false);
    else
        xResultURI = '';
    end
end

xResult=javaMethod('transformResultFactory',...
    xUtil,...
    xResult);

%------------ Find Stylesheet ----------
if length(varargin)<2
    varargin{2}='';
end
xProcessor = locTransformer(varargin{2},xSource,xUtil,errorListener,uriResolver);

%--------- Perform Transformation -----------
xProcessor.transform(xSource,xResult);

if isToString
    xResultURI = char(stringWriter.toString);
    if isView
        web(['text://' xResultURI]);
    end
elseif isView & ~isempty(xResultURI)
    web(xResultURI);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isView,isToString,errorListener,uriResolver,arg]=locFlags(arg)

flagIdx = strncmp(arg,'-',1);
flagStrings = arg(find(flagIdx));
arg=arg(find(~flagIdx));
isView=any(strcmp(flagStrings,'-web'));
isToString=any(strcmp(flagStrings,'-tostring'));

%see if any of the input arguments are a javax.xml.transform.ErrorListener
errorListener=[];
uriResolver=[];
i=1;
while i<=length(arg)
    if isa(arg{i},'javax.xml.transform.ErrorListener')
        errorListener=arg{i};
        arg=[arg(1:i-1),arg(i+1:end)];
    elseif isa(arg{i},'javax.xml.transform.URIResolver')
        uriResolver=arg{i};
        arg=[arg(1:i-1),arg(i+1:end)];
    else
        i=i+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xProcessor = locTransformer(xStyle,xSource,xUtil,errorListener,uriResolver)

if isa(xStyle,'javax.xml.transform.Transformer')
    xProcessor = xStyle;
    if ~isempty(errorListener)
        %note that SAXON does not yet honor the errorListener so this action
        %doesn't really do anything yet
        xProcessor.setErrorListener(errorListener);
    end
    
    if ~isempty(uriResolver)
        xProcessor.setURIResolver(uriResolver);
    end
else
    xformFactory = javaMethod('newInstance',...
        'javax.xml.transform.TransformerFactory');
    if ~isempty(errorListener)
        xformFactory.setErrorListener(errorListener);
    end
    
    if ~isempty(uriResolver)
        xformFactory.setURIResolver(uriResolver);
    end
    
    if isempty(xStyle) %find the stylesheet
        try
            xStyle=javaMethod('getAssociatedStylesheet',xformFactory,...
                xSource,'','','');
        catch
            error('Could not find associated stylesheet');
        end
    else
        if ischar(xStyle)
            xStyle = xmlstringinput(xStyle,true,false);
        end
        xStyle = javaMethod('transformSourceFactory',...
            xUtil,xStyle);
    end
    
    xProcessor = javaMethod('newTransformer',...
        xformFactory,xStyle);
end