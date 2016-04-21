function [index,status] = pmatchm(StrCell,str)
%PMATCH  Case insensitive string matching with automatic completion.
%
%   [INDICES,STATUS] = PMATCH(STRCELL,STR)  takes a cell array 
%   STRCELL containing reference names and a string STR to be 
%   matched.  It returns an index vector INDEX such that 
%   STRCELL(INDEX) are all the strings matching STR.
%   
%   STATUS is the empty matrix if exactly one cell matches each
%   string.  Otherwise it returns a "standard" error message.
%
%   Note:  PMATCH is optimized for the LTI object and uses only
%   the first two characters of STR for comparison purposes.

%   Author(s): A. Potvin, 3-1-94
%   Revised: P. Gahinet, 4-1-96
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $

%   Note: replace nchars = min(l,2) by nchars = l below to obtain 
%   following general behavior:
%        StrCell = {'CurrentMenu'; 'Color'; 'CurrentObject'}
%        STR = 'current' 
%           INDICES = []
%           STATUS  = 'Ambiguous property name: supply more characters'
%        STR = 'currentmenu' 
%           INDICES = 1
%           STATUS  = []
%        STR = 'foobar' 
%           INDICES = []
%           STATUS  = 'Invalid object property'

index = []; 
status = [];
l1=length(StrCell);
if ~isstr(str),
   status = 'Property names must be strings';
   return
elseif ndims(str)>2 | min(size(str))>1,
   status = 'Property names must be single-line strings';
   return
end

% STR is a single-line string
str = str(:)';

%Handle shortcuts

 
s = lower(str);
ls = length(s);


% Set number of chars used to identify name
nchars = min(ls,8);  

% Find all matches in StrCell
% RE: Assumes all strings in StrCell are lower case
for i=1:length(StrCell),
   refstr = StrCell{i};
 %  ncc = min(length(refstr),nchars);  % # chars used for comparison
   if strcmp(lower(refstr),s),
      index = [index; i];
   end
end

if isempty(index)
   for i=1:length(StrCell),
   refstr = StrCell{i};
   if length(refstr)>=nchars % # chars used for comparison
     % disp('hej'),keyboard
   if strcmp(lower(refstr(1:nchars)),s(1:nchars)),
      index = [index; i];
   end
   end
 end
 end

% Error handling 
nhits = length(index); %keyboard
if nhits==0,
   status = ['Invalid object property "' str '"'];
   index = [];  return
elseif nhits>1 
  
    %keyboard      
   status = ['Ambiguous property name "' str '". Supply more characters.'];
   index = [];  return
   end
%end
% To make Fs/Ts, Fstart/Tstart etc synonomous:
  
% end pmatch.m
