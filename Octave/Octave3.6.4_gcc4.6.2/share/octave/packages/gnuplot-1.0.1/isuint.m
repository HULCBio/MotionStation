## yesno = isuint (x)
function yesno = isuint (x)

typ = typeinfo (x);
yesno = length (typ) > 3 && strcmp (typ(1:4), "uint");