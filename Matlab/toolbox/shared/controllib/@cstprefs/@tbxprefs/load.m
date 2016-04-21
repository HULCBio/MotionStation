function h = load(h,filename)
%LOAD  Load Toolbox Preferences from disk

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:52 $

if nargin<2
   %---If no file name is specified, load from default preference file
   filename = h.defaultfile;
end

try
   s = load(filename);
   %---Map old preference values into current preferences object
   Dirty = localMapValues(h,s.p);
   if Dirty
      h.save;   %---Force save if changes were made during mapping
   end
end


%---Define our Java fonts (this may not be neccessary if java.awt.Font is system/version independent)
if usejava('AWT')
   h.JavaFontP = java.awt.Font('Dialog',java.awt.Font.PLAIN,h.JavaFontSize);
   h.JavaFontB = java.awt.Font('Dialog',java.awt.Font.BOLD,h.JavaFontSize);
   h.JavaFontI = java.awt.Font('Dialog',java.awt.Font.ITALIC,h.JavaFontSize);
end


%%%%%%%%%%%%%%%%%%
% localMapValues %
%%%%%%%%%%%%%%%%%%
function Dirty = localMapValues(h,p)
% Map values into preferences object (from structure p to object h)
Dirty = 0;
%---Version info
newver = h.Version;
if isfield(p,'Version')
   oldver = p.Version;
else
   oldver = 0;
end
%---Field names
fnp = fieldnames(p);
fnh = fieldnames(h);
%---Quick set (property list unchanged)
if isequal(fnp,fnh)
   set(h,p);
%---Partial set (property list has changed)
else
   %---Copy any common properties to the new version
   hs = get(h);
   for n=1:length(fnp)
      if isfield(hs,fnp{n})
         set(h,fnp{n},p.(fnp{n}));
      end
   end
end
%---Restore new version number (since the set may have wiped it out)
h.Version = newver;
%---Custom version-specific modifications
localUpdateValues(h,oldver);
%---If anything has changed, force a save
if ~isequal(get(h),p)
   Dirty = 1;
end


%%%%%%%%%%%%%%%%%%%%%
% localUpdateValues %
%%%%%%%%%%%%%%%%%%%%%
function localUpdateValues(h,oldver)
% Update old property values to new equivalent values
hs = get(h);
%---Old CompensatorFormat options
if isfield(hs,'CompensatorFormat')
   if strcmpi(h.CompensatorFormat,'ZPK1')
      h.CompensatorFormat = 'ZeroPoleGain';
   elseif strcmpi(h.CompensatorFormat,'TimeConstant')
      h.CompensatorFormat = 'TimeConstant1';
   end
end
%---Prefilter color change (v1.1)
if isfield(hs,'SISOToolStyle')&(oldver<1.1)
   tmp = h.SISOToolStyle;
   tmp.Color.PreFilter = [0 0.7 0];
   h.SISOToolStyle = tmp;
end
