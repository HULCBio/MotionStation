function varargout = get(t,varargin)
%GET Get NTREE object field contents.
%   [FieldValue1,FieldValue2, ...] = ...
%       GET(T,'FieldName1','FieldName2', ...) returns
%   the contents of the specified fields for the NTREE
%   object T.
%
%   [...] = GET(T) returns all the field contents of T.
%
%   The valid choices for 'FieldName' are:
%     'wtbo'  : wtbo parent object
%     'order' : Order of tree
%     'depth' : Depth of tree
%     'spsch' : Split scheme for nodes
%     'tn'    : Array of terminal nodes of tree
%
%   Or fields in WTBO parent object:
%     'wtboInfo' : Object information
%     'ud'       : Userdata field
%
%   Examples:
%     t = ntree(3,2);
%     o = get(t,'order');
%     [o,tn] = get(t,'order','tn');
%
%   See also DISP, SET.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Aug-2000.
%   Last Revision: 18-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/03/15 22:38:19 $

nbin = length(varargin);
if nbin==0 , varargout = struct2cell(struct(t))'; return; end
varargout = cell(nbin,1);
for k=1:nbin
    field = varargin{k};
    try
      varargout{k} = t.(field);
    catch
      lasterr('')
      varargout{k} = get(t.wtbo,field);
    end
end