function obj2mfile(objects, filename, varargin)
%OBJ2MFILE Convert instrument object to MATLAB code.
%
%   OBJ2MFILE(OBJ,'FILENAME') converts the instrument object, OBJ, 
%   to the equivalent MATLAB code using the SET syntax and saves the
%   MATLAB code to the specified file, FILENAME. If an extension is 
%   not specified, the .m extension is used. By default, only those
%   properties that are not set to their default values are written 
%   to the file, FILENAME. OBJ can be a single instrument object or
%   an array of instrument objects.
%
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX') converts the instrument object, 
%   OBJ, to the equivalent MATLAB code using the specified SYNTAX and
%   saves the code to the file, FILENAME. The SYNTAX can be either 'set'
%   or 'dot'. By default, the 'set' SYNTAX is used.
%
%   OBJ2MFILE(OBJ,'FILENAME','MODE')
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX','MODE') saves the equivalent MATLAB 
%   code for all properties if MODE is 'all' and saves only the properties
%   that are not set to their default values if MODE is 'modified'. By
%   default, the 'modified' MODE is used.
%
%   OBJ2MFILE(OBJ,'FILENAME','REUSE')
%   OBJ2MFILE(OBJ,'FILENAME','SYNTAX','MODE','REUSE') checks for an 
%   existing instrument object, OBJ, before creating OBJ. If REUSE is
%   'reuse', the object is used if it exists otherwise the object is
%   created. If REUSE is 'create', the object is always created. By 
%   default, REUSE is 'reuse'.
%
%   An object will be re-used if the object had the same constructor 
%   arguments as the object about to be created and the Type and Tag 
%   property values are the same.
%
%   If OBJ's UserData is not empty or if any of the callback properties
%   are set to a cell array of values or to a function handle, then the
%   data stored in those properties are written to a MAT-file when the 
%   instrument object is converted and saved. The MAT-file has the same
%   name as the M-file containing the instrument object code.  
%
%   The values of read-only properties will not be restored. Therefore,
%   if an object is saved with a Status property value of open, the 
%   object will be recreated with a Status property value of closed 
%   (the default value). PROPINFO can be used to determine if a property
%   is read-only.
%
%   To recreate OBJ, type the name of the M-file.  
%
%   Example:
%       g = gpib('ni', 0, 2);
%       set(g, 'Tag', 'mygpib', 'EOSMode', 'read', 'EOSCharCode', 'CR');
%
%       % To save g:
%       obj2mfile(g, 'mygpib.m', 'dot', 'all');
%
%       % To recreate g:
%       copyOfG = mygpib;
%
%   See also INSTRUMENT/PROPINFO, INSTRHELP.
%

%   MP 12-11-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/01/16 20:00:14 $

error('icgroup:obj2mfile:unsupportedFcn', 'Wrong object type passed to OBJ2MFILE. Use the object''s parent.');
