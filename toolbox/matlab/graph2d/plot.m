%PLOT   Linear plot. 
%   PLOT(X,Y) plots vector Y versus vector X. If X or Y is a matrix,
%   then the vector is plotted versus the rows or columns of the matrix,
%   whichever line up.  If X is a scalar and Y is a vector, length(Y)
%   disconnected points are plotted.
%
%   PLOT(Y) plots the columns of Y versus their index.
%   If Y is complex, PLOT(Y) is equivalent to PLOT(real(Y),imag(Y)).
%   In all other uses of PLOT, the imaginary part is ignored.
%
%   Various line types, plot symbols and colors may be obtained with
%   PLOT(X,Y,S) where S is a character string made from one element
%   from any or all the following 3 columns:
%
%          b     blue          .     point              -     solid
%          g     green         o     circle             :     dotted
%          r     red           x     x-mark             -.    dashdot 
%          c     cyan          +     plus               --    dashed   
%          m     magenta       *     star             (none)  no line
%          y     yellow        s     square
%          k     black         d     diamond
%                              v     triangle (down)
%                              ^     triangle (up)
%                              <     triangle (left)
%                              >     triangle (right)
%                              p     pentagram
%                              h     hexagram
%                         
%   For example, PLOT(X,Y,'c+:') plots a cyan dotted line with a plus 
%   at each data point; PLOT(X,Y,'bd') plots blue diamond at each data 
%   point but does not draw any line.
%
%   PLOT(X1,Y1,S1,X2,Y2,S2,X3,Y3,S3,...) combines the plots defined by
%   the (X,Y,S) triples, where the X's and Y's are vectors or matrices 
%   and the S's are strings.  
%
%   For example, PLOT(X,Y,'y-',X,Y,'go') plots the data twice, with a
%   solid yellow line interpolating green circles at the data points.
%
%   The PLOT command, if no color is specified, makes automatic use of
%   the colors specified by the axes ColorOrder property.  The default
%   ColorOrder is listed in the table above for color systems where the
%   default is blue for one line, and for multiple lines, to cycle
%   through the first six colors in the table.  For monochrome systems,
%   PLOT cycles over the axes LineStyleOrder property.
%
%   If you do not specify a marker type, PLOT uses no marker. 
%   If you do not specify a line style, PLOT uses a solid line.
%
%   PLOT(AX,...) plots into the axes with handle AX.
%
%   PLOT returns a column vector of handles to lineseries objects, one
%   handle per plotted line. 
%
%   The X,Y pairs, or X,Y,S triples, can be followed by 
%   parameter/value pairs to specify additional properties 
%   of the lines. For example, PLOT(X,Y,'LineWidth',2,'Color',[.6 0 0]) 
%   will create a plot with a dark red line width of 2 points.
%
%   Backwards compatibility
%   PLOT('v6',...) creates line objects instead of lineseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   See also PLOTTOOLS, SEMILOGX, SEMILOGY, LOGLOG, PLOTYY, PLOT3, GRID,
%   TITLE, XLABEL, YLABEL, AXIS, AXES, HOLD, LEGEND, SUBPLOT, SCATTER.

%   If the NextPlot axes property is "replace" (HOLD is off), PLOT resets 
%   all axes properties, except Position, to their default values,
%   deletes all axes children (line, patch, text, surface, and
%   image objects), and sets the View property to [0 90].

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.19.4.4 $  $Date: 2004/02/01 22:03:02 $
%   Built-in function.

