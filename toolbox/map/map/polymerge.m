function [lat2,lon2] = polymerge(lat,lon,tol,outputformat)

%POLYMERGE merge line segments with matching endpoints 
%
%  [lat2,lon2] = POLYMERGE(lat,lon) combines vector line segments 
%  with identical endpoints. Line are sequences of disconnected 
%  segments, each of which consist of one or more connected points. 
%  POLYMERGE compares the endpoints of all line segments and combines 
%  those which match. The line may be input as vectors of latitude and 
%  longitude with NaNs delimiting segments. The line may also be input 
%  as cell arrays, with each element of a cell array containing a 
%  segment. The resulting line is in the same format as the input.
%
%  [lat2,lon2] = POLYMERGE(lat,lon,tol) combines line segments whose
%  endpoints are separated by less than the circular tolerance. If 
%  omitted, tol= 0 is assumed. The tolerance is in the same units as 
%  the polygon input.
%
%  [lat2,lon2] = POLYMERGE(lat,lon,tol,outputformat) controls the 
%  format of the resulting polygons. If outputformat is 'vector', the 
%  result is returned as vectors with NaNs separating the segments. If 
%  outputformat is 'cell', the result is returned as cell arrays 
%  containing segments in each element. If omitted, 'vector' is assumed.
%
%  See also POLYSPLIT, POLYJOIN

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.4.4.1 $ $Date: 2003/08/01 18:17:37 $

if nargin < 3; tol = 0;end
if nargin < 4; outputformat='input';end
if nargin < 2; error('Incorrect number of input arguments'); end

%check input arguments

if ~ischar(outputformat); error('Output format flag must be a string'); end
outputformat = lower(outputformat);

% Check for valid output format before time consuming logical operation

switch outputformat
case {'vector','input','cell'}
otherwise
   error('Unrecognized ouput format flag')
end

% convert to vectors

inputformat = 'vector';
if iscell(lat)
   inputformat = 'cell';
   [lat,lon] = polyjoin(lat,lon);
end

% and canonical input format

lat = [NaN; lat; NaN];
lon = [NaN; lon; NaN];
[lat,lon] = singlenan(lat,lon);

% extract line segments into cellarrays for easier manipulation

[latc,lonc] = polysplit(lat,lon);

% identify connected segments 

s='start';
e='end';
rcsave = [];
direction = [];
[rcsave,direction,lat,lon] = matchends(lat,lon,tol,s,s,rcsave,direction);    % X--- X---
[rcsave,direction,lat,lon] = matchends(lat,lon,tol,e,e,rcsave,direction);    % ---X ---X
[rcsave,direction,lat,lon] = matchends(lat,lon,tol,s,e,rcsave,direction);    % X--- ---X
[rcsave,direction,lat,lon] = matchends(lat,lon,tol,e,s,rcsave,direction);    % ---X X---

if isempty(rcsave)
   [lat2,lon2] = polyjoin(latc,lonc);
   return
end

% identify connected runs of segments

[chainsegs,chaindirs] = chainpairs(rcsave,direction);

% flip segments before concatenation

for i=1:length(chaindirs)
   for j=1:length(chaindirs{i});
      if chaindirs{i}(j) == -1;
         latc{chainsegs{i}(j)} = flipud(latc{chainsegs{i}(j)});
         lonc{chainsegs{i}(j)} = flipud(lonc{chainsegs{i}(j)});
      end
   end
end

inchainsindx = cat(2,chainsegs{:});
notinchainsindx = setdiff(1:length(latc),inchainsindx);

% Build new cell array of segments

[latc2,lonc2] = deal(latc(notinchainsindx),lonc(notinchainsindx));
for i=1:length(chainsegs)
   latc2{end+1} = cat(1,latc{chainsegs{i}});
   lonc2{end+1} = cat(1,lonc{chainsegs{i}});
end

% Convert result to proper output format
switch outputformat
case 'input'
   
   switch inputformat
   case 'cell'
      [lat2,lon2] = deal(latc2,lonc2);
   case 'vector'
      [lat2,lon2] = polyjoin(latc2,lonc2);
   end
   
case 'vector'
   [lat2,lon2] = polyjoin(latc2,lonc2);
case 'cell'
   [lat2,lon2] = deal(latc2,lonc2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [chainsegs,chaindirs] = chainpairs(rcsave,direction)


s1fun = inline('ceil(sign(x)/2 + 1)','x');
s2fun = inline('ceil(sign(-x)/2 + 1)','x');


segEndsUsed = zeros(max(rcsave(:)),2);

% construct list of ends of line segments

k=0;
for i=1:size(rcsave,1)
   
   if ~isnan(rcsave(i,1)) && ...
         ~segEndsUsed(rcsave(i,1),s1fun(direction(i,1))) && ...
         ~segEndsUsed(rcsave(i,2),s2fun(direction(i,2))) 
         
      k=k+1;
      seg1 = rcsave(i,1);
      seg2 = rcsave(i,2);
      
      chainsegs{k} = rcsave(i,:);
      chaindirs{k} = direction(i,:);
      
      segEndsUsed(seg1,s1fun(direction(i,1))) = 1;
      segEndsUsed(seg2,s2fun(direction(i,2))) = 1;
      
      firstseg = seg2;
      rcsave(i,:) = NaN;
      direction(i,:) = NaN;
      [rs,cs] = find(rcsave == firstseg);
      
      while ~isempty(rs);
         for j=1:length(rs)
            
            r = rs(j); c = cs(j);
            c2 = mod(c,2)+1;                 % selects other part of segment pair;
            lastseg = rcsave(r,c);
            lastdir = direction(r,c);
            thisseg = rcsave(r,c2);
            thisdir = direction(r,c2);
            
            switch c
            case 1
               endindx = s1fun(lastdir);
            case 2
               endindx = s2fun(lastdir);
            end
            if isnan(endindx);
               endused = 1;
            else
               endused = segEndsUsed(lastseg,endindx);
            end
            
            switch c2
            case 1
               end2indx = s1fun(thisdir);
            case 2
               end2indx = s2fun(thisdir);
            end
            endused = endused | segEndsUsed(thisseg,end2indx);
            
            if endused 
               if j == length(rs); rs = [];end
            else
               
               chainsegs{k}(end+1) = thisseg;
               chaindirs{k}(end+1) = sign(c2-1.5)*direction(r,c2);
               
               switch c
               case 1
                  segEndsUsed(lastseg,s1fun(lastdir)) = 1;
               case 2
                  segEndsUsed(lastseg,s2fun(lastdir)) = 1;
               end
               
               switch c2
               case 1
                  segEndsUsed(thisseg,s1fun(thisdir)) = 1;
               case 2
                  segEndsUsed(thisseg,s2fun(thisdir)) = 1;
               end
               
               rcsave(r,:) = NaN;
               direction(r,:) = NaN;
               
               [rs,cs] = find(rcsave == thisseg);
               
               break
               
            end
            
         end
         
      end
            
      
      
      firstseg = seg1;
      [rs,cs] = find(rcsave == firstseg);      
      while ~isempty(rs);
         for j=1:length(rs)
            
            r = rs(j); c = cs(j);
            c2 = mod(c,2)+1;                 % selects other part of segment pair;
            lastseg = rcsave(r,c);
            lastdir = direction(r,c);
            thisseg = rcsave(r,c2);
            thisdir = direction(r,c2);
            
            switch c
            case 1
               endindx = s1fun(lastdir);
            case 2
               endindx = s2fun(lastdir);
            end
            if isnan(endindx);
               endused = 1;
            else
               endused = segEndsUsed(lastseg,endindx);
            end
            
            switch c2
            case 1
               end2indx = s1fun(thisdir);
            case 2
               end2indx = s2fun(thisdir);
            end
            endused = endused | segEndsUsed(thisseg,end2indx);
            
            if endused 
               if j == length(rs); rs = [];end
            else
               
               chainsegs{k} = [thisseg chainsegs{k}];
               chaindirs{k} = [-sign(c2-1.5)*direction(r,c2) chaindirs{k}];
               
               switch c
               case 1
                  segEndsUsed(lastseg,s1fun(lastdir)) = 1;
               case 2
                  segEndsUsed(lastseg,s2fun(lastdir)) = 1;
               end
               
               switch c2
               case 1
                  segEndsUsed(thisseg,s1fun(thisdir)) = 1;
               case 2
                  segEndsUsed(thisseg,s2fun(thisdir)) = 1;
               end
               
               rcsave(r,:) = NaN;
               direction(r,:) = NaN;
               
               [rs,cs] = find(rcsave == thisseg);
               
               break
            end
         end
         
      end
      
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [rcsave,direction,lat,lon] = matchends(lat,lon,tol,end1,end2,rcsave,direction)

%MATCHENDS identify connected segments 

% Construct indices of points at requested ends of line segments

indx = find(isnan(lat));

sindx = indx(1:end-1)+1;   % start
eindx = indx(2:end)-1;     % end

switch end1
case 'start'
   i1 = sindx;
   dirflag(1) = -1;
case 'end'
   i1 = eindx;
   dirflag(1) = 1;
end

switch end2
case 'start'
   i2 = sindx;
   dirflag(2) = 1;
case 'end'
   i2 = eindx;
   dirflag(2) = -1;
end

% If the number of line segments is relatively small, use a vectorized calculation
% to compute the distances between segment endpoints. When the number of segments 
% gets large, this matrix becomes a memory hog, so switch to a non-vectorized calculation.


n=length(i1);

if n < 1000
   
   % Construct a matrix of distances between the ends of the segments specified
   % whose indices are provided in i1 and i2
   dist = ...
      (repmat(lat(i1),1,n) - ...
      repmat(lat(i2)',n,1) ) .^2 + ...
      (repmat(lon(i1),1,n) - ...
      repmat(lon(i2)',n,1) ) .^2 ;
   
   
   %%This isn't right
   %dist = distance(...
   %   repmat(lat(i1),1,n),repmat(lon(i1),1,n),...
   %   repmat(lat(i2),1,n),repmat(lon(i2),1,n) )
   
   
   % Retain only part of matrix above the diagonal because symettry 
   % duplicates information
   dist = dist+ tril( NaN*zeros(size(dist)) );
   
   % Identify segment pairs with ends closer than the tolerance
   [r,c] = find(dist <= tol^2);                       % segment indices
   
else
   
   % With lots of segments, compute the distances one at a time, and take the
   % penalty for looping and memory allocations.
   r = []; c = [];
   for i=1:n
      for j=i+1:n
         dist = (lat(i1(i)) - lat(i2(j))).^2 + (lon(i1(i)) - lon(i2(j))).^2;
         if dist <= tol;
            r = [r;i];
            c = [c;j];
         end
      end
   end
   
end

% append segment pairs to running count
[rcsave,direction]=deal([rcsave;[r c]],[direction; repmat(dirflag,length(r),1)]);




