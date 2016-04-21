function printMap(this)

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/02/01 21:57:03 $

%printdlg(double(this.Figure));
fig = figure('Visible','off','Position',double(this.Figure.Position));
h=copyobj(double(this.Axis),fig);
%hh=copyobj(this.AnnotationAxes,fig);
set(this.AnnotationAxes,'Parent',fig)
axis 'off';
printdlg(fig);
set(this.AnnotationAxes,'parent',this.Figure)
close(fig);


