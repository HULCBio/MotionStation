function st = close(varargin)
%CLOSE  Close figure.
%   CLOSE(H) closes the window with handle H.
%   CLOSE, by itself, closes the current figure window.
%
%   CLOSE('name') closes the named window.
%
%   CLOSE ALL  closes all the open figure windows.
%   CLOSE ALL HIDDEN  closes hidden windows as well.
%   
%   STATUS = CLOSE(...) returns 1 if the specified windows were closed
%   and 0 otherwise.
%
%   See also DELETE.

%   CLOSE ALL FORCE  unconditionally closes all windows by deleting them
%   without executing the close request function.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.42.4.1 $  $Date: 2002/09/26 01:54:20 $
%   J.N. Little 1-7-92

h = [];
closeAll = 0;
closeForce = 0;
closeHidden = 0;
status = 1;

if nargin == 0
    h = get(0,'CurrentFigure');
else
    % Input can be <handle>, '<handle>', 'force', and/or 'all' in any order
    for i=1:nargin
        cur_arg = varargin{i};
        
        if isstr(cur_arg)
            switch lower(cur_arg)
             case 'force', 
              closeForce  = 1;
             case 'all',
              closeAll    = 1;
             case 'hidden',
              closeHidden = 1;
             case 'gcf',
              h = [h gcf];
             case 'gcbf',
              h = [h gcbf];
             otherwise
              %Find Figure with given name, or it is command style call
              hlist = findobj(get(0,'children'),'flat','name',cur_arg);
              if ~isempty(hlist)
                  h = [h hlist];
              else
                  num = str2double(cur_arg);
                  if ~isnan(num)
                      h = [h num];
                  end
              end
            end
        else
            h = [h cur_arg];
            if isempty(h),  % make sure close([]) does nothing:
                if nargout==1, st = status; end
                return
            end 
        end
    end

    % If h is empty that this point, define it by context.
    if isempty(h)
        % If there were other args besides the special ones, error out 
        if (closeHidden + closeForce + closeAll) < nargin
            error('Specified window does not exist.');
        end
        if closeHidden | closeForce
            hhmode = get(0,'showhiddenhandles');
            set(0,'showhiddenhandles','on');
        end
        if closeAll
            h = findobj(get(0,'Children'), 'flat','type','figure');
            sfFigs = findobj(h, 'Tag', 'SFCHART');
            sfFigs = [sfFigs; findobj(h, 'Tag', 'DEFAULT_SFCHART')];
            sfFigs = [sfFigs; findobj(h, 'Tag', 'SFEXPLR')];
            sfFigs = [sfFigs; findobj(h, 'Tag', 'SF_DEBUGGER')];
            sfFigs = [sfFigs; findobj(h, 'Tag', 'SF_SAFEHOUSE')];
            sfFigs = [sfFigs; findobj(h, 'Tag', 'SF_SNR')];
            h = setdiff(h,sfFigs);
        else
            h = get(0,'CurrentFigure');
        end
        if closeHidden | closeForce
            set(0,'showhiddenhandles',hhmode)
        end
    end
end

if ~checkfigs(h), error('Invalid figure handle.'); end

if closeForce
    delete(h)
else
    status = request_close(h);
end

if nargout==1, st = status; end


%------------------------------------------------
function status = request_close(h)
persistent in_request_close;
status = 1;
numFig=length(h);
hhmode = get(0,'showhiddenhandles');
set(0,'showhiddenhandles','on')
waserr=0;
for lp = 1:numFig,
  if ishandle(h(lp))
    set(0,'CurrentFigure',h(lp));
    crf = get(h(lp),'CloseRequestFcn');
    % prevent recursion
    if (in_request_close)
        ws = warning('on');
        warning('A callback recursively calls CLOSE.  Use DELETE to prevent this message.')
        warning(ws);
        delete(h)
        in_request_close = 0;
    else
        try
            in_request_close = 1;
            if ischar(crf)
                eval(crf)
            elseif iscell(crf)
                % fcn pointer call backs are called like this
                %     fcn     obj   evd  other args      
                feval(crf{1}, h(lp), [], crf{2:end});
            elseif isa(crf,'function_handle')
                feval(crf, h(lp), [])
            end
            in_request_close = 0;
        catch
            in_request_close = 0;
            error(sprintf('Error while evaluating figure CloseRequestFcn\n\n%s', lasterr));
        end
    end
  end
  if ishandle(h(lp)), status = 0; end
end
set(0,'showhiddenhandles',hhmode);

%------------------------------------------------
function status = checkfigs(h)
status = 1;
for i=1:length(h)
  if ~ishandle(h(i)) | ~strcmp(get(h(i),'type'),'figure')
    status = 0;
    return
  end
end
