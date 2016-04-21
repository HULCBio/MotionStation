/* Hej, Emacs, this is -*- C -*- mode!

   $Id: mysql.xs 1.1 Tue, 30 Sep 1997 01:28:08 +0200 joe $

   Copyright (c) 1997 Jochen Wiedmann

   You may distribute under the terms of either the GNU General Public
   License or the Artistic License, as specified in the Perl README file,
   with the exception that it cannot be placed on a CD-ROM or similar media
   for commercial distribution without the prior approval of the author.

*/

#include "dbdimp.h"
#include "../dbd/constants.h"


/* --- Variables --- */


DBISTATE_DECLARE;


static SV* _quote(SV* dbh, SV* str) {
    SV* result;
    char* ptr;
    char* sptr;
    STRLEN len;

    if (!SvOK(str)) {
        static SV* nullStrSv = NULL;
	if (!nullStrSv) {
	    nullStrSv = newSVpv("NULL", 4);
	}
	SvREFCNT_inc(nullStrSv);
	result = nullStrSv;
    } else {
        ptr = SvPV(str, len);
	result = newSV(len*2+3);
	sptr = SvPVX(result);

	*sptr++ = '\'';
	while (len--) {
	    switch (*ptr) {
	      case '\'':
		*sptr++ = '\\';
		*sptr++ = '\'';
		break;
	      case '\\':
		*sptr++ = '\\';
		*sptr++ = '\\';
		break;
#if defined(DBD_MYSQL)
	      case '\n':
		*sptr++ = '\\';
		*sptr++ = 'n';
		break;
	      case '\r':
		*sptr++ = '\\';
		*sptr++ = 'r';
		break;
	      case '\0':
		*sptr++ = '\\';
		*sptr++ = '0';
		break;
#endif
	      default:
		*sptr++ = *ptr;
		break;
	    }
	    ++ptr;
	}
	*sptr++ = '\'';
	SvPOK_on(result);
	SvCUR_set(result, sptr - SvPVX(result));
	*sptr++ = '\0';  /*  Never hurts NUL terminating a Perl
			  *	 string ...
			  */
    }
    return result;
}


MODULE = DBD::mysql	PACKAGE = DBD::mysql

INCLUDE: mysql.xsi

MODULE = DBD::mysql	PACKAGE = DBD::mysql

double
constant(name, arg)
    char* name
    char* arg
  CODE:
    RETVAL = mymsql_constant(name, arg);
  OUTPUT:
    RETVAL

#if defined(DBD_MSQL) && defined(IDX_TYPE) && defined(HAVE_STRPTIME)

char*
unixtimetodate(package = Package, clock)
    time_t clock
  PROTOTYPE: $$
  CODE:
    RETVAL = msqlUnixTimeToDate(clock);
  OUTPUT:
    RETVAL

char*
unixtimetotime(package = Package, clock)
    time_t clock
  PROTOTYPE: $$
  CODE:
    RETVAL = msqlUnixTimeToTime(clock);
  OUTPUT:
    RETVAL

time_t
datetounixtime(package = Package, clock)
  PROTOTYPE: $$
  CODE:
    RETVAL = msqlDateToUnixTime(clock);
  OUTPUT:
    RETVAL

time_t
timetounixtime(package = Package, clock)
  PROTOTYPE: $$
  CODE: $$
    RETVAL = msqlTimeToUnixTime(clock);
  OUTPUT:
    RETVAL

#endif /* defined(DBD_MSQL) && defined(IDX_TYPE) && defined(HAVE_STRPTIME) */


MODULE = DBD::mysql	PACKAGE = DBD::mysql::dr

void
_ListDBs(drh, host, port=NULL)
    SV *        drh
    char *	host
    char *      port
  PPCODE:
{
#if defined(DBD_MYSQL)
    MYSQL mysql;
    dbh_t sock = &mysql;
#elif defined(DBD_MSQL)
    dbh_t sock;
#endif
    if (MyConnect(&sock,NULL,host,port,NULL,NULL,NULL,NULL)) {
        result_t res;
        row_t cur;
        res = MyListDbs(sock);
        if (!res) {
            do_error(drh, MyErrno(sock, JW_ERR_LIST_DB), MyError(sock));
        } else {
            EXTEND(sp, MyNumRows(res));
	    while ((cur = MyFetchRow(res))) {
	        PUSHs(sv_2mortal((SV*)newSVpv(cur[0], strlen(cur[0]))));
	    }
	    MyFreeResult(res);
        }
        MyClose(sock);
    }
}


void
_admin_internal(drh,dbh,command,dbname=NULL,host=NULL,port=NULL,user=NULL,password=NULL)
    SV* drh
    SV* dbh
    char* command
    char* dbname
    char* host
    char* port
    char* user
    char* password
  PPCODE:
    {
        dbh_t sock;
	int result;
#if defined(DBD_MYSQL)
	MYSQL mysql;
	sock = &mysql;
#endif

	/*
	 *  Connect to the database, if required.
	 */
	if (SvOK(dbh)) {
	    D_imp_dbh(dbh);
	    sock = imp_dbh->svsock;
	} else {
	    if (!MyConnect(&sock,NULL,host,port,user,password,NULL,NULL)) {
	        do_error(drh, MyErrno(sock, JW_ERR_CONNECT), MyError(sock));
		XSRETURN_NO;
	    }
       }
 
       if (strEQ(command, "shutdown")) {
	   result = MyShutdown(sock);
       } else if (strEQ(command, "reload")) {
	   result = MyReload(sock);
       } else if (strEQ(command, "createdb")) {
	   result = MyCreateDb(sock, dbname);
       } else if (strEQ(command, "dropdb")) {
          result = MyDropDb(sock, dbname);
       } else {
	  croak("Unknown command: %s", command);
       }
#if defined(DBD_MYSQL)
       if (result) {
#elif defined(DBD_MSQL)
       if (result < 0) {
#endif
	   do_error(SvOK(dbh) ? dbh : drh, MyErrno(sock, JW_ERR_LIST_DB),
		    MyError(sock));
	   result = 0;
       } else {
	   result = 1;
       }
       if (SvOK(dbh)) {
	   MyClose(sock);
       }
       if (result) { XSRETURN_YES; } else { XSRETURN_NO; }
   }


MODULE = DBD::mysql    PACKAGE = DBD::mysql::db


#if defined(DBD_MYSQL)

int
_InsertID(dbh)
    SV *	dbh
  CODE:
    D_imp_dbh(dbh);
    MYSQL *sock = (MYSQL*) imp_dbh->svsock;
    EXTEND( sp, 1 );
    RETVAL = mysql_insert_id(sock);
  OUTPUT:
    RETVAL

#endif

void
_ListDBs(dbh)
    SV*	dbh
  PPCODE:
    D_imp_dbh(dbh);
    result_t res;
    row_t cur;
    res = MyListDbs(imp_dbh->svsock);
    if (!res  &&  (!MyReconnect(imp_dbh->svsock, dbh)
		   ||  !(res = MyListDbs(imp_dbh->svsock)))) {
        do_error(dbh, MyErrno(imp_dbh->svsock, JW_ERR_LIST_DB),
		 MyError(imp_dbh->svsock));
    } else {
        EXTEND(sp, MyNumRows(res));
	while ((cur = MyFetchRow(res))) {
	    PUSHs(sv_2mortal((SV*)newSVpv(cur[0], strlen(cur[0]))));
	}
	MyFreeResult(res);
    }


void
_ListTables(dbh)
    SV *	dbh
    PPCODE:
    D_imp_dbh(dbh);
    result_t res;
    row_t cur;
    res = MyListTables(imp_dbh->svsock);
    if (!res  &&  (!MyReconnect(imp_dbh->svsock, dbh)
		   ||  !(res = MyListTables(imp_dbh->svsock)))) {
        do_error(dbh, MyErrno(imp_dbh->svsock, JW_ERR_LIST_TABLES),
		 MyError(imp_dbh->svsock));
    } else {
        while ((cur = MyFetchRow(res))) {
            XPUSHs(sv_2mortal((SV*)newSVpv( cur[0], strlen(cur[0]))));
        }
        MyFreeResult(res);
    }
 

void
do(dbh, statement, attr=Nullsv, ...)
    SV *        dbh
    SV *	statement
    SV *        attr
  PROTOTYPE: $$;$@      
  CODE:
{
    D_imp_dbh(dbh);
    struct imp_sth_ph_st* params = NULL;
    int numParams = 0;
    result_t cda = NULL;
    int retval;

    if (items > 3) {
       	/*  Handle binding supplied values to placeholders	     */
	/*  Assume user has passed the correct number of parameters  */
	int i;
	numParams = items-3;
	Newz(0, params, sizeof(*params)*numParams, struct imp_sth_ph_st);
	for (i = 0;  i < numParams;  i++) {
	    params[i].value = ST(i+3);
	    params[i].type = SQL_VARCHAR;
	}
    }
    retval = dbd_st_internal_execute(dbh, statement, attr, numParams,
				     params, &cda, imp_dbh->svsock, 0);
    Safefree(params);
    if (cda) {
	MyFreeResult(cda);
    }
    /* remember that dbd_st_execute must return <= -2 for error	*/
    if (retval == 0)		/* ok with no rows affected	*/
	XST_mPV(0, "0E0");	/* (true but zero)		*/
    else if (retval < -1)	/* -1 == unknown number of rows	*/
	XST_mUNDEF(0);		/* <= -2 means error   		*/
    else
	XST_mIV(0, retval);	/* typically 1, rowcount or -1	*/
}


SV*
ping(dbh)
    SV* dbh;
  PROTOTYPE: $
  CODE:
    {
        int result;
	D_imp_dbh(dbh);
#if defined(DBD_MYSQL)
#if defined(MYSQL_VERSION_ID)  &&  (MYSQL_VERSION_ID >= 32203)
	result = (mysql_ping(imp_dbh->svsock) == 0);
	if (!result  &&  MyReconnect(imp_dbh->svsock, dbh)) {
	    result = (mysql_errno(imp_dbh->svsock) == 0);
	}
#else
	(void) mysql_stat(imp_dbh->svsock);
	result = (mysql_errno(imp_dbh->svsock) == 0);
	if (!result  &&  MyReconnect(imp_dbh->svsock, dbh)) {
	    (void) mysql_stat(imp_dbh->svsock);
	    result = (mysql_errno(imp_dbh->svsock) == 0);
	}
#endif
#elif defined(DBD_MSQL)
	result = TRUE;
#endif
	RETVAL = boolSV(result);
    }
  OUTPUT:
    RETVAL



void
quote(dbh, str)
    SV* dbh
    SV* str
  PROTOTYPE: $$
  PPCODE: 
    EXTEND(sp, 1);
    ST(0) = sv_2mortal(_quote(dbh, str));
    XSRETURN(1);


#if defined(DBD_MSQL) && defined(IDX_TYPE)

void
getsequenceinfo(dbh, table)
    SV* dbh
    char* table
  PROTOTYPE: $$
  PPCODE:
  {
    m_seq* seq;
    D_imp_dbh(dbh);
    seq = msqlGetSequenceInfo(imp_dbh->svsock, table);
    if (!seq) {
        do_error(dbh, MyErrno(sock, JW_ERR_SEQUENCE), MyError(sock));
	XSRETURN_UNDEF;
    } else {
        EXTEND(sp, 2);
	ST(0) = sv_2mortal(newSViv(seq->step));
	ST(1) = sv_2mortal(newSViv(seq->value));
	XSRETURN(2);
	Safefree(seq);
    }
  }

#endif /* defined(DBD_MSQL) && defined(IDX_TYPE) */

MODULE = DBD::mysql    PACKAGE = DBD::mysql::st

int
dataseek(sth, pos)
    SV* sth
    int pos
  PROTOTYPE: $$
  CODE:
{
    D_imp_sth(sth);
    if (imp_sth->cda) {
        MyDataSeek(imp_sth->cda, pos);
	RETVAL = 1;
    } else {
        RETVAL = 0;
	do_error(sth, JW_ERR_NOT_ACTIVE, "Statement not active");
    }
}
  OUTPUT:
    RETVAL
