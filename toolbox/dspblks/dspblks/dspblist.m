function list = dspblist(lib)
% DSPBLIST returns a list of all blocks in the DSP Library.
%   Each block is described by the graphical and simulink path.
%
%   For example, the paths for the Transpose block are:
%	 list.g = 'dsplib/Math Functions/Matrix Math/Transpose'
%   list.s = 'dspmtrx/Transpose'

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/12/23 22:27:59 $

error(nargchk(0,2,nargin));

global list;
list = [];

if nargin == 0, lib = 'dsplibv4'; end
if strcmp(lib,'dsplib'), lib='dsplibv4'; end
load_system(lib);

% Find all blocks in current library:
% Delete first element from the list, 
% since it's the name of the library
blocks = find_system(lib,'searchdepth',1,'lookundermasks','all'); 
blocks(1) = [];

% Sort blocks according to position instead of alphebetically:
blocks = sort_blocks(blocks);

for i = 1:length(blocks),
  dsp_recurse(blocks{i},[]);
end
close_system(lib);

%
%=============================================================================
function dsp_recurse(block,sys)

global list;

% ignore demo blocks
bcolor = get_param(block,'backgroundcolor');
switch bcolor,
   
case {'white','orange'}
   glist = [sys '/' get_param(block,'name')];
   slist = block;
   
   if ~isempty(glist),
      n = length(list);
   	list(n+1).g = glist;
      list(n+1).s = slist;
   end
     
case 'yellow'
	% check if block is linked (checks for Simulink Connections):
   if ~isempty(strmatch('none',get_param(block,'linkstatus')))
		sys = get_param(block,'openfcn');
         
      if isempty(sys),
         open_system(block);
         close_system(block);
         new_blocks = find_system(block,'searchdepth',1,'lookundermasks','all'); 
         new_blocks(1) = [];
         new_blocks = sort_blocks(new_blocks);
            
      else
         % get the blocks under this library:
         load_system(sys);
         new_blocks = find_system(sys,'searchdepth',1,'lookundermasks','all'); 
         new_blocks(1) = [];
      end
      
      % recurse on new blocks 
      for j = 1:length(new_blocks),
         dsp_recurse(new_blocks{j},block);
      end
   end
end
%=============================================================================
%

%
%=============================================================================
function [y,m] = sort_blocks(x)
% Sort blocks according to position in library.

% Find position of all the blocks. 
% Change the cell array to a matrix.
% Sort over the first column of the matrix 
% (since it's the x position)

pos = get_param(x,'position'); 		
pos = cat(1,pos{:});
[n,m] = sort(pos(:,1));
y = x(m);

% Equivalent code:
% pos = [];
% for i = 1:length(x),
%     pos_vect = get_param(x{i},'position');
% 	   pos = [pos pos_vect(1)];   
% end
% [n,m] = sort(pos);
% y = x(m);
   

%=============================================================================
%
