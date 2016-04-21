function str = fdobjhelp(module,tag,fig,h)
%FDOBJHELP Help for Filter Designer objects - similar to fdhelpstr but with
%  module input
% Inputs:
%   module - string identifying current module, one of
%      fdremez, fdkaiser, fdfirls, fdbutter, fdcheby1, fdcheby2
%   tag - string identifying the object clicked on
%   fig - figure handle of GUI
%   h - handle of the clicked object

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.8 $

    str{1,1} = 'Filter Designer';
    str{1,2} = {['common object (' tag ')']};

switch tag
case {'pb1' ,'pb2' ,'pb3' ,'sb1' ,'sb2','sb3' ,'pbm1' ,'pbm2' ,'pbm3' , ...
      'sbm1' ,'sbm2' ,'sbm3'}
      
    bandpop = filtdes('findobj','fdspec','tag','bandpop');
    bandStr = num2str(get(bandpop,'value'));
    minordcheckbox = filtdes('findobj','fdspec','tag','minordcheckbox');
    if get(minordcheckbox,'value')
        minStr = 'min';
    else
        minStr = 'set';
    end
    
    str = fdhelpstr([tag ':' module ':' minStr ':' bandStr]);

case {'passband','stopband'}
    bandpop = filtdes('findobj','fdspec','tag','bandpop');
    bandStr = num2str(get(bandpop,'value'));
    minordcheckbox = filtdes('findobj','fdspec','tag','minordcheckbox');
    if get(minordcheckbox,'value')
        minStr = 'min';
        tagStr = [tag ':' minStr];
    else
        minStr = 'set';
        tagStr = [tag ':' module ':' minStr];
    end
    
    str = fdhelpstr(tagStr);
    
case {'L3_1','L3_2'}
    bandpop = filtdes('findobj','fdspec','tag','bandpop');
    if get(bandpop,'value') > 2
        bandStr = 'two';  % are there two or one parameters lines visible?
    else
        bandStr = 'one';
    end
    minordcheckbox = filtdes('findobj','fdspec','tag','minordcheckbox');
    if get(minordcheckbox,'value')
        minStr = 'min';
    else
        minStr = 'set';
    end
    tagStr = [tag ':' module ':' bandStr];
    
    str = fdhelpstr(tagStr);

case 'bandpop'
    str = fdhelpstr('bandpop1');
    fdutil('showBandConfigWindow',fig,h)
    
case 'minordcheckbox'
    str = fdhelpstr('minordcheckbox1');
    fdutil('showBandConfigWindow',fig,h)

case {'passframe' ,'stopframe' ,'order' ,'bandpop',...
      'passframe1' ,'stopframe1' ,'order1' ,...
      'ax' ,'response'}
    str = fdhelpstr(tag);
    
otherwise
    % do nothing!
    str{1,2} = {['Not a common object (' tag ')']};

end

