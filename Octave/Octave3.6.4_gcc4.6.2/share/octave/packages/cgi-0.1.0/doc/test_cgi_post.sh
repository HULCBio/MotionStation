export DOCUMENT_ROOT=/var/www 
export REQUEST_METHOD=POST 
export CONTENT_TYPE=application/x-www-form-urlencoded
export CONTENT_LENGTH=54

echo "x=50%2C1,2&y=1,2,3&len=10&name=test&field=random_field" | ./test_cgi_post.m 
