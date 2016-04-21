function fcmdemo(action)
%FCMDEMO Fuzzy c-means clustering demo (2-D).
%   FCMDEMO displays a GUI window to let you try out various parameters
%   in fuzzy c-means clustering for 2-D data. You can choose the data set
%   and clustering number from the GUI buttons at right, and then click
%   "Start" to start the fuzzy clustering process.
%
%   Once the clustering is done, you can select one of the clusters by
%   mouse and view the MF surface by clicking the "MF Plot" button.
%   (Note that "MF Plot" is slow because MATLAB is using the command
%   "griddata" to do interpolation among all data points.) To get a
%   better viewing angle, click and drag inside the figure to rotate the
%   MF surface.
%
%   If you choose to use a customized data set, it must be 2-D data.
%   Moreover, the data set is normalized to within the unit cube
%   [0,1] X [0,1] before being clustered.
%
%   File name: fcmdemo.m
%
%   See also DISTFCM, INITFCM, IRISFCM, STEPFCM, FCM.

%   J.-S. Roger Jang, 12-12-94.
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.16.2.2 $  $Date: 2004/04/10 23:15:17 $

global FcmFigH FcmFigTitle FcmAxisH FcmCenter FcmU OldDataID

if nargin == 0,
    action = 'initialize';
end

if strcmp(action, 'initialize'),
    FcmFigTitle = '2-D Fuzzy C-Means Clustering';
    FcmFigH = findobj(0, 'Name', FcmFigTitle);
    if isempty(FcmFigH)
        eval([mfilename, '(''set_gui'')']);
        % ====== change to normalized units
                set(findobj(FcmFigH,'Units','pixels'),'Units','normal');
                % ====== make all UI interruptible
                set(findobj(FcmFigH,'Interrupt','off'),'Interrupt','on');
    else
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
    end
elseif strcmp(action, 'set_gui'),   % set figure, axes and gui's
    % ====== setting figure
    FcmFigH = figure('Name', FcmFigTitle, 'NumberTitle', 'off','DockControls','off');
%%  set(0, 'Currentobject', FcmFigH);
    % set V4 default color
    colordef(FcmFigH, 'black');
    figPos = get(FcmFigH, 'position');
    % ====== setting axes
    border = 30;
    axes_pos = [border border figPos(4)-2*border figPos(4)-2*border];
    FcmAxisH = axes('unit', 'pix', 'pos', axes_pos, 'box', 'on');
    %axis([-inf inf -inf inf]); % fit axis to data
    axis([0 1 0 1]);
    axis square;
    set(FcmAxisH, 'xtick', [], 'ytick', []);
    % ====== setting gui buttons
    % ============ background gui frame
    border = 10;
    ui_usable_pos = [figPos(4) 0 figPos(3)-figPos(4) figPos(4)];
    [frameH, tmp] = uiarray(ui_usable_pos, 1, 1, border, 0, 'text');
    ui_frame_pos = [tmp(1)-border, tmp(2), tmp(3)+border, tmp(4)];
    set(frameH, 'position', ui_frame_pos);
    set(frameH, 'backgroundcolor', [0.5 0.5 0.5]);
    tmp1 = str2mat('popup', 'popup', 'radio', 'push', 'push', 'push');
    tmp2 = str2mat('text', 'text', 'text');
    tmp3 = str2mat('push', 'push');
    style = str2mat(tmp1, tmp2, tmp3);
    [uiH, uiPos] = uiarray(ui_frame_pos, size(style,1), 1, 5, 5,style);
    % ============ background gui frame
    bgc = [0.5 0.5 0.5];
    fgtc = [1 1 1];
    % ============ data set
    set(uiH(1), 'string', ...
        'Data Set 1|Data Set 2|Data Set 3|Data Set 4|Data Set 5|Custom ...');
    set(uiH(1), 'callback', ...
        [mfilename, '(''get_data''); ', ...
         mfilename, '(''init_U''); ', ...
         mfilename, '(''label_data0''); ', ...
         mfilename, '(''display_data'');']);
    set(uiH(1), 'tag', 'data_set');
    % ============ cluster number
    set(uiH(2), 'string', '2 Clusters|3 Clusters|4 Clusters|5 Clusters|6 Clusters|7 Clusters|8 Clusters|9 Clusters|10 Clusters');
    set(uiH(2), 'callback', [mfilename, '(''cluster_number'');']);
    set(uiH(2), 'tag', 'cluster_number');
    % ============ label cluster
    set(uiH(3), 'string','Label Data', 'tag', 'label_data');
    set(uiH(3), 'callback', [mfilename, '(''label_data'')']);
    % ============ clear trajectory
    set(uiH(4), 'string', 'Clear Traj.', 'tag', 'clear_traj');
    set(uiH(4), 'callback', [mfilename, '(''clear_traj'')']);
    % ============ clear center
    set(uiH(5), 'string', 'MF Plot', 'tag', 'mf_plot');
    set(uiH(5), 'callback', [mfilename, '(''mf_plot'')']);
    % ============ start & stop
    set(uiH(6), 'string','Start');
    set(uiH(6), 'tag', 'start');
    set(uiH(6), 'callback', [mfilename, '(''start_stop'')']);
    % ============ exponential
    delete(uiH(7));
    tmpH = uiarray(uiPos(7,:), 1, 2, 0, 0, str2mat('text', 'edit'));
    set(tmpH(1), 'string','Expo.:', 'back', bgc, 'fore', fgtc);
    set(tmpH(2), 'background', fgtc, 'string', '2');
    set(tmpH(2), 'tag', 'exponent');
    set(tmpH(2), 'callback', [mfilename, '(''exponent'')']);
    % ============ max iteration
    delete(uiH(8));
    tmpH = uiarray(uiPos(8,:), 1, 2, 0, 0, str2mat('text', 'edit'));
    set(tmpH(1), 'string','Iterat.:', 'back', bgc, 'fore', fgtc);
    set(tmpH(2), 'background', fgtc, 'string', '100');
    set(tmpH(2), 'tag', 'max_iter');
    % ============ epsilson
    delete(uiH(9));
    tmpH = uiarray(uiPos(9,:), 1, 2, 0, 0, str2mat('text', 'edit'));
    set(tmpH(1), 'string','Improv.:', 'back', bgc, 'fore', fgtc);
    set(tmpH(2), 'background', fgtc, 'string', '1e-5');
    set(tmpH(2), 'tag', 'min_impro');
    % ============ info
    set(uiH(10), 'string','Help');
    set(uiH(10), 'tag', 'info');
    set(uiH(10), 'callback', [mfilename, '(''info'')']);
    % ============ close
    set(uiH(11), 'string','Close');
    set(uiH(11), 'tag', 'close');
    set(uiH(11), 'callback', [mfilename, '(''close'')']);

    % setting initial values for GUI. 
    % ============ initial settings for data set
    OldDataID = 2;
    set(findobj(FcmFigH, 'tag', 'data_set'), 'value', OldDataID);
    % ============ initial settings for cluster number 
    set(findobj(FcmFigH, 'tag', 'cluster_number'), 'value', 2);
    % ============ initial settings for labeling data 
    label_data = 0;
    set(findobj(FcmFigH, 'tag', 'label_data'), 'value', label_data);
    % ============ initial settings for exponent 
    exponent = 2.0;
    set(findobj(FcmFigH, 'tag', 'exponent'), 'string', num2str(exponent));
    % ============ initial settings for max_iter 
    max_iter = 100;
    set(findobj(FcmFigH, 'tag', 'max_iter'), 'string', num2str(max_iter));
    % ============ initial settings for min_impro 
    min_impro = 1e-5;
    set(findobj(FcmFigH, 'tag', 'min_impro'), 'string', num2str(min_impro));
    % ============ GUI initial operations
    eval([mfilename, '(''get_data'')']);
    eval([mfilename, '(''init_U'')']);
    eval([mfilename, '(''label_data0'')']);
    eval([mfilename, '(''display_data'')']);
    eval([mfilename, '(''set_mouse_action'')']);

    % ============ set user data
    set(FcmFigH, 'userdata', uiH);
elseif strcmp(action, 'start_stop'),
    if ~isempty(findobj(FcmFigH, 'string', 'Start')), 
        eval([mfilename, '(''start_clustering'')']);
    else    % stop clustering
        set(findobj(FcmFigH, 'tag', 'start'), 'string', 'Start');
    end
elseif strcmp(action, 'start_clustering'),
    % === set some buttons to be uninterruptible
    % The following does not work
    %set(findobj(FcmFigH, 'tag', 'data_set'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'cluster_number'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'clear_traj'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'mf_plot'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'exponent'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'max_iter'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'min_impro'), 'interrupt', 'no');

    set(findobj(FcmFigH, 'tag', 'data_set'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'cluster_number'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'clear_traj'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'exponent'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'max_iter'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'min_impro'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Expo.:'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Iterat.:'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Improv.:'), 'enable', 'off');

    % === change label of start
    set(findobj(FcmFigH, 'tag', 'start'), 'string', 'Stop');
    % === delete selectH
    delete(findobj(FcmFigH, 'tag', 'selectH'));
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata', []);
    % === find some clustering parameters
    expo = str2double(get(findobj(FcmFigH, 'tag', 'exponent'), 'string'));
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    max_iter = str2double(get(findobj( ...
        FcmFigH, 'tag', 'max_iter'), 'string'));
    min_eps = str2double(get(findobj( ...
        FcmFigH, 'tag', 'min_impro'), 'string'));
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    % === initial partition
    FcmU = initfcm(cluster_n, data_n);
    % === find initial centers
    [FcmU, FcmCenter] = stepfcm(data, FcmU, cluster_n, expo);
    center_prev = FcmCenter;
    U_prev = FcmU;
    % === Graphic handles for traj and head 
    headH = line(ones(2,1)*FcmCenter(:,1)', ones(2,1)*FcmCenter(:,2)',...
        'erase', 'none', 'LineStyle', 'none', 'Marker', '.', ...
        'markersize', 30, 'tag', 'headH');
    trajH = line(zeros(2,cluster_n), zeros(2,cluster_n), ...
        'erase', 'none', 'linewidth', 3, ...
        'tag', 'trajH');

    % === array for objective function 
    err = zeros(max_iter, 1);

    for i = 1:max_iter,
        [FcmU, FcmCenter, err(i)] = stepfcm( ...
            data, U_prev, cluster_n, expo);
        fprintf('Iteration count = %d, obj. fcn = %f\n', i, err(i));
        % === label each data if necessary
        eval([mfilename, '(''label_data'')']);
        % === check ternimation invoked from GUI
        if findobj(FcmFigH, 'string', 'Start')
            break;
        end
        tempusdt=get(findobj(FcmFigH, 'string', 'Close'), 'userdata');
        if ~isempty(tempusdt)&(tempusdt == 1),
            break;
        end
        % === check normal termination condition
        if i > 1,
            if abs(err(i) - err(i-1)) < min_eps, break; end,
        end
%       if max(max(U_prev - FcmU)) < min_eps, break; end,
        % === refresh centers for animation
        for j = 1:cluster_n,
            set(headH(j), 'xdata', FcmCenter(j, 1), 'ydata', FcmCenter(j, 2));
            set(trajH(j), 'xdata', [center_prev(j, 1) FcmCenter(j, 1)], ...
            'ydata', [center_prev(j, 2) FcmCenter(j, 2)]);
        end
        drawnow;
        center_prev = FcmCenter;
        U_prev = FcmU;
    end
    % === change the button label
    tempusdt=get(findobj(FcmFigH, 'string', 'Close'), 'userdata');
    if  ~isempty(tempusdt)&tempusdt== 1,
        delete(FcmFigH);
    else
        % change to 'Start'
        set(findobj(FcmFigH, 'tag', 'start'), 'string', 'Start');
        % make everything interruptible
                %set(findobj(FcmFigH,'Interrupt','no'),'Interrupt','yes');
                set(findobj(FcmFigH,'enable','off'),'enable','on');
    end
elseif strcmp(action, 'label_data0'),   % initialize labelH
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');

    maxU = max(FcmU);
    x=[];
    y=[];
    for i = 1:cluster_n,
        index = find(FcmU(i, :) == maxU);
        cluster = data(index', :);
        if isempty(cluster), cluster = [nan nan]; end
        x = fstrvcat(x, cluster(:, 1)');
        y = fstrvcat(y, cluster(:, 2)');
    end
    x(find(x==0)) = nan*find(x==0); % get rid of padded zeros
    y(find(y==0)) = nan*find(y==0); % get rid of padded zeros
    labelH = line(x', y', 'LineStyle', 'none', 'Marker', 'o', 'visible', 'off');
    set(labelH, 'erase', 'xor');
    set(findobj(FcmFigH, 'tag', 'label_data'), 'userdata', labelH), 
elseif strcmp(action, 'label_data'),
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    labelH = get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata');
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');
    if label_data ~= 0,
        set(dataplotH, 'visible', 'off');
        maxU = max(FcmU);
        for i = 1:cluster_n,
            index = find(FcmU(i, :) == maxU);
            cluster = data(index', :);
            if isempty(cluster), cluster = [nan nan]; end
            set(labelH(i), 'xdata', cluster(:, 1), ...
                'ydata', cluster(:, 2));
        end
        set(labelH, 'visible', 'on');
    else
        set(dataplotH, 'visible', 'on');
        set(labelH, 'visible', 'off');
    end
elseif strcmp(action, 'get_data'),
    getDataH = findobj(FcmFigH, 'tag', 'data_set');
    dataID = get(getDataH, 'value'); 
    no_change = 0;
    if dataID == 1,
        data_n = 400;
        data = rand(data_n, 2);
        % === cluster 1
        dist1 = distfcm([0.2 0.2], data);
        index1 = (dist1 < 0.15)';
        % === cluster 2
        dist2 = distfcm([0.7 0.7], data);
        index2 = (dist2 < 0.25)';
        % === cluster 3
        index3 = data(:,1) - data(:, 2) - 0.1 < 0;
        index4 = data(:,1) - data(:, 2) + 0.1 > 0;
        index5 = data(:,1) + data(:, 2) - 0.4 > 0;
        index6 = data(:,1) + data(:, 2) - 1.4 < 0;
        % === final data
        data(find((index1|index2|(index3&index4&index5&index6)) ...
            == 0), :) = [];
    elseif dataID == 2,
        data_n = 100;
        % === cluster 1
        c1 = [0.6 0.2]; radius1 = 0.2;
        data1 = randn(data_n, 2)/10 + ones(data_n, 1)*c1;
        % === cluster 2
        c2 = [0.2 0.6]; radius2 = 0.2;
        data2 = randn(data_n, 2)/10 + ones(data_n, 1)*c2;
        % === cluster 3
        c3 = [0.8 0.8]; radius3 = 0.2;
        data3 = randn(data_n, 2)/10 + ones(data_n, 1)*c3;
        % === final data
        data = [data1; data2; data3];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 3,
        data_n = 100;
        k = 10;
        c1 = [0.125 0.25];
        data1 = randn(data_n, 2)/k + ones(data_n, 1)*c1;
        c2 = [0.625 0.25];
        data2 = randn(data_n, 2)/k + ones(data_n, 1)*c2;
        c3 = [0.375 0.75];
        data3 = randn(data_n, 2)/k + ones(data_n, 1)*c3;
        c4 = [0.875 0.75];
        data4 = randn(data_n, 2)/k + ones(data_n, 1)*c4;
        data = [data1; data2; data3; data4];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 4,
        data_n = 100;
        % === cluster 1
        c1 = [0.2 0.2];
        data1 = randn(data_n, 2)/15 + ones(data_n, 1)*c1;
        % === cluster 2
        c2 = [0.2 0.5];
        data2 = randn(data_n, 2)/15 + ones(data_n, 1)*c2;
        % === cluster 3
        c2 = [0.2 0.8];
        data3 = randn(data_n, 2)/15 + ones(data_n, 1)*c2;
        % === cluster 4
        c3 = [0.8 0.5];
        data4 = randn(data_n, 2)/10 + ones(data_n, 1)*c3;
        % === final data
        data = [data1; data2; data3; data4];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 5,
        data_n = 300;
        data = rand(data_n, 2);
    elseif dataID == 6, % Customized data set
        data_file = uigetfile('*.dat');
        if data_file == 0 | data_file == '',    % cancelled
            no_change = 1;
        else        % loading data
            eval(['load ' data_file]);
            tmp = find(data_file=='.');
            if tmp == [],   % data file has no extension.
                eval(['data=' data_file ';']);
            else
                eval(['data=' data_file(1:tmp-1) ';']);
            end
            if size(data, 2) ~= 2,
                fprintf('Given data is not 2-D!\n');
                no_change = 1;
            end
        end
    else
        error('Selected data not found!');
    end
    if no_change,
        set(getDataH, 'value', OldDataID); 
    else
        % normalize data set
        maxx = max(data(:,1)); minx = min(data(:,1));
        data(:,1) = (data(:,1)-minx)/(maxx-minx); 
        maxy = max(data(:,2)); miny = min(data(:,2));
        data(:,2) = (data(:,2)-miny)/(maxy-miny); 
        % process data
        OldDataID = dataID; 
        delete(get(FcmAxisH, 'child'));
%        set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        dataplotH = line(data(:, 1), data(:, 2), 'color', 'g', ...
            'LineStyle', 'none', 'Marker', 'o', 'visible', 'off', ...
            'clipping', 'off');
        set(dataplotH, 'userdata', data);
        set(getDataH, 'userdata', dataplotH);
    end
elseif strcmp(action, 'init_U'),
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), ...
        'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    FcmU = initfcm(cluster_n, data_n);
elseif strcmp(action, 'display_data'),
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    labelH = get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata');
    if label_data == 0,
        set(dataplotH, 'visible', 'on');
        set(labelH, 'visible', 'off');
    else
        set(dataplotH, 'visible', 'off');
        set(labelH, 'visible', 'on');
    end
elseif strcmp(action, 'cluster_number'),
    eval([mfilename, '(''init_U'')']);
    delete(get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata'));
    delete(findobj(FcmFigH, 'tag', 'headH'));
    delete(findobj(FcmFigH, 'tag', 'trajH'));
    delete(findobj(FcmFigH, 'tag', 'selectH'));
    FcmCenter = [];
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata', []);
    eval([mfilename, '(''label_data0'')']);
    eval([mfilename, '(''display_data'')']);
elseif strcmp(action, 'clear_traj'),
    if ~isempty(findobj(FcmFigH, 'string', 'Start')),
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        delete(findobj(FcmFigH, 'tag', 'trajH'));
    end
elseif strcmp(action, 'clear_all'),
    if ~isempty(findobj(FcmFigH, 'string', 'Start')),
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        delete(findobj(FcmFigH, 'tag', 'headH'));
    end
elseif strcmp(action, 'close'),
    set(findobj(FcmFigH, 'string', 'Close'), 'userdata', 1);
    if ~isempty(findobj(FcmFigH, 'string', 'Start')),
        delete(FcmFigH);
    end
elseif strcmp(action, 'mf_plot'),
    old_pointer = get(FcmFigH, 'pointer');
    set(FcmFigH, 'pointer', 'watch');
    % looping till mouse action is done
    which_cluster = get(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata');
    if isempty(which_cluster),
        fprintf('Use mouse to select a cluster first.\n');
    else
        title = ['MF Plot for Cluster ', int2str(which_cluster)];
        MfFigH = findobj(0, 'Name', title);
        if isempty(MfFigH), % create a new MF plot
            dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
            data = get(dataplotH, 'userdata');
            tmp = FcmU';
            % use griddata to do surface plot
            fprintf('Using "griddata" to plot MF surface ...\n');
            [XI, YI] = meshgrid(0:0.1:1, 0:0.1:1);
            ZI = griddata(data(:,1), data(:, 2), tmp(:, which_cluster), XI, YI);
            % Create a new figure window
            pos = get(0, 'defaultfigurepos');
            pos(3) = pos(3)*0.75; pos(4) = pos(4)*0.75;
            MfFigH = figure('Name', title, ...
                'NumberTitle', 'off', 'position', pos, 'DockControls','off');
	    % V4 color default
	    colordef(MfFigH, 'black');
            mesh(XI, YI, ZI);
            xlabel('X'), ylabel('Y'), zlabel('MF');
            axis([0 1 0 1 0 1]); set(gca, 'box', 'on');
            rotate3d on;
            set(MfFigH, 'HandleVisibility', 'callback');
        end
        set(0, 'Currentfigure', MfFigH);
    end
    set(FcmFigH, 'pointer', old_pointer);
elseif strcmp(action, 'set_mouse_action'),
    % action when button is first pushed down
    action1 = [mfilename '(''mouse_action1'')'];
    % actions after the mouse is pushed down
    action2 = ' ';
    % action when button is released
    action3 = ' ';

    % temporary storage for the recall in the down_action
    set(gca,'UserData',action2);

    % set action when the mouse is pushed down
    down_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'',get(gca,''UserData''));' ...
        action1];
    set(gcf,'WindowButtonDownFcn',down_action);

    % set action when the mouse is released
    up_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'','' '');', action3];
    set(gcf,'WindowButtonUpFcn',up_action);
elseif strcmp(action, 'mouse_action1'),
    curr_info = get(gca, 'CurrentPoint');
    CurrPt = [curr_info(1, 1) curr_info(1,2)];
    if ~isempty(FcmCenter),
        [junk, which_cluster] = min(distfcm(CurrPt, FcmCenter));
        set(findobj(gcf, 'tag', 'mf_plot'), 'userdata', which_cluster);
        delete(findobj(gcf, 'tag', 'selectH'));
        selectH = line(FcmCenter(which_cluster, 1), FcmCenter(which_cluster, 2), ...
            'tag', 'selectH', 'LineStyle', 'none', 'Marker', 'o', 'markersize', 30);
    end
elseif strcmp(action, 'exponent'),
    expo = str2double(get(findobj(FcmFigH, 'tag', 'exponent'), 'string'));
    if expo <= 1,
        fprintf('The exponent for MF''s should be greater than 1!\n');
        set(findobj(FcmFigH, 'tag', 'exponent'), 'string', num2str(1.01));
    end
elseif strcmp(action, 'info'),
    helpwin(mfilename);
%   title = '2-D Fuzzy C-means Clustering';
%   help_string = ...        
%   [' You are seeing fuzzy C-means clustering         '  
%    ' when the data sets are 2-dimensional. You can   '  
%    ' choose the data set and clustering number from  '  
%    ' the GUI buttons at right, and then click        '  
%    ' "Start" to start the fuzzy clustering process.  '  
%    '                                                 '  
%    ' Once the clustering is done, you can select     '  
%    ' one of the clusters by mouse and view the MF    '  
%    ' surface by clicking the "MF Plot" button.       '  
%    '                                                 '  
%    ' If you choose to use a customized data set,     '  
%    ' it must be 2-D data. Moreover, the data set     '  
%    ' is normalized to within the unit cube           '  
%    ' [0,1] X [0,1] before being clustered.           '  
%    '                                                 '  
%    ' File name: fcmdemo.m                            '];
%   fhelpfun(title, help_string);
else
    fprintf('Given string is "%s".\n', action);
    error('Unrecognized action string!');
end
