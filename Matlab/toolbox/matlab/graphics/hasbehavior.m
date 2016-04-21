function has=hasbehavior(varargin)
%HASBEHAVIOR sets(enables/disables) or gets behaviors of hg objects
%
% HASBEHAVIOR(h,behaviorname,truefalse) sets the behavior
% behaviorname for the hg object with handle h to truefalse (true or false).
% HAS=HASBEHAVIOR(h,behaviorname) returns the boolean value for the
% behavior behaviorname of h.  If the behavior has not been
% previously set for h, then 'on' is returned.
% It is the responsiblity of the behavior implementing
% functions(e.g. legend, zoom) to check for the state of the behavior.
%
%   Examples:
%       ax=axes;
%       l=plot(rand(3,3));
%       hasbehavior(ax,'zoom',false); % axes can not be zoomed
%       hasbehavior(l(1),'legend',false); % line will not be in legend
%       hasbehavior(l(2),'legend',true); % line will be in legend
%
%       axeszoomable = hasbehavior(ax,'zoom'); % gets zoom behavior
%       linelegendable = hasbehavior(l(1),'legend'); % gets legend behavior
 
%   G. DeLoid 06/18/2002
%
%   Copyright 1984-2003 The MathWorks, Inc.
%   $ $

if nargin<2
    error('MATLAB:HASBEHAVIOR:Not Enough Input Args');
    return;
elseif nargin==2
    if nargout>1
        error('MATLAB:HASBEHAVIOR:Too Many Output Args');
        return;
    else
        if ~ishandle(varargin{1})
            error('MATLAB:HASBEHAVIOR:First Arg Must Be A Valid Handle');
            return;
        elseif length(varargin{1})>1
            error('MATLAB:HASBEHAVIOR:First Arg Must Be A Single Handle');
            return;
        elseif ~ischar(varargin{2})
            error('MATLAB:HASBEHAVIOR:Second Arg Must Be A String');
            return;
        else % get the state of behavior for object varargin{1}
            % to reasonably ensure that the behavior names do not
            % confilict with other appdata, we append '_hgbehavior'
            % to the name given.
            behaviorname = [varargin{2},'_hgbehavior'];
            % if the appdata does not exist then the behavior is true
            if ~isappdata(varargin{1},behaviorname)
                has = true;
            elseif isequal(false,getappdata(varargin{1},behaviorname))
                has = false;
            else
                has = true;
            end
        end
    end
elseif nargin==3
    if nargout >0
        error('MATLAB:HASBEHAVIOR:Too Many Output Args');
        return;
    else
        if ~ishandle(varargin{1})
            error('MATLAB:HASBEHAVIOR:First Arg Must Be A Valid Handle');
            return;
        elseif length(varargin{1})>1
            error('MATLAB:HASBEHAVIOR:First Arg Must Be A Single Handle');
            return;
        elseif ~ischar(varargin{2})
            error('MATLAB:HASBEHAVIOR:Second Arg Must Be A String');
            return;
        elseif ~isnumeric(varargin{3}) && ~islogical(varargin{3})
            error('MATLAB:HASBEHAVIOR:Third Arg Must Be logical or numeric');
            return;
        else % set the behavior for object varargin{1} to varargin{3}
            % to reasonably ensure that the behavior names do not
            % confilict with other appdata, we append '_hgbehavior'
            % to the name given.
            behaviorname = [varargin{2},'_hgbehavior'];
            setappdata(varargin{1},behaviorname,varargin{3});
        end
    end    
else
    error('MATLAB:HASBEHAVIOR:Too Many Input Args');
    return;
end