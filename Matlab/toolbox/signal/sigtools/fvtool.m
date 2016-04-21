function varargout = fvtool(varargin) 
%FVTOOL Filter Visualization Tool (FVTool).
%   FVTool is a Graphical User Interface (GUI) that allows 
%   you to analyze digital filters.  
%
%   FVTOOL(B,A) launches the Filter Visualization Tool and computes 
%   the Magnitude Response for the filter defined by numerator and denominator 
%   coefficients in vectors B and A. 
% 
%   FVTOOL(B,A,B1,A1,...) will perform an analysis on multiple filters. 
%
%   FVTOOL(Hd) will perform an analysis on a discrete-time filter (DFILT) 
%   object. 
%
%   If the Filter Design Toolbox is installed, FVTOOL(H,H1) can be used to
%   analyze fixed-pt filter objects, by setting the 'Arithmetic' property
%   to 'fixed, multirate filter objects, MFILTs, and adaptive filter
%   objects, ADAPTFILTs.
%
%   H = FVTOOL(...) returns the handle to FVTool.  This handle can be
%   used to interface with FVTool through the GET and SET commands as you
%   would with a normal figure, but with additional properties.  Some of
%   these properties are analysis-specific and will change whenever the 
%   analysis changes.  Execute GET(H) to see a list of FVTool's properties 
%   and current values.
%
%   FVTOOL(Hd,PROP1,VALUE1,PROP2,VALUE2, etc.) launches FVTool and sets
%   the specified properties to the specified values.
%
%   The following methods are defined for H, the handle to FVTool:
%
%   ADDFILTER(H, FILTOBJ) where filtobj is a DFILT object.  This will add
%   the new filter to FVTool without affecting the filters currently  being
%   analyzed.
%   
%   SETFILTER(H, FILTOBJ) replaces the filter in FVTool with FILTOBJ.
%
%   DELETEFILTER(H, INDEX) deletes the filter at specified by INDEX from FVTool.
%
%   LEGEND(H, STRING1, STRING2, etc) creates a legend on FVTool by
%   associating STRING1 with Filter #1, STRING2 with Filter #2 etc.
%
%   EXAMPLES:
%   % #1 Magnitude Response of an IIR filter
%   [b,a] = butter(5,.5);                                                 
%   h1 = fvtool(b,a);                                                     
%   Hd = dfilt.df1(b,a); % Discrete-time filter (DFILT) object            
%   h2 = fvtool(Hd);                                                      
%
%   % #2 Analysis of multiple FIR filters
%   b1 = firpm(20,[0 0.4 0.5 1],[1 1 0 0]); 
%   b2 = firpm(40,[0 0.4 0.5 1],[1 1 0 0]); 
%   fvtool(b1,1,b2,1);
%
%   % #3 Using FVTool's API
%   set(h1, 'Analysis', 'impulse'); % Change the analysis 
%   
%   Hd2 = dfilt.dffir(b2);                                                
%   addfilter(h2, Hd2);             % Add a new filter 
%
%   % Setting FVTool's analysis-specific properties
%   h = fvtool(Hd2,'Analysis','phase','PhaseDisplay','Continuous Phase');               
%
%   See also FDATOOL, SPTOOL.

%    Author(s): J. Schickler & P. Costa
%    Copyright 1988-2004 The MathWorks, Inc.
%    $Revision: 1.37.4.5 $  $Date: 2004/04/13 00:31:49 $ 

% Parse the inputs
error(nargchk(1,inf,nargin));

[msg, id] = lasterr;

try
    % Instantiate the fvtool object.
    hObj = sigtools.fvtool(varargin{:});
catch
    rethrow(lasterror);
end

% We need to reset the lasterr because DFILTs populate it with bogus info.
lasterr(msg, id);

% Turn FVTool on
set(hObj,'Visible','On');

% Return FVTools' handle
if nargout > 0,
    varargout{1} = hObj;
end

% [EOF]
