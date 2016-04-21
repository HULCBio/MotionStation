function [drlat,drlong,drtime]=dreckon(waypoints,time,speed,spdtimes)

% DRECKON  Computes dead reckoning (DR) positions for a track
%
%  [drlat,drlong,drtime] = DRECKON(waypoints,time,speed) takes
%  the latitudes and waypoints in navigational track format,
%  the first point of which is presumably a navigational fix, and
%  the time of that fix, as well as ordered speeds in knots
%  (nautical miles per hour), returns the positions and times
%  associated with required dead reckoning (DR) in accordance with
%  standard navigational practice.  Speed is a scalar, in which case
%  it applies throughout, or is provided for each leg (a vector of same
%  length as lat, minus 1), in which case speed changes coincide with
%  course changes.
%
%  [drlat,drlong,drtime] = DRECKON(waypoints,time,speed,spdtimes)
%  associates the vector spdtimes with a vector input speed.
%  Spdtimes are elapsed times after the fix time at which a given
%  speed order ends (i.e., speed(1) would start at time and end at
%  time + spdtimes(1).  No DR will be given for positions past the
%  last waypoint in the track, nor, if given, past the last time
%  in spdtimes.
%
%  Note:  This is a navigational function -- all lats/longs are in
%         degrees, all distances in nautical miles, all times
%         in hours, and all speeds in knots (nautical miles per hour).
%
%  See also NAVFIX, GCWAYPTS, TRACK, CROSSFIX

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:15:59 $


if nargin < 3
    error('Incorrect number of arguments')
elseif nargin == 3
    spdtimes = [];
end



% DR's are required when:
%		1) There is a course change (i.e., a new track leg)
%		2) There is a speed change
%		3) Every hour on the hour
%
%	And, in practice, at other times not relevant to this function
%  DR's will not be taken less than some tolerance level in time
%  apart;  three minutes is common.

tol=1/20;

% Strategy is to pack up required dr times and interp1 for distances,
% then loop through the times, reckon('rh')'ing from point to point

if (size(waypoints,2)~=2)
	 error('Navigational track format required for waypoints')

elseif (size(waypoints,1)<2)

	error('At least 2 waypoints are required')

end

lat=waypoints(:,1);
long=waypoints(:,2);

if any([min(size(speed))    min(size(time))]    ~= 1) | ...
       any([ndims(speed) ndims(time)] > 2)
	    error('Speed and time must be a scalar or vector')

elseif any([~isreal(lat) ~isreal(long) ~isreal(time) ~isreal(speed) ~isreal(spdtimes)])
        warning('Imaginary parts of complex arguments ignored')
		lat = real(lat);    long = real(long);
		time = real(time);  speed = real(speed);
		spdtimes = real(spdtimes);
end

%  Ensure column vectors

lat   = lat(:);       long = long(:);
speed = speed(:);     time = time(:);
if ~isempty(spdtimes)
	if any(diff(spdtimes)<=0)
			error('Times for speed changes must be in time-increasing order')
	end
  spdtimes = spdtimes(:);
end


crschng=0;
[course,dist]=legs(lat,long,'rh');

if isempty(spdtimes)  % derived speed times

	if max(size(speed)) == 1  % constant speed
		spdtimes=time+cumsum(dist)/speed; % clock time at end of each leg
		speed=speed*ones(size(dist));  % expand speed out to vector, 1 for each leg

	elseif length(speed)==(size(lat,1)-1) % you have a speed for each leg
		spdtimes=cumsum(dist./speed)+time; % clock time at end of each leg

	else
		error('Speed must be a scalar or matched to times or track legs')
	end
crstimes=spdtimes;  % you will dr at each speed time.  More points may follow.

elseif any(size(speed) ~= size(spdtimes))  % you input speed times
		error('To be matched, speeds and times must be of same size')

else
	crschng=1; % Flag indicating to watch for course changes
				% i.e., they are not already in speed times as would happen
				% if no spdtimes had been input
	spdtimes=time+spdtimes;
end

if length(spdtimes)>1
	intervals=[spdtimes(1)-time;diff(spdtimes)]; % not clock times but intervals
else
	intervals=spdtimes(1)-time;
end

spddists=cumsum(speed.*intervals);  % distance traveled in each interval


if crschng	% you haven't included course changes yet
	cumdist=cumsum(dist); % these are the cumulative distances travelled at each course change

	% Don't let speed orders take you past defined track
	last1=max(find(spddists<cumdist(length(cumdist))));

	if isempty(last1) % first spddist beyond track, just go to end of track, constant (first) speed

		spddists=cumdist(length(cumdist));
		spdtimes=time+spddists/speed(1);

	elseif last1==length(spddists) % track extends beyond spddists, stop at last spddists

		last2=max(find(cumdist<spddists(length(spddists)))); %don't let track take you past last defined speed time

		if isempty(last2) % first course change is after last speed time, no course changes apply

				cumdist=[];

		else % there are course changes before the last speed time

				cumdist=cumdist(1:last2);
		end

	else  %some interior spddist segment contains end of track

		spddists=[spddists(1:last1);cumdist(length(cumdist))];
		timeseg=(cumdist(length(cumdist))-spddists(last1))/speed(last1+1);
		spdtimes=[spdtimes(1:last1);spdtimes(last1)+timeseg];

	end

	% interpolate the times of the course changes under the speed/time profile.
	% if cumdist is empty, so will be crstimes

	crstimes=interp1([0;spddists],[time;spdtimes],cumdist,'linear');

	% pack up times and distances of dr events -- will sort later
	spdtimes=[crstimes;spdtimes];
	spddists=[cumdist;spddists];
end

% Sort dr events in time order.  Saving kndx allows reordering the associated distances as well
[spdtimes,kndx]=sort(spdtimes);
spddists=spddists(kndx);

% remove duplicate speed times -- will cause problems later in interp
qndx=find(diff(spdtimes)<eps);
spdtimes(qndx)=[];
spddists(qndx)=[];

% There are also every-hour-on-the-hour dr requirements.
% hrtimes is all whole hours during this period.

hrtimes=(ceil(time+tol):floor(spdtimes(length(spdtimes))-tol))';

% Pack up and reorder with the other dr events into drtime
drtime=sort([spdtimes;hrtimes]);

% Where ever two dr events are within the tolerance (3 minutes), remove one
jndx=find(diff(drtime)<tol);
while ~isempty(jndx)
	drtime(jndx(1))=[];
	jndx=find(diff(drtime)<tol);
end

% Find the distances associated with dr events.  Many of these will coincide
% exactly with spddists, which by now are the distances associated with speed
% and course changes.  This adds hrtimes and leaves out any distances for points
% removed for tolerance (3 minute) reasons


drdist=interp1([time;spdtimes],[0;spddists],drtime,'linear');

% The distances for each between-dr segment

distseg=[drdist(1);diff(drdist)];

% we're going to walk through the track.  Start at the initial point
startlat=lat(1);
startlong=long(1);

for i=1:length(drtime)

	% which course leg are you on
	indx=find(crstimes<drtime(i));
	if isempty(indx) % you're on the first course leg
		indx=0;
	end
	% since the crstimes was less than the drtime, you want the course for
	% the crstimes which comes immediately after the drtime.  Remember,
	% crstimes is the time a course ends.

	indx=indx+1;
	steer=course(max(indx));
	[drlat(i,1),drlong(i,1)]=reckon('rh',startlat,startlong,...
	                                distseg(i)/60,steer,'degrees');
	startlat=drlat(i);
	startlong=drlong(i);
end

%  Set the output vector if necessary

if nargout < 3;  drlat = [drlat drlong drtime];  end
