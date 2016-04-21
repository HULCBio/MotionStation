function q = loadobj(s)
%LOADOBJ Load filter for objects.
%   B = LOADOBJ(A) is called by LOAD when an object is loaded from a .MAT
%   file. The return value B is subsequently used by LOAD to populate the
%   workspace.  LOADOBJ can be used to convert one object type into
%   another, to update an object to match a new object definition, or to
%   restore an object that maintains information outside of the object
%   array.
%
%   If the input object does not match the current definition (as defined
%   by the constructor function), the input will be a struct-ized version
%   of the object in the .MAT file.  All the information in the original
%   object will be available for use in the conversion process.
%
%   LOADOBJ will be separately invoked for each object in the .MAT file.
%
%   See also LOAD, SAVEOBJ.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:35:36 $

% Version history.
% 1 = R12
%
%  Default R12 structure:
%  struct(quantizer)
%              mode: 'fixed'
%         roundmode: 'floor'
%      overflowmode: 'saturate'
%            format: [16 15]
%         quantizer: [1x1 com.mathworks.toolbox.filterdesign.Sfixfloorsaturate]
%           version: 1
%
% From SAVEOBJ, the saved R12 structure is:
%
%
% There will be no higher version numbers for this particular object.
% After R12, the @quantizer object was superseded by the UDD object
% quantum.mquantizer whose parent is quantum.quantizer.  The file
% QUANTIZER.M is a gateway to quantum.mquantizer so the constructor
% syntax should stay the same as R12 for all future versions.
%
% THIS FILE SHOULD ALWAYS EXIST AS @QUANTIZER/LOADOBJ.M EVEN WHEN THE
% OBJECT IS OBSOLETED.  THIS ASSURES THAT MAT-FILES CONTAINING THE
% OLD OBJECT WILL ALWAYS BE ABLE TO BE LOADED.

switch s.version
  case 1
    % If we got into this function, then s is a structure or a
    % version 1 object.  Ensure that it is a structure:
    s = struct(s);
    % Create new object q, and set all its properties from the structure.
    wrn = warning('off');
    q = quantizer;
    q.mode         = s.mode;
    q.roundmode    = s.roundmode;
    q.overflowmode = s.overflowmode;
    q.format       = s.format;
    q.max          = s.quantizer.max;
    q.min          = s.quantizer.min;
    q.noverflows   = s.quantizer.nover;
    q.nunderflows  = s.quantizer.nunder;
    q.noperations  = s.quantizer.noperations;
    warning(wrn);
  otherwise
    % If nothing else can be done, return the structure that was saved.
    warning('Unrecognized QUANTIZER version.  Returning saved structure.')
    q = s;
end