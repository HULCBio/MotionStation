function t = set(t,varargin)
%SET Set NTREE object fields contents.
%   T = SET(T,'FieldName1',FieldValue1,'FieldName2',FieldValue2,...)
%   sets the contents of the specified fields for the NTREE object T.
%   
%   The valid choices for 'FieldName' are:
%     'wtbo'  : wtbo parent object
%     'order' : Order of tree
%     'depth' : Depth of tree
%     'spsch' : Split scheme for nodes
%     'tn'    : Array of terminal nodes of tree
%
%   Or fields in WTBO object:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Caution: Use the SET function only for the field 'ud'.
%
%   See also DISP, GET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Last Revision: 18-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/03/15 22:38:44 $

nbin = length(varargin);
for k=1:2:nbin
    field = varargin{k};
    try 
      t.(field) = varargin{k+1};
    catch
      lasterr('');
      t.wtbo = set(t.wtbo,field,varargin{k+1});
    end
end