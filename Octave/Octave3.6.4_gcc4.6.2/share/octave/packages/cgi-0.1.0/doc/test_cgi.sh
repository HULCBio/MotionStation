export DOCUMENT_ROOT=/var/www 
export REQUEST_METHOD=GET
export QUERY_STRING="x=50%2C1,2&y=1,2,3&len=10&name=test&field=random_field" 

octave -q <<EOF
CGI = cgi();
disp(cgi.form.y)
EOF