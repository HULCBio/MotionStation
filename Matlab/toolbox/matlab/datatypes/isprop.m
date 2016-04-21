function valid = isprop(varargin)
%ISPROP Returns true if the property exists
%   ISPROP(H, PROP) Returns true if PROP is a property of H.  This function
%   tests for Handle objects and Handle Graphics objects.
%   ISPROP(PACKAGENAME, CLASSNAME, PROP) Returns true if PROP is a property of the class
%   CLASSNAME of package PACKAGENAME

%   Author(s): J. Schickler, G. DeLoid
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2004/04/10 23:25:27 $

% get lasterror information
[lastmsg, lastid] = lasterr;

if nargin == 2 && all(ishandle(varargin{1})) && ischar(varargin{2}) && isempty(regexp(varargin{2},'\W'))
    % check for property of hg or handle object instances
    for i = 1:length(varargin{1})
        try
            p=findprop(handle(varargin{1}(i)), varargin{2});
            if isempty(p) || ~strcmpi(p.Name,varargin{2})
                valid(i) = false;
            else
                valid(i) = true;
            end
        catch
            valid(i) = false;
            lasterr(lastmsg, lastid);
        end
    end
elseif nargin == 3 && ischar(varargin{1}) && ischar(varargin{2}) && ischar(varargin{3}) && isempty(regexp(varargin{3},'\W'))
    % check for property of class - package and class name provided
    try
        p=findprop(findclass(findpackage(varargin{1}),varargin{2}),varargin{3});
        if isempty(p) || ~strcmpi(p.Name,varargin{3})
            valid = false;
        else
            valid = true;
        end
    catch
        valid = false;
        lasterr(lastmsg, lastid);
    end
else
    valid=false;
end





