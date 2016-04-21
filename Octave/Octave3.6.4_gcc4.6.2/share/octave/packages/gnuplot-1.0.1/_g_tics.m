## gnuplot_tic_setting_command = _g_tics (values, labels, ...)
## options:
## "x", "y", "z", "x2", "y2", "cb" axis on which tics go
## "tpl"        default 'tpl = "set %stics (%s)";'
## "fmt"        default '%3.2f' 
## "major"      default 1:length (values)
function s = _g_tics (values, labels, varargin)

N = length (values);

side = "x";
tpl = "set %stics (%s)";
fmt = "% g";

major = 1:N;

if nargin < 2, labels = values; end
assert (length (labels) == N);

n = 2;
while n<nargin
  n++;
  opt = varargin{n-2};
  assert (ischar (opt))
  if opt(1) == "%", fmt = opt; continue; end
  switch opt
    case "x",     side =  "x";
    case "y",     side =  "y";
    case "z",     side =  "z";
    case "x2",    side =  "x2";
    case "y2",    side =  "y2";
    case "cb",    side =  "cb";
    case "tpl",   tpl =   varargin{++n-2};
    case "fmt",   fmt =   varargin{++n-2};
    case "major", major = varargin{++n-2};
    otherwise,
      error ("Unknown option '%s'",opt);
  end
end

if ! (length (major) == N && all (major == 0 | major == 1) \
      || all (major >= 1 & major <= N & major == round (major)))
  major
  values
  "Problem w/ major tic argument. Please fix"
  keyboard
end
if length (major) == N && all (major == 0 | major == 1)
  #tmp = zeros(1,N);
  #tmp(major) = 1;
				#major = tmp;
  major = find (major);
end

s1 = sprintf (["\"",fmt,"\" %f, "],[labels(major)(:) values(major)(:)]')(1:end-2);



minor = setdiff (1:N, major);
if ! isempty (minor)
  s2 = "";
  s2 = sprintf ("\"\" %f, ",values(minor))(1:end-2);
  s1 = [s1, ", ", s2];
end


s = sprintf (tpl, side, s1);