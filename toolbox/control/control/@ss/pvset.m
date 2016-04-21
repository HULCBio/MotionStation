function sys = pvset(sys,varargin)
%PVSET  Set properties of LTI models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.24 $ $Date: 2002/04/10 06:00:46 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.

ni = nargin;
abcde = zeros(1,5);        % keeps track of which state-space matrices are reset
LTIProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the LTI parent

for i=1:2:ni-1,
   % Set each Property Name/Value pair in turn. 
   Property = varargin{i};
   Value = varargin{i+1};
   
   % Perform assignment
   switch Property
   case 'a'
      sys.a = Value;
      abcde(1) = 1;
      
   case 'b'
      sys.b = Value;
      abcde(2) = 1;
      
   case 'c'
      sys.c = Value;
      abcde(3) = 1;
      
   case 'd'
      sys.d = Value;
      abcde(4) = 1;
      
   case 'e'
      sys.e = Value;
      abcde(5) = 1;
      
   case 'StateName',
      sys.StateName = StateNameCheck(Value);
      
   otherwise
      LTIProps([i i+1]) = 1;
      
   end % switch
end % for


% Set all LTI properties at once
% RE: At this point, VARARGIN contains only valid LTI properties in full lower-case format
LTIProps = find(LTIProps);
if ~isempty(LTIProps)
   sys.lti = pvset(sys.lti,varargin{LTIProps});
end

% CONSISTENCY CHECKS:
% 1) Check consistency of A,B,C,D,E
sys = abcdechk(sys,abcde);

% 2) Check length of state name
nx = size(sys,'order');
ns = max(nx(:));
if length(sys.StateName)~=ns,
   if isempty(sys.StateName) | isequal('',sys.StateName{:}),
      EmptyStr = {''};
      sys.StateName = EmptyStr(ones(ns,1),1);
   else
      error('Invalid system: length of StateName does not match number of states.')
   end
end

% Check LTI property consistency
sys.lti = lticheck(sys.lti,size(sys.d));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction StateNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sn = StateNameCheck(sn)
% Checks specified I/O names
if isempty(sn),  
   sn = sn(:);   % make 0x1
   return  
end

% Determine if first argument is an array or cell vector 
% of single-line strings.
if ischar(sn) & ndims(sn)==2,
   % A is a 2D array of padded strings
   sn = cellstr(sn);
   
elseif iscellstr(sn) & ndims(sn)==2 & min(size(sn))==1,
   % A is a cell vector of strings. Check that each entry
   % is a single-line string
   sn = sn(:);
   if any(cellfun('ndims',sn)>2) | any(cellfun('size',sn,1)>1),
      error('All cell entries of StateName must be single-line strings.')
   end
   
else
   error(sprintf('%s\n%s',...
     'StateName must be set to a 2D array of padded strings (like [''a'' ; ''b'' ; ''c''])',...
     'or a cell vector of strings (like {''a'' ; ''b'' ; ''c''}).'))

end



