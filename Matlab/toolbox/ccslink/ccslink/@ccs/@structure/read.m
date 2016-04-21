function resp = read(st,varargin)
% READ Read values stored in the location pointed to the STRUCTURE object ST.
% 
% 	O = READ(st) - reads the numeric values of each STRUCTURE member in ST. This returns a Matlab
%     structure having the member names as fields.
%     
% 	O = READ(st,val,member) - reads the numeric value of the STRUCTURE member specified by MEMBER.
%     
% 	O = READ(st,val,member,varargin) - reads the numeric value of the STRUCTURE member specified by MEMBER,
% 	where VARARGIN are extra READ options. See READ options of MEMBER.
% 
% 	O = READ(st,index,val,member) - reads the numeric value of the member of the STRUCTURE element INDEX.
%     
% 	O = READ(st,index,val,member,varargin) - reads the numeric value of the member of the STRUCTURE 
%     element INDEX, where VARARGIN are extra READ options. See READ options of MEMBER.
% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $ $Date: 2004/04/08 20:47:08 $

if ~ishandle(st),
    error('MATLAB:STRUCTURE_read_m:InvalidStructureHandle',...
        'First parameter must be a valid STRUCTURE handle.');
end
resp = read_structure(st,varargin);

% [EOF] read.m
 