function daabout(product)
%DAABOUT  DAStudio about figure

%   J Breslau
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

mlock;

aboutImageDir = [matlabroot '/toolbox/shared/dastudio/resources/'];

product = lower(product);

switch(product),
case 'simulink',
    [cdata, map] = imread([aboutImageDir 'about_sl.tif'], 'tif');
    dlgTitle = 'About Simulink';

	aboutString = {...
	    ver2str(ver('simulink')), ...
	};
case 'stateflow',
    [cdata, map] = imread([aboutImageDir 'about_sf.tif'], 'tif');
    dlgTitle = 'About Stateflow';

    if sf('License','coder')
    	aboutString = {...
    	    ver2str(ver('stateflow')), ...
    	    ver2str(ver('coder')), ...
    	};
    elseif sf('License','basic')
    	aboutString = {...
    	    ver2str(ver('stateflow')), ...
    	};
    elseif sf('License','demo')
        sfVer = ver('stateflow');
        sfVer.Name = [sfVer.Name ' Demo'];
    	aboutString = {...
    	    ver2str(sfVer), ...
    	};
    else
       error('Stateflow is not licensed.');
    end
otherwise,
    error('Product not supported by DAStudio');
end



cdata = flipud(cdata);

dlg = dialog(   'Name',     dlgTitle, ...
                'Color',    'White', ...
                'WindowStyle', 'Normal', ...
                'Visible',  'off', ...
                'Colormap', map);



buttonWidth = 60;
buttonHeight = 20;
buttonY = 10;

textHeight = 25;

bottomBuffer = textHeight + buttonHeight + 2*buttonY;

pos = get(dlg, 'position');
imsize = size(cdata);
pos(2) = pos(2) - bottomBuffer;
pos(3) = imsize(1);
pos(4) = imsize(2) + bottomBuffer;
set(dlg, 'Position', pos);

ax = axes(      'Parent',   dlg, ...
                'Visible',  'off', ...
                'units',    'pixels', ...
                'position', [0 bottomBuffer imsize(1) imsize(2)], ...
                'xlim',     [0 imsize(1)], ...
                'ylim',     [0 imsize(2)]);

im = image(     'Parent',   ax, ...
                'CData',    cdata);

aboutText = uicontrol(  'Style',                'text', ...
                        'Position',             [20 2*buttonY+buttonHeight imsize(1)-20 textHeight], ...
                        'BackgroundColor',      'white', ...
                        'ForegroundColor',      [.35 .35 .35], ...
                        'String',               aboutString, ...
                        'Parent',               dlg,...
                        'FontSize',             8,...
                        'HorizontalAlignment',  'Left');

ok = uicontrol( 'String',   'OK', ...
                'Parent',   dlg, ...
                'Position', [(imsize(1)-buttonWidth)/2 buttonY buttonWidth buttonHeight], ...
                'Style',    'pushbutton', ...
                'CallBack', 'closereq');

set(dlg, 'Visible', 'on');


function str = ver2str(ver)
    str = [ver.Name ' version ' ver.Version ' ' ver.Release ' dated ' ver.Date] ;
