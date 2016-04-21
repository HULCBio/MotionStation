function [xlims,ylims] = rloclims(r,Ts)
%RLOCLIMS  Compute adequate axis limits for root loci with asymptotes.
%
%   [XLIMS,YLIMS] = RLOCLIMS(R,Ts) returns the X and Y axis limits 
%   vectors given the set of roots R (arranged column-wise).  Ts
%   is the sample time of the open-loop model.
%
%   See also RLOCUS.

%   Author(s): P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/06/11 17:30:44 $

if isempty(r)
   % Quick exit if no roots
   xlims = [-1 1];
   ylims = [-1 1];
   return
end

% Search for infinite poles
jinf = find(any(isinf(r),1));
rinf = r(:,jinf);

if ~isempty(jinf),
   % Root locus is unbounded. 
   % Find and remove the asymptotes from the root locus. Store the starting  
   % point, end point, and direction for each asymptote
   [r1,s1,e1,t1] = AsymInfo(r(:,jinf-1:-1:1),rinf);
   [r2,s2,e2,t2] = AsymInfo(r(:,jinf+1:end),rinf);
   s = [s1;s2];   % asymptote starting points
   e = [e1;e2];   % asymptote end points
   t = [t1;t2];   % asymptote directions
   
   % Compute smallest box containing the loci minus the asymptotes
   rclip = [r1 ; r2 ; rinf(isfinite(rinf))];
   [xmin,xmax,ymax] = minbox(rclip);
   xextent = (max(0,xmax)-min(0,xmin))/2;   % include origin
   yextent = ymax;
   extent = max(xextent,yextent) + (~xextent & ~yextent);
   % Correct flat aspect ratio 
   xextent = max(xextent,extent/4);
   yextent = max(yextent,extent/4);
   % Inflate extent for flat locus
   if ~ymax | xmin==xmax,
      xextent = 2 * xextent;   yextent = 2 * yextent;
   end
   
   % Scale smallest box up 200% and make each asymptote extend 
   % to borders of resulting box 
   ScaleF = 2 + 0.5 * (length(t)==1);
   xc = (xmin+xmax)/2; 
   xl = (ScaleF * xextent + sign(real(t)) .* (xc - real(s))) ./ (eps + abs(real(t))); 
   yl = (ScaleF * yextent - sign(imag(t)) .* imag(s)) ./ (eps + abs(imag(t))); 
   totlength = max(min(xl,yl));            % max common length 
   totlength = min([totlength ; abs(e-s)]);   % adjust to actual data extent 
   r = [rclip ; s + totlength * t];        % add last visible asymptote points 
end

% Compute tight bounding box
[xmin,xmax,ymax] = minbox(r(:));   

% Limit aspect ratio to 1:10 and expand bounding box by 5% 
% Make sure origin is contained in axes
xextent = (xmax-xmin)/2;
yextent = ymax;
xc = (xmin+xmax)/2;
extent = max(xextent,yextent);
extent = extent + max(1,0.1*abs(xc)) * (extent<=0.1*abs(xc));  % guard against zero extent
xextent = max(xextent,extent/10);
yextent = max(yextent,extent/10);
xmin = min(xc-1.05*xextent,-0.05*xextent);
xmax = max(xc+1.05*xextent,0.05*xextent);
ymax = 1.05 * yextent;

xlims = [xmin xmax];
ylims = [-ymax ymax];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xmin,xmax,ymax] = minbox(r)
%MINBOX  Find smallest box containing all roots R

xmin = min(real(r)); 
xmax = max(real(r));
ymax = max(imag(r));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [r,s,e,t] = AsymInfo(r,rinf)
%ASYMINFO  Identifies and factors out root locus asymptotes
%  
%  Assumes the roots are ordered as RINF, R(:,1), R(:,2),...

% Quick exit if R is empty
if isempty(r),
   r = r(:);   s = zeros(0,1);   e = zeros(0,1);   t = zeros(0,1);
   return
end

% Extract branches with asymptotes (BWA) 
nr = size(r,2);
bwa = isinf(rinf);  % 1 for branches with an asymptote
rasy = r(bwa,:);    % branches w/ asymptotes
rfin = r(~bwa,:);   % finite branches

% Compute tangent directions T along BWAs, and derive angles with  
% initial directions T(:,1) along each branch.  A point is considered 
% on the asymptote if this angle is smaller than 2 degrees.
% RE: T(:,1) approximates the asymptote directions
t = rasy(:,2:nr)-rasy(:,1:nr-1);
t = t ./ (abs(t)+(t==0));
ang = abs(real(t .* conj(t(:,ones(1,nr-1)))));
OnAsymptote = [all(ang>cos(pi/90),1) , 0];

% Compute first and last point on asymptotes
e = rasy(:,1);    % end points
ia = find(cumprod(OnAsymptote));
is = ia(end)+1;
s = rasy(:,is);   % starting points
t = -t(:,1);      % asymptote direction (RE: measure it where it's most accurate!)

% Delete asymptotes (keep only their starting points)
rasy(:,1:is-1) = [];
r = [rfin(:) ; rasy(:)];

   

