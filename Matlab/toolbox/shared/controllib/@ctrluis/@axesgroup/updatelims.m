function updatelims(h,varargin)
%UPDATELIMS  Builtin limit picker.
%
%   UPDATELIMS(H) implements the default limit management (LimitManager='builtin').  
%   This limit manager
%     1) Finds common auto limits for axes in auto mode, in accordance
%        with the limit sharing settings defined by XLimSharing and 
%        YLimSharing
%     2) Ensures axes in manual mode comply with the LimSharing settings.
%   Only visible axes are included in the auto limit computation.
%
%   UPDATELIMS(H,XLIMMODE,YLIMMODE) adjusts the limits for the limit mode
%   settings XLIMMODE and YLIMMODE.  Custom limit managers can use this option 
%   to apply the default manager to only a subset of the axes group. Set 
%   XLimMode='manual' or YLimMode='manual' to exclude particular axes from the 
%   auto limit picking.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:24 $

ni = nargin;
if isvisible(h)
   % No updating if global mode is manual or custom (unless called directly)
   ax = h.Axes2d;
   [nr,nc] = size(ax);
   
   % Visible axes
   vis = reshape(strcmp(get(ax,'Visible'),'on'),[nr nc]);  % 1 for visible axes
   indrow = find(any(vis,2))';  % row with visible axes
   indcol = find(any(vis,1));   % columns with visible axes
   
   % Turn off backdoor listeners
   LimitMgrEnable = h.LimitManager;  % can be 'off' in call with 3 inputs
   h.LimitManager = 'off';
   
   % X and Y limit modes
   if ni==3 & ~isempty(varargin{1})
      XLimMode = varargin{1};
   else
      XLimMode = h.XLimMode;  % Use current settings
   end
   if ni==3 & ~isempty(varargin{2})
      YLimMode = varargin{2};
   else
      YLimMode = h.YLimMode;  % Use current settings
   end
   
   % Switch to auto mode for visible axes with XLimMode=auto
   xauto = strcmp(XLimMode,'auto');
   if length(xauto)==1
      xauto = repmat(xauto,[nr nc]);
   else
      xauto = repmat(xauto',[nr 1]);
   end
   set(ax(vis & xauto),'XlimMode','auto')
   
   % Switch to auto mode for visible axes with YLimMode=auto
   yauto = strcmp(YLimMode,'auto');
   if length(yauto)==1
      yauto = repmat(yauto,[nr nc]);
   else
      yauto = repmat(yauto,[1 nc]);
   end
   set(ax(vis & yauto),'YlimMode','auto')
   
   % Update X limits
   switch h.XLimSharing
   case 'column'
      for ct=indcol,
         LocalEqualizeLims(ax(indrow,ct),'Xlim','XScale');
      end
   case 'all'
      LocalEqualizeLims(ax(vis),'Xlim','XScale');
   case 'peer'
      stride = h.Size(4);
      for ct=1:stride,
         subax = ax(:,ct:stride:nc);
         subvis = vis(:,ct:stride:nc);
         LocalEqualizeLims(subax(subvis),'Xlim','XScale');
      end
   end
   
   % Update Y limits
   switch h.YLimSharing
   case 'row'
      for ct=indrow,
         LocalEqualizeLims(ax(ct,indcol),'Ylim','YScale');
      end
   case 'all'
      LocalEqualizeLims(ax(vis),'Ylim','YScale');
   case 'peer'
      stride = h.Size(3);
      for ct=1:stride,
         subax = ax(ct:stride:nr,:);
         subvis = vis(ct:stride:nr,:);
         LocalEqualizeLims(subax(subvis),'Ylim','YScale');
      end
   end
   
   % Turn backdoor listeners back on
   h.LimitManager = LimitMgrEnable;
end

%------------------ Local Functions -----------------------

function LocalEqualizeLims(ax,LimProp,ScaleProp);
% Enforce common limits for all axes in handle array AX
% All axes are assumed visible.

% Compute common limits
Lmin = NaN;
Lmax = NaN;
for ct=1:prod(size(ax))
   Lims = get(ax(ct),LimProp);
   Lmin = min(Lmin,Lims(1));
   Lmax = max(Lmax,Lims(2));
end

% Enforce these limits
set(ax,LimProp,[Lmin Lmax])
