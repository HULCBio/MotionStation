## s = boxplot_data (x)
##
## s.quantiles : quantiles [0.05, 0.25, 0.5, 0.75, 0.95] of x
## s.outliers  : 
function s = boxplot_data (x)

C = columns (x);
R = rows (x);

if ! any (isnan (x(:)))

  sx = sort (x);

  ifloor = 1+floor([0.05 0.25 0.50 0.75 0.95]*(R-1));
  iceil =  1+ceil ([0.05 0.25 0.50 0.75 0.95]*(R-1));

  s.quantiles = (sx(ifloor,:) + sx(iceil,:))/2;

  stdx =  nanstd (x); 
  meanx = nanmean (x);

  s.mean = meanx;
  s.std =  stdx;

  for i = 1:C
    iout = find (abs (x(:,i)-meanx(i)) > 3*stdx(i));
    s.outliers{i} = x(iout,i);
  end
else				# There are NaNs

  sx = sort (x);
 
  nok = sum (!isnan (x));

  ifloor = 1+floor([0.05 0.25 0.50 0.75 0.95]'*(nok-1));
  iceil =  1+ceil ([0.05 0.25 0.50 0.75 0.95]'*(nok-1));

  s.quantiles = nan (5,C);
  for i = 1:C
    if nok(i)
      s.quantiles(:,i) = (sx(ifloor(:,i),i)+sx(iceil(:,i),i))/2;
    end

    iout = find (abs (x(:,i)-meanx(i)) > 3*stdx(i));
    s.outliers{i} = x(iout,i);
  end
end
