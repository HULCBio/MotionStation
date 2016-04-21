function msh=Umsh2pdetool(filename);

##
##
##  loadgmshmesh(filename);
##
##

awk_command = "BEGIN {  filename = ARGV[1] ; gsub(/\\./,""_"",filename) }\n\
\n\
/\\$NOD/,/\\$ENDNOD/ { \n\
    if ( FNR>2 ) \n\
    {  \n\
	if($0 ~ /^[^\\$]/  )  \n\
	{\n\
	    print ""p ( "" $1 "" ,:) = ["" $2 "" ""  $3""];""  > filename ""_p.m"" \n\
	}\n\
    } \n\
} \n\
\n\
/\\$ELM/,/\\$ENDNELM/ { \n\
    if (  $1 ~ /\\$ELM/   )\n\
    {\n\
	gsub(/\\$ELM/,""t=["")\n\
	print > filename ""_t.m""\n\
	gsub(/t=\\[/,""e=["")\n\
	print > filename ""_e.m""\n\
\n\
    } else if  ($1 ~ /\\$ENDELM/ ){\n\
		gsub(/\\$ENDELM/,""];"")\n\
		print > filename ""_t.m""\n\
		print > filename ""_e.m""\n\
    }\n\
    else if ( $2 == ""2"" )\n\
    {\n\
	print ( $6 "" "" $7 "" "" $8 "" "" $4)  > filename ""_t.m"" \n\
    }\n\
    else if ( $2 == ""1"" )\n\
    {\n\
	print ( $6 "" "" $7 "" 0 0 "" $4 "" 0 0"")  > filename ""_e.m"" \n\
    }\n\
    else if ( $2 == ""9"" )\n\
    {\n\
     print ( $6 "" "" $7 "" "" $8 "" "" $9 "" "" $10 "" "" $11 "" "" \
	    $4)  > filename ""_t.m"" \n\
    }\n\
    else if ( $2 == ""8"" )\n\
    {\n\
     print ( $6 "" "" $7 "" "" $8 "" 0 "" $4)  > filename ""_e.m"" \n\
    }\n\
}\n\
\n\
{ }"

system(["awk '" awk_command "' " filename ".msh"]);
eval([ filename "_msh_p"]);
eval([ filename "_msh_e"]);
eval([ filename "_msh_t"]);


msh=struct("p",p',"t",t',"e",e');