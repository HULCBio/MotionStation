function setset( h, propName, propValue )
%SETSET Do a SET on Handle Graphics object or a SET_PARAM on Simulink object.
%   SETSET(H, NAME, VALUE ) SET/SET_PARAM property pair on HG and/or SL objects H.
%   SETSET(N, NAME, VALUE ) SET_PARAM property pair on Simulink object named N.
%   For Simulink models it ignores Lock settings.
%
%    See also SET, SET_PARAM.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 17:09:23 $

if isempty(h)
    return
end

if isstr(h)
    h = get_param(h,'handle');
end

ish = ishghandle(h);
hg = h(ish);
issl = isslhandle(h);
sl = h(issl);

if ~isempty(hg)
    if iscell(propValue)
        %Vectorize SET not used because propValue may vary per object
        values = propValue( logical(ish) );
        if length(hg) ~= length(values)
            error( 'Inconsistent number of objects and property values.' )
        end
        for i = 1:length(hg)
            set( hg(i), propName, values{i} )
        end
    else
        set( hg, propName, propValue )
    end
end

if ~isempty(sl)
    %Set_param can not be vectorized because of the Lock issue.
    if iscell(propValue)
        values = propValue( logical(issl) );
    end
    for i = 1:length(sl)
       %If the block is a linked system, reassign the block so that
       %we are actually setting the block's reference system
       if ~strcmp(get_param(sl(i),'type'),'block_diagram')
          if strcmp(get_param(sl(i),'LinkStatus'),'resolved')
             sl(i) = get_param(get_param (sl(i),'ReferenceBlock'),'Handle');
          end
       end
       
       r = bdroot( sl(i) );
       
       LockSetting = get_param(r, 'Lock');
       DirtySetting = get_param(r,'Dirty');
       
       set_param( r , 'Lock', 'off');
       
       if iscell(propValue)
          set_param( sl(i), propName, values{i} );
       else
          set_param( sl(i), propName, propValue );
       end
       
       set_param( r, ...
          'Lock' , LockSetting,...
          'Dirty', DirtySetting);
    end
 end
