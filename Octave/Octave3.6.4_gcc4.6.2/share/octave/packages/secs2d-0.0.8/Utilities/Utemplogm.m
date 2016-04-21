function T = Utemplogm(t1,t2)

T = zeros(size(t2));

sing     = abs(t2-t1)< 100*eps ;
T(sing)  = (t2(sing)+t1(sing))/2;
T(~sing) = (t2(~sing)-t1(~sing))./log(t2(~sing)./t1(~sing));

