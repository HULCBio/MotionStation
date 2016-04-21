/* $Id: dbi_sql.h,v 10.1 1998/08/14 20:17:38 timbo Exp $
 *
 * Copyright (c) 1997  Tim Bunce  England
 *
 * See COPYRIGHT section in DBI.pm for usage and distribution rights.
 */


/* Some core SQL CLI standard (ODBC) declarations		*/
#ifndef SQL_SUCCESS	/* don't clash with ODBC based drivers	*/

/* Standard SQL datatypes (ANSI/ODBC type numbering)		*/
#define	SQL_ALL_TYPES		0
#define	SQL_CHAR		1
#define	SQL_NUMERIC		2
#define	SQL_DECIMAL		3
#define	SQL_INTEGER		4
#define	SQL_SMALLINT		5
#define	SQL_FLOAT		6
#define	SQL_REAL		7
#define	SQL_DOUBLE		8
#define SQL_DATE		9	/* SQL_DATETIME in CLI!	*/
#define SQL_TIME		10
#define SQL_TIMESTAMP		11
#define	SQL_VARCHAR		12

/* Other SQL datatypes (ODBC type numbering)			*/
#define SQL_LONGVARCHAR		(-1)
#define SQL_BINARY		(-2)
#define SQL_VARBINARY		(-3)
#define SQL_LONGVARBINARY	(-4)
#define SQL_BIGINT		(-5)	/* too big for IV	*/
#define SQL_TINYINT		(-6)


/* Main return codes						*/
#define	SQL_ERROR			(-1)
#define	SQL_SUCCESS			0
#define	SQL_SUCCESS_WITH_INFO		1
#define	SQL_NO_DATA_FOUND		100

#endif	/*	SQL_SUCCESS	*/

/* Handy macro for testing for success and success with info.		*/
/* BEWARE that this macro can have side effects since rc appears twice!	*/
/* So DONT use it as if(SQL_ok(func(...))) { ... }			*/
#define SQL_ok(rc)	((rc)==SQL_SUCCESS || (rc)==SQL_SUCCESS_WITH_INFO)


/* end of dbi_sql.h */
