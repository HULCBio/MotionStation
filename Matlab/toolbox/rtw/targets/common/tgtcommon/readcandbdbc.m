% READCANDBDBC Reads a candb file into matlab
%
% messages = readcandbdbc(dbc_fname, format)
%   
% Arguments
%   dbc_fname - the full path to the dbc file to read in
%   format    - 'struct' | 'html' - parameter is optional and defaults
%               to 'struct' to return a structure array. 'html' requests
%               the return of an html file.
%
% Returns
%   messages  - a structure array of all messages in the 
%               file or an html report.

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $
%   $Date: 2004/04/29 03:40:04 $
function data = readcandbdbc(fname, format)

if nargin == 1
    format = 'struct';
end

switch format
case { 'struct' 'html' }
otherwise
    error([format ' is not a valid for parameter ''format''.']);
end

import('com.mathworks.toolbox.ecoder.canlib.CanDB.dbcparser.*');
import('java.io.*');

% Read in the input file
fis = FileInputStream(fname);

% Create the parser
t = candb_pp(fis);

% Parse the file
astCANdb = t.CANdb();

% Collect the XML string
xmlstring = astCANdb.toXML('','   ');

% Write the XML string to a temporary file
fosfname = tempname;
fos = FileOutputStream(fosfname);
osw = OutputStreamWriter(fos);

osw.write(xmlstring,0,xmlstring.length);
osw.flush;
fos.close;


% Convert the XML file to M Code
switch format
case 'html'
    xsltfname = which('candb.xsl');
case 'struct'
    xsltfname = which('candb_matlab.xsl');
end
candbmfname  = [ tempname '.m' ];
xslt(fosfname, xsltfname, candbmfname);

switch format
case 'html'
    data = textread(candbmfname,'%s','delimiter','\n');
    data = sprintf('%s\n',data{:});
case 'struct'
    % Run the mfile as a script
    currDir = pwd;
    try
        [fpath, fname] = fileparts(candbmfname);
        cd(fpath);
        data = eval(fname);
    catch
        % error running m-script
        % make sure we restore the path
        cd(currDir);
        rethrow(lasterror);
    end
    cd(currDir);
end

