function [out1, out2] = mfdrag(action,lineHndl,mfType,mfParam)
% MFDRAG Interactive changes of membership functions by clicking and dragging.
%   It is called from mfedit.m where action is 'mf' and lineHndl is the current
%   selected membership function.  MFDRAG allows clicking and dragging of 
%   membership functions to change their shapes. In general, clicking on a 
%   membership function curve translates the whole curve; clicking on square 
%   control points changes the shape.
%
%       File name: mfdrag.m
%
%       See also DSIGMF, GAUSSMF, GAUSS2MF, GBELLMF, EVALMF, PIMF, PSIGMF,
%       SIGMF, SMF, TRAPMF, TRIMF, and ZMF.

%       Roger Jang, 6-28-95, Kelly Liu 3-12-97, Rajiv Singh 03/29/2002
%       Copyright 1994-2003 The MathWorks, Inc.
% $Revision: 1.19.4.3 $ $Date: 2004/04/10 23:15:30 $
selectColor = [1 0 0];
f = findobj(allchild(0),'type','figure','tag','mfedit');
switch action
case 'mf',
    lineH=lineHndl;
    set(lineH, 'Color', 'red');
    x = get(lineH, 'xdata');
    mf_type = mfType;
    mf_param = mfParam;
    new_mf = evalmf(x, mf_param, mf_type); 
    set(lineH, 'ydata', new_mf, 'color', 'red');
    % setting control points and mouse actions
    feval(mfilename, 'set_control_point', lineH, mf_type, mf_param);
    
case 'get_current_mf',
    mf_type = str2mat('trimf', 'trapmf', 'gbellmf', 'gaussmf', 'gauss2mf',...
        'sigmf', 'dsigmf',  'psigmf', 'pimf',...
        'smf', 'zmf');
    mf_type = str2mat(mf_type);
    
    %       mf_param_n = [3 4 2 2 3 2 2 4 4 4 4];
    which_mf = get(findobj(f, 'tag', 'mftype'), 'value');
    out1 = mf_type(which_mf, :);
    out2=[];
    
case 'set_control_point',
    % delete all possible previous control points
    delete(findobj(f, 'tag', 'leftlow'));
    delete(findobj(f, 'tag', 'lefthigh'));
    delete(findobj(f, 'tag', 'center'));
    delete(findobj(f, 'tag', 'righthigh'));
    delete(findobj(f, 'tag', 'rightlow'));
    % find MF types and parameters
    mf_type = mfType;
    mf_param = mfParam;
    square = local_get_control_square;
    controlcolor='black';
    if strcmp(mf_type, 'trimf'),
        leftlowH = line(mf_param(1)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        centerH = line(mf_param(2)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'center');
        rightlowH = line(mf_param(3)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
    elseif strcmp(mf_type, 'trapmf') | strcmp(mf_type, 'pimf'),
        leftlowH = line(mf_param(1)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        lefthighH = line(mf_param(2)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'lefthigh');
        righthighH = line(mf_param(3)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
        rightlowH = line(mf_param(4)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
    elseif strcmp(mf_type, 'gaussmf'),
        sigma = mf_param(1);
        c = mf_param(2);
        height = 0.5;
        x_left = c - sigma*sqrt(-2*log(height));
        x_right = c + sigma*sqrt(-2*log(height));
        leftlowH = line(x_left+real(square), height+imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        rightlowH = line(x_right+real(square), height+imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
    elseif strcmp(mf_type, 'gauss2mf'),
        s1 = mf_param(1); c1 = mf_param(2);
        s2 = mf_param(3); c2 = mf_param(4);
        height = 0.5;
        x_left = c1 - s1*sqrt(-2*log(height));
        x_right = c2 + s2*sqrt(-2*log(height));
        leftlowH = line(x_left+real(square), height+imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        rightlowH = line(x_right+real(square), height+imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
        lefthighH = line(mf_param(2)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'lefthigh');
        righthighH = line(mf_param(4)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
    elseif strcmp(mf_type, 'sigmf'),
        a = mf_param(1);
        c = mf_param(2);
        height = 0.1;
        leftlowH = line(c-log(1/height-1)/a + real(square), ...
            height + imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        righthighH = line(c-log(1/(1-height)-1)/a + real(square), ...
            1-height + imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
    elseif strcmp(mf_type, 'gbellmf'),
        a = mf_param(1); b = mf_param(2); c = mf_param(3);
        height = 0.9;
        leftlowH = line(c-a+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        rightlowH = line(c+a+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
        lefthighH = line(c-a*(1/height-1)^(1/(2*b))+real(square), ...
            height+imag(square), 'color', controlcolor, 'tag', 'lefthigh');
        righthighH = line(c+a*(1/height-1)^(1/(2*b))+real(square), ...
            height+imag(square), 'color', controlcolor, 'tag', 'righthigh');
    elseif strcmp(mf_type, 'smf'),
        leftlowH = line(mf_param(1)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        righthighH = line(mf_param(2)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
    elseif strcmp(mf_type, 'zmf'),
        lefthighH = line(mf_param(1)+real(square), 1+imag(square), ...
            'color', controlcolor, 'tag', 'lefthigh');
        rightlowH = line(mf_param(2)+real(square), imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
    elseif strcmp(mf_type, 'psigmf'),
        a1=mf_param(1); c1=mf_param(2); a2=mf_param(3); c2=mf_param(4);
        height = 0.9;
        leftlowH = line(c1+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        rightlowH = line(c2+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
        lefthighH = line(c1-log(1/height-1)/a1+real(square), ...
            height+imag(square), ...
            'color', controlcolor, 'tag', 'lefthigh');
        righthighH = line(c2-log(1/height-1)/a2+real(square), ...
            height+imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
    elseif strcmp(mf_type, 'dsigmf'),
        a1=mf_param(1); c1=mf_param(2); a2=mf_param(3); c2=mf_param(4);
        height = 0.9;
        leftlowH = line(c1+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'leftlow');
        rightlowH = line(c2+real(square), 0.5+imag(square), ...
            'color', controlcolor, 'tag', 'rightlow');
        lefthighH = line(c1-log(1/height-1)/a1+real(square), ...
            height+imag(square), ...
            'color', controlcolor, 'tag', 'lefthigh');
        righthighH = line(c2+log(1/height-1)/a2+real(square), ...
            height+imag(square), ...
            'color', controlcolor, 'tag', 'righthigh');
    else
        msgStr='not a default mf type';
        statHndl=findobj(f, 'Tag', 'status');
        set(statHndl, 'String', msgStr);
        return
        %          fprintf('mf_type = %s\n', mf_type);
        %          error('Unknown MF type!');
    end
    
    % set mouse button-down function
    
    set(f,'WindowButtonDownFcn',@localButtonDownFcn);
    
case 'info',
    helpwin(mfilename);
end

%--------------------------------------------------------------------------
function localButtonDownFcn(eventSrc,eventData)
% local function for mouse button down action
%f = findobj(allchild(0),'type','figure','tag','mfedit');
f = eventSrc;

userparam=get(gca, 'Userdata');
if ~isstruct(userparam)
    return
end
curr_info = get(gca, 'CurrentPoint');
leftlowH = findobj(f, 'tag', 'leftlow');
lefthighH = findobj(f, 'tag', 'lefthigh');
centerH = findobj(f, 'tag', 'center');
righthighH = findobj(f, 'tag', 'righthigh');
rightlowH = findobj(f, 'tag', 'rightlow');
lineH = findobj(f, 'tag', 'mfline', 'Userdata', userparam.CurrMF);
allH = [leftlowH lefthighH centerH righthighH rightlowH lineH];
set(allH, 'erasemode', 'xor');
% test if inside control squares
for i = 1:length(allH)-1,
    
    set(allH(i), 'userdata', ...
        inside(curr_info(1,1)+j*curr_info(1,2), ...
        get(allH(i),'xdata')'+j*get(allH(i),'ydata')'));
end
% test if clicking on the line
if isequal(gco,lineH),
    param = eval(get(findobj(f, 'tag', 'mfparams'), 'string'));
    set(findobj(f, 'tag', 'mfparams'), 'userdata', [curr_info(1,1) param]);
end

% store the current state and set the button motion function
fishist = get(f, 'Userdata');
fis = fishist{1}; % current fis
set(f,'WindowButtonUpFcn',{@localButtonUpFcn,fis},'WindowButtonMotionFcn',@localButtonMotionFcn);


%--------------------------------------------------------------------------
function localButtonMotionFcn(eventSrc,eventData)
% local function for mouse button motion action

selectColor = [1 0 0];
curr_info = get(gca, 'CurrentPoint');

%f = findobj(allchild(0),'type','figure','tag','mfedit');
f = eventSrc;

leftlowH = findobj(f, 'tag', 'leftlow');
rightlowH = findobj(f, 'tag', 'rightlow');
lefthighH = findobj(f, 'tag', 'lefthigh');
righthighH = findobj(f, 'tag', 'righthigh');
centerH = findobj(f, 'tag', 'center');
mainAxes = findobj(f, 'Tag','mainaxes');

paramLine = get(mainAxes, 'UserData');
lineH = findobj(f, 'tag', 'mfline', 'UserData', paramLine.CurrMF);
if ~isempty(lineH)
    
    mf_type = deblank(feval(mfilename, 'get_current_mf'));
    square = local_get_control_square;
    
    paramH = findobj(f, 'tag', 'mfparams');
    x = get(lineH, 'xdata');
    
    mf_type = deblank(feval(mfilename, 'get_current_mf'));
    
    paramstr=get(paramH, 'string');
    if ~isempty(deblank(paramstr))
        param = eval(paramstr);
    else
        param=[];
    end
    
    % Is the current variable input or output?
    currVarAxes=findobj(f,'Type','axes','XColor',selectColor);
    varIndex=get(currVarAxes,'UserData');
    varType=get(currVarAxes,'Tag');
    oldfis=get(f, 'Userdata');
    fis=oldfis{1};
    if strcmp(mf_type, 'trimf'),
        if  get(leftlowH, 'userdata') & curr_info(1,1) <= param(2),
            param(1) = curr_info(1,1);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', real(square) + curr_info(1));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(centerH, 'userdata') & ...
                param(1) <= curr_info(1,1) & curr_info(1,1) <= param(3),
            param(2) = curr_info(1,1);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(centerH, 'xdata', real(square) + curr_info(1));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(rightlowH, 'userdata') & param(2) <= curr_info(1,1),
            param(3) = curr_info(1,1);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(rightlowH, 'xdata', real(square) + curr_info(1,1));
            set(paramH, 'string', mat2str(param, 3));
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            param = curr_info(1,1) - tmp(1) + tmp(2:length(tmp));
            y=evalmf(x, param, mf_type);
            set(lineH, 'ydata', y);
            set(leftlowH, 'xdata', real(square) + param(1));
            set(centerH, 'xdata', real(square) + param(2));
            set(rightlowH, 'xdata', real(square) + param(3));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'trapmf') | strcmp(mf_type, 'pimf'),
        %curr_info
         %   param
        if get(leftlowH, 'userdata'),
            if curr_info(1,1) <= param(2),
                param(1) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(leftlowH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(rightlowH, 'userdata'),
            if curr_info(1,1) >= param(3),
                param(4) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(rightlowH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(lefthighH, 'userdata'),
            if (curr_info(1,1) >= param(1)) && ((curr_info(1,1) < param(3)-sqrt(eps)))
                param(2) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(lefthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(righthighH, 'userdata'),
            if (curr_info(1,1) <= param(4)) && ((curr_info(1,1) > sqrt(eps)+param(2)))
                param(3) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(righthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            param = curr_info(1,1) - tmp(1) + tmp(2:length(tmp));
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', real(square) + param(1));
            set(lefthighH, 'xdata', real(square) + param(2));
            set(righthighH, 'xdata', real(square) + param(3));
            set(rightlowH, 'xdata', real(square) + param(4));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'gaussmf'),
        sigma = param(1); c = param(2);
        height = 0.5;
        if get(leftlowH, 'userdata'),
            if curr_info(1,1) < c,
                param(1) = (c-curr_info(1,1))/sqrt(-2*log(height));
                sigma = param(1); c = param(2);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(leftlowH,'xdata', real(square)+curr_info(1,1));
                set(rightlowH,'xdata', real(square)+2*c-curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(rightlowH, 'userdata'),
            if curr_info(1,1) > c,
                param(1) = (curr_info(1,1)-c)/sqrt(-2*log(height));
                sigma = param(1); c = param(2);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(rightlowH,'xdata', real(square)+curr_info(1,1));
                set(leftlowH,'xdata', real(square)+2*c-curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            param(2) = curr_info(1,1) - tmp(1) + tmp(3);
            sigma = param(1); c = param(2);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', real(square) + ...
                c-sigma*sqrt(-2*log(height)));
            set(rightlowH, 'xdata', real(square) + ...
                c+sigma*sqrt(-2*log(height)));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'gauss2mf'),
        s1=param(1); c1=param(2); s2=param(3); c2=param(4);
        height = 0.5;
        if get(leftlowH, 'userdata'),
            spread = param(1)*sqrt(-2*log(height));
            param(2) = curr_info(1,1)+spread;
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(lefthighH,'xdata', real(square)+param(2));
            set(leftlowH,'xdata', param(2)-spread+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(rightlowH, 'userdata'),
            spread = param(3)*sqrt(-2*log(height));
            param(4) = curr_info(1,1)-spread;
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(righthighH,'xdata', real(square)+param(4));
            set(rightlowH,'xdata', param(4)+spread+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(lefthighH, 'userdata'),
            spread = curr_info(1,1)-(c1-s1*sqrt(-2*log(height)));
            if spread > 0,
                param(1) = spread/sqrt(-2*log(height));
                param(2) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(lefthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(righthighH, 'userdata'),
            spread = -(curr_info(1,1) - ...
                (c2+s2*sqrt(-2*log(height))));
            if spread > 0,
                param(3) = spread/sqrt(-2*log(height));
                param(4) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(righthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'userdata');
            %    tmp = str2mat(tmpstr);
            %   tmp = get(lineH, 'userdata');
            param(2) = curr_info(1,1) - tmp(1) + tmp(3);
            param(4) = curr_info(1,1) - tmp(1) + tmp(5);
            s1=param(1); c1=param(2); s2=param(3); c2=param(4);
            height = 0.5;
            x_left = c1 - s1*sqrt(-2*log(height));
            x_right = c2 + s2*sqrt(-2*log(height));
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', x_left+real(square));
            set(rightlowH, 'xdata', x_right+real(square));
            set(lefthighH, 'xdata',  param(2)+real(square));
            set(righthighH, 'xdata',  param(4)+real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'sigmf'),
        a = param(1); c = param(2);
        height = 0.1;
        if get(leftlowH, 'userdata'),
            if curr_info(1,1) == c,
                param(1) = realmax;
            else
                param(1) = -log(1/height-1)/(curr_info(1,1)-c);
            end
            a = param(1); c = param(2);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH,'xdata',real(square)+curr_info(1,1));
            set(righthighH,'xdata',real(square)+2*c-curr_info(1,1));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(righthighH, 'userdata'),
            if curr_info(1,1) == c,
                param(1) = realmax;
            else
                param(1) = -log(1/(1-height)-1)/(curr_info(1,1)-c);
            end
            a = param(1); c = param(2);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(righthighH, 'xdata', real(square)+curr_info(1,1));
            set(leftlowH, 'xdata', real(square)+2*c-curr_info(1,1));
            set(paramH, 'string', mat2str(param, 3));
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            %   tmp = str2mat(tmpstr);
            %   tmp = get(lineH, 'userdata');
            param(2) = curr_info(1,1) - tmp(1) + tmp(3);
            a = param(1); c = param(2);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', ...
                c-log(1/height-1)/a + real(square));
            set(righthighH, 'xdata', ...
                c-log(1/(1-height)-1)/a + real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'gbellmf'),
        height = 0.9;
        if get(leftlowH, 'userdata'),
            if curr_info(1,1) < param(3),
                param(1) = param(3)-curr_info(1,1);
                a = param(1); b = param(2); c = param(3);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(leftlowH, 'xdata', curr_info(1,1)+real(square));
                set(rightlowH, 'xdata',2*c-curr_info(1,1)+real(square));
                set(lefthighH, 'xdata', ...
                    c-a*(1/height-1)^(1/(2*b))+real(square));
                set(righthighH, 'xdata', ...
                    c+a*(1/height-1)^(1/(2*b))+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(rightlowH, 'userdata'),
            if curr_info(1,1) > param(3),
                param(1) = curr_info(1,1)-param(3);
                a = param(1); b = param(2); c = param(3);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(rightlowH, 'xdata', curr_info(1,1)+real(square));
                set(leftlowH, 'xdata', 2*c-curr_info(1,1)+real(square));
                set(lefthighH, 'xdata', ...
                    c-a*(1/height-1)^(1/(2*b))+real(square));
                set(righthighH, 'xdata', ...
                    c+a*(1/height-1)^(1/(2*b))+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(lefthighH, 'userdata'),
            tmp = abs((curr_info(1,1)-param(3))/param(1));
            if tmp == 0,
                param(2) = eps;
            elseif tmp == 1,
                param(2) = realmax;
            else
                param(2) = log(1/height-1)/(2*log(tmp));
            end
            a = param(1); b = param(2); c = param(3);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(lefthighH, 'xdata', curr_info(1,1)+real(square));
            set(righthighH, 'xdata', 2*c-curr_info(1,1)+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(righthighH, 'userdata'),
            tmp = abs((curr_info(1,1)-param(3))/param(1));
            if tmp == 0,
                param(2) = eps;
            elseif tmp == 1,
                param(2) = realmax;
            else
                param(2) = log(1/height-1)/(2*log(tmp));
            end
            a = param(1); b = param(2); c = param(3);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(righthighH, 'xdata', curr_info(1,1)+real(square));
            set(lefthighH, 'xdata', 2*c-curr_info(1,1)+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            %   tmp = str2mat(tmpstr);
            %   tmp = get(lineH, 'userdata');
            param(3) = curr_info(1,1) - tmp(1) + tmp(4);
            a = param(1); b = param(2); c = param(3);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', c-a+real(square));
            set(rightlowH, 'xdata', c+a+real(square));
            set(lefthighH, 'xdata', ...
                c-a*(1/height-1)^(1/(2*b)) + real(square));
            set(righthighH, 'xdata', ...
                c+a*(1/height-1)^(1/(2*b)) + real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'smf'),
        if get(leftlowH, 'userdata'),
            if curr_info(1,1) <= param(2),
                param(1) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(leftlowH, 'xdata', curr_info(1,1)+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(righthighH, 'userdata'),
            if curr_info(1,1) >= param(1),
                param(2) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(righthighH, 'xdata', curr_info(1,1)+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            % tmp = str2mat(tmpstr);
            % tmp = get(lineH, 'userdata');
            param = curr_info(1,1) - tmp(1) + tmp(2:3);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', param(1)+real(square));
            set(righthighH, 'xdata', param(2)+real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'zmf'),
        if get(lefthighH, 'userdata'),
            if curr_info(1,1) <= param(2),
                param(1) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(lefthighH, 'xdata', curr_info(1,1)+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(rightlowH, 'userdata'),
            if curr_info(1,1) >= param(1),
                param(2) = curr_info(1,1);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(rightlowH, 'xdata', curr_info(1,1)+real(square));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            %     tmp = str2mat(tmpstr);
            %     tmp = get(lineH, 'userdata');
            param = curr_info(1,1) - tmp(1) + tmp(2:3);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(lefthighH, 'xdata', param(1)+real(square));
            set(rightlowH, 'xdata', param(2)+real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'psigmf'),
        height = 0.9;
        if get(leftlowH, 'userdata'),
            param(2) = curr_info(1,1);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', curr_info(1,1)+real(square));
            set(lefthighH, 'xdata',c1-log(1/height-1)/a1+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(rightlowH, 'userdata'),
            param(4) = curr_info(1,1);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(rightlowH, 'xdata', curr_info(1,1)+real(square));
            set(righthighH, 'xdata',c2-log(1/height-1)/a2+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(lefthighH, 'userdata'),
            %if curr_info(1,1) == param(2),
            %       param(1) = realmax;
            %else
            %       param(1) = -log(1/height-1)/(curr_info(1,1)-param(2));
            %end
            if curr_info(1,1) > param(2),
                param(1) = -log(1/height-1)/(curr_info(1,1)-param(2));
                a = param(1); c = param(2);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(lefthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif get(righthighH, 'userdata'),
            %if curr_info(1,1) == param(4),
            %       param(3) = realmax;
            %else
            %       param(3) = -log(1/height-1)/(curr_info(1,1)-param(4));
            %end
            if curr_info(1,1) < param(4),
                param(3) = -log(1/height-1)/(curr_info(1,1)-param(4));
                a = param(3); c = param(4);
                set(lineH, 'ydata', evalmf(x, param, mf_type));
                set(righthighH, 'xdata', real(square)+curr_info(1,1));
                set(paramH, 'string', mat2str(param, 3));
            end
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            param(2) = curr_info(1,1) - tmp(1) + tmp(3);
            param(4) = curr_info(1,1) - tmp(1) + tmp(5);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', c1+real(square));
            set(rightlowH, 'xdata', c2+real(square));
            set(lefthighH, 'xdata', ...
                c1-log(1/height-1)/a1+real(square));
            set(righthighH, 'xdata', ...
                c2-log(1/height-1)/a2+real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    elseif strcmp(mf_type, 'dsigmf'),
        height = 0.9;
        if get(leftlowH, 'userdata'),
            param(2) = curr_info(1,1);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', curr_info(1,1)+real(square));
            set(lefthighH, 'xdata',c1-log(1/height-1)/a1+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(rightlowH, 'userdata'),
            param(4) = curr_info(1,1);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(rightlowH, 'xdata', curr_info(1,1)+real(square));
            set(righthighH, 'xdata',c2+log(1/height-1)/a2+real(square));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(lefthighH, 'userdata'),
            if curr_info(1,1) == param(2),
                param(1) = realmax;
            else
                param(1) = -log(1/height-1)/(curr_info(1,1)-param(2));
            end
            a = param(1); c = param(2);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(lefthighH, 'xdata', real(square)+curr_info(1,1));
            set(paramH, 'string', mat2str(param, 3));
        elseif get(righthighH, 'userdata'),
            if curr_info(1,1) == param(4),
                param(3) = realmax;
            else
                param(3) = log(1/height-1)/(curr_info(1,1)-param(4));
            end
            a = param(3); c = param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(righthighH, 'xdata', real(square)+curr_info(1,1));
            set(paramH, 'string', mat2str(param, 3));
        elseif gco == lineH,
            paramHndl = findobj(f, 'Tag', 'mfparams');
            tmp = get(paramHndl, 'Userdata');
            param(2) = curr_info(1,1) - tmp(1) + tmp(3);
            param(4) = curr_info(1,1) - tmp(1) + tmp(5);
            a1=param(1); c1=param(2); a2=param(3); c2=param(4);
            set(lineH, 'ydata', evalmf(x, param, mf_type));
            set(leftlowH, 'xdata', c1+real(square));
            set(rightlowH, 'xdata', c2+real(square));
            set(lefthighH, 'xdata', ...
                c1-log(1/height-1)/a1+real(square));
            set(righthighH, 'xdata', ...
                c2+log(1/height-1)/a2+real(square));
            set(paramH, 'string', mat2str(param, 3));
        end
    else
        error('Unknown MF type!');
    end
    %      y=evalmf(x, param, mf_type);
    %      centerIndex=find(y==max(y));
    %      centerIndex=round(mean(centerIndex));
    %      textHndl=findobj(gcf, 'Tag', 'mftext', 'Userdata', paramLine.CurrMF);
    %      set(textHndl, 'Position', [x(centerIndex), 1.1, 0]);
    
    fis.(varType)(varIndex).mf(paramLine.CurrMF).params = param;
    
    % update the most recent state.
    oldfis{1} = fis;
    set(f, 'Userdata', oldfis);
end

%---------------------------------------------------------
function localButtonUpFcn(eventSrc,eventData,storedfis)
% local function for mouse button up action

%f = findobj(allchild(0),'type','figure','tag','mfedit');
f = eventSrc;

leftlowH = findobj(f, 'tag', 'leftlow');
lefthighH = findobj(f, 'tag', 'lefthigh');
centerH = findobj(f, 'tag', 'center');
righthighH = findobj(f, 'tag', 'righthigh');
rightlowH = findobj(f, 'tag', 'rightlow');
lineH = findobj(f, 'tag', 'mfline');
allH = [leftlowH lefthighH centerH righthighH rightlowH];  % lineH'];
set(allH, 'erasemode', 'normal', 'userdata', []);
oldfis = get(f, 'Userdata');
currentfis = oldfis{1};
if ~isequalwithequalnans(currentfis,storedfis) % REVISIT: isequalwithequalnans 
    oldfis{1} = storedfis;
    set(f, 'Userdata',oldfis);
    pushundo(f,currentfis);
    updtfis(f,currentfis,[4 5 6]);
end
param=get(findobj(f, 'Tag', 'mainaxes'), 'Userdata');
textHndl=findobj(f, 'Tag', 'mftext', 'Userdata', param.CurrMF);
lineHndl=findobj(f, 'Tag', 'mfline', 'Userdata', param.CurrMF);
if ~isempty(lineHndl)
    y=get(lineHndl, 'Ydata');
    x=get(lineHndl, 'Xdata');
    centerIndex=find(y==max(y));
    centerIndex=round(mean(centerIndex));
    set(textHndl, 'Position', [x(centerIndex), 1.1, 0]);
end
set(f,'WindowButtonMotionFcn','');

%--------------------------------------------------------------------------
function out = local_get_control_square
% create a perfect square

set(gca, 'unit', 'pixel');
axes_pos = get(gca, 'pos'); w = axes_pos(3); h = axes_pos(4);
out = 0.02*([-1 1 1 -1 -1]*h/w*...
    (max(get(gca, 'xlim'))- min(get(gca, 'xlim')))/...
    (max(get(gca, 'ylim'))- min(get(gca, 'ylim'))) +...
    sqrt(-1)*[-1 -1 1 1 -1]);
set(gca, 'unit', 'normalize');
