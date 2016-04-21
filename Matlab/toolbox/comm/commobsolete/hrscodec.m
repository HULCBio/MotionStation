%HRSCODEC is an example of the RS code/decode.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       This example calls a file rstemp.tst. It codes the file using RS code.
%       It sets errors after the carriage return and decodes the contents. 
%       This script file creates a figure showing the results.
%

%       Wes Wang 9/29/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.13 $

    rsencof rstemp.tst temp.cod
    DefUiBgC = get(0,'DefaultUicontrolBackgroundColor');
    h_ui = zeros(1,8);
    UiBfrC = [.9, .9, 0];
    UiAftC = [.9 .9 .9];
    fig = figure('Position',[10 10 800 400],'Color',DefUiBgC,...
            'NumberTitle','off','Resize','off',...
            'Name','R-S code in the application of processign files.');
        fid = fopen('rstemp.tst', 'r');
        x   = fread(fid, inf, 'char');
        fclose(fid);
    h_ui(1) = uicontrol('Style','text','Position',[50 365 300 20],...
     'BackgroundColor',UiAftC,...
     'String','Original text (file: rstemp.tst)');    
    h_ui(2) = uicontrol('Style','text','Position',[450 365 300 20],...
     'BackgroundColor',UiBfrC,...
     'String','Coded text (file: temp.cod)');    
    h_ui(3) = uicontrol('Style','text','Position',[450 165 300 20],...
     'BackgroundColor',UiBfrC,...
     'String','Coded text with noise (file: temp.noi)');    
    h_ui(4) = uicontrol('Style','text','Position',[50 165 300 20],...
     'BackgroundColor',UiBfrC,...
     'String','Recovered text (file: temp.dec)');    
    h_ui(5) = uicontrol('Style','edit','Max',2,'Position',[ 10 210 380 150], ...
     'BackgroundColor',UiAftC,...
     'HorizontalAlignment','left','String',setstr(x)');
    drawnow;
    h_ui(6) = uicontrol('Style','edit','Max',2,'Position',[405 210 390 150], ...
     'BackgroundColor',UiBfrC,...
     'HorizontalAlignment','left','String','In processing.'); 
    h_ui(7) = uicontrol('Style','edit','Max',2,'Position',[405  10 390 150], ...
     'BackgroundColor',UiBfrC,...
     'HorizontalAlignment','left','String','In processing.');
    h_ui(8) = uicontrol('Style','edit','Max',2,'Position',[5 10 390 150], ...
     'BackgroundColor',UiBfrC,...
     'HorizontalAlignment','left','String',...
      str2mat('In processing using command:','rsdecof temp.noi temp.dec'));
    drawnow
fid = fopen('temp.cod', 'r');
x   = fread(fid, inf, 'char');
fclose(fid);
    set(h_ui(2), 'BackgroundColor',UiAftC);
    set(h_ui(6), 'BackgroundColor',UiAftC,...
     'String',setstr(x)')
    drawnow;
    tmp = find(x == 10);
    if isempty(tmp)
      tmp = find(x==13);
      tmp = tmp(1 : 4 : length(tmp));
    end
    if ~isempty(tmp)
      tmp(length(tmp)) = 0;
    end
    for i = 1 : length(tmp)
        x(tmp(i)+1:tmp(i)+2) = abs('$$');
    end;
%%for i = 30 : 63 : length(x)
%%    x(i:i+1) = abs('$$');
%%end;
fid = fopen('temp.noi','w');
fwrite(fid, x, 'char');
    set(h_ui(3), 'BackgroundColor',UiAftC);
    set(h_ui(7), 'BackgroundColor',UiAftC,...
     'String',setstr(x)')
    drawnow;
rsdecof temp.noi temp.dec
    fid = fopen('temp.dec', 'r');
    x   = fread(fid, inf, 'char');
    fclose(fid);
    set(h_ui(4), 'BackgroundColor',UiAftC);
    set(h_ui(8), 'BackgroundColor',UiAftC,...
     'String',setstr(x)')
    drawnow;

