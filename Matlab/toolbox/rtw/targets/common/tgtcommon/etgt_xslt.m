%% File : etgt_xslt(stylesheet,xmlfile,outfile,[parameter1,value1, parameter2, value2 , .....])
%% 
%% Abstract
%%   Ivoke an XSLT style sheet on an xml file
%%
%% Parameters
%%	stylesheet 	- path to xslt stylesheet
%%	xmlfile		- path to xml file
%%	outfile		- output file
%%	optional arguments - All other arguments are optional and are
%%						 passed to the XSL engine to pass to the XSL
%%						 file as parameter value pairs.
%%
%% Usage:
%% 	etgt_xslt('stylesheet.xsl','file.xml','out.xml','param1',0,'param2',0,'param3',0);
%%

%% $Revision: 1.1.6.3 $
%% $Date: 2004/04/29 03:40:02 $
%%
%% Copyright 1990-2004 The MathWorks, Inc.

function etgt_xslt(stylesheet,xmlfile,outfile,varargin)
import('javax.xml.transform.stream.*');
import('javax.xml.transform.*');
import('java.io.*');

% Locate the stylesheet
stylesheet_full_path = which(stylesheet);
if isempty(stylesheet_full_path)
    error(['Stylesheet ' stylesheet ' cannot be found.']);
end

% Locate the xml file
xmlfile_full_path = which(xmlfile);
if isempty(xmlfile_full_path) 
    xmlfile_full_path = xmlfile;
    if ~exist(xmlfile_full_path)
        error(['XML File ' xmlfile ' cannot be found.']);
    end
end

if rem(length(varargin),2)~=0
    error('The optional arguments should be a set of parameter value pairs');
end
    
% Create the input and output streams
os = StreamResult(FileOutputStream(File(outfile)));
is = StreamSource(xmlfile_full_path);
xslt_is = StreamSource(stylesheet_full_path);

% Create the XSLT transformer
tFactory = TransformerFactory.newInstance;
transformer = tFactory.newTransformer(xslt_is);

% Setup the transformation parameters
for i=1:(length(varargin)/2)
    param = varargin{i*2 - 1};
    val = varargin{i*2};
    transformer.setParameter(param,val);
end

% Cleanup and dump the document handles
transformer.transform(is, os);
os.getOutputStream.close;
transformer.clearDocumentPool;
