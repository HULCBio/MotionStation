%FIXPTDEFTYPE is for internal use only by the Fixed Point Blockset

% Define default Storage-Data-Types
%   for use by Fixed Point Blocks

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.9 $  
% $Date: 2002/04/10 18:59:20 $

%
% Default SHORT storage type
%
if exist('ShortType') ~= 1
   ShortType = sfix(8);
end

%
% Default BASE storage type
%
if exist('BaseType') ~= 1
   BaseType = sfix(16);
end

%
% Default LONG storage type
%
if exist('LongType') ~= 1
   LongType = sfix(32);
end

%
% Default EXTENDED storage type
%
if exist('ExtendedType') ~= 1
   ExtendedType = sfix(64);
end   
   
