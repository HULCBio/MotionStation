function index = end(sys,position,numindices)
%END  Overloaded END for LTI objects.
%
%   END(SYS,POSITION,NUMINDICES) returns the index
%   corresponding to the last entry along the dimension
%   POSITION in the LTI model or LTI array SYS.
%   NUMINDICES is the number of indices used in the
%   indexing expression.
%
%   For example,
%      SYS(end,1)   extracts the subsystem from the first
%                   input to the last output
%      SYS(1,1,end) extracts the mapping from first input
%                   to first output in the last model of
%                   the LTI array SYS.
%
%   When using END to grow an LTI array, as in
%      SYS(:,:,end+1) = RHS,
%   make sure SYS exists first.
%
%   See also SUBSREF, SUBSASGN.

%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/10 05:51:04 $

sizes = size(sys);
if position==numindices & position>=3 & position<length(sizes)
   % Case where END is in last position: return absolute
   % index except when POSITION is an I/O dimension
   index = prod(sizes(position:end)); % collapse LTI array dims
else
   sizes = [sizes 1]; % '1' allows trailing singleton dims
   index = sizes(min(position,end));
end