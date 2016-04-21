function warn_bad_blocks( c, badList, msg )
%WARN_BAD_BLOCKS warn if a list of blocks contains invalid entries
% this function provides a common way to report the list of
% incorrectly specified blocks.
%

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:58 $
if isempty( badList ), return; end

if nargin == 2
   if iscell( badList )
      msg = 'Error: invalid block name(s): ';
   else
      msg = 'Error: invalid block handle(s): ';
   end
end

if iscell( badList ), ic = 1; else ic = 0; end

for i = 1:length( badList )
   if ic, 
      msg = [ msg, badList{i}, ', ' ];
   else
      msg = [ msg, num2str( badList(i) ), ', ' ];
   end
end
msg( end-1:end ) = [];

status( c, msg, 1 );