/* $Id: DBIXS.h,v 10.8 1999/05/09 01:14:04 timbo Exp $
 *
 * Copyright (c) 1994, 1995, 1996, 1997, 1998, 1999  Tim Bunce  England
 *
 * See COPYRIGHT section in DBI.pm for usage and distribution rights.
 */

/* DBI Interface Definitions for DBD Modules */

#ifndef DBIXS_VERSION				/* prevent multiple inclusion */

#ifndef DBIS
#define DBIS	dbis	/* default name for dbistate_t variable	*/
#endif

/* first pull in the standard Perl header files for extensions	*/
#define PERL_POLLUTE
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef debug		/* causes problems with DBIS->debug	*/
#undef debug
#endif

/* Perl backwards compatibility definitions */
#ifndef boolSV	/* added in perl5.004		*/
#define boolSV(bool) ((bool) ? &sv_yes : &sv_no) 
#endif

#ifndef dTHR	/* added in perl5.004_50	*/
#define dTHR typedef int _thr_DBI_dummy
#endif


/* DBI SQL_* type definitions */
#include "dbi_sql.h"


/* The DBIXS_VERSION value will be incremented whenever new code is
 * added to the interface (this file) or significant changes are made.
 * It's primary goal is to allow newer drivers to compile against an
 * older installed DBI. This is mainly an issue whilst the API grows
 * and learns from the needs of various drivers.  See also the
 * DBISTATE_VERSION macro below. You can think of DBIXS_VERSION as
 * being a compile time check and DBISTATE_VERSION as a runtime check.
 */
#define DBIXS_VERSION 93

#ifdef NEED_DBIXS_VERSION
#if NEED_DBIXS_VERSION > DBIXS_VERSION
error You_need_to_upgrade_your_DBI_module_before_building_this_driver
#endif
#else
#define NEED_DBIXS_VERSION DBIXS_VERSION
#endif


#if defined(USE_THREADS) && !defined(DBI_NO_THREADS)
#define DBI_USE_THREADS
#define DBI_LOCK	MUTEX_LOCK(DBIS->mutex)
#define DBI_UNLOCK	MUTEX_UNLOCK(DBIS->mutex)
#define dbi_mutex perl_mutex
#define dbi_cond  perl_cond
#else
#define DBI_LOCK
#define DBI_UNLOCK
#define dbi_mutex void
#define dbi_cond  void
#endif


/* forward declaration of 'DBI Handle Common Data', see below		*/

/* implementor needs to define actual struct { dbih_??c_t com; ... }*/
typedef struct imp_drh_st imp_drh_t;	/* driver			*/
typedef struct imp_dbh_st imp_dbh_t;	/* database			*/
typedef struct imp_sth_st imp_sth_t;	/* statement			*/
typedef struct imp_fdh_st imp_fdh_t;	/* field descriptor		*/
typedef struct imp_xxh_st imp_xxh_t;	/* any (defined below)		*/



/* --- DBI Handle Common Data Structure (all handles have one) ---	*/

/* Handle types. Code currently assumes child = parent + 1.		*/
#define DBIt_DR		1
#define DBIt_DB		2
#define DBIt_ST		3
#define DBIt_FD		4

/* component structures */

typedef struct dbih_com_std_st {
    U32  flags;
    int  call_depth;	/* used by DBI to track nested calls (int)	*/
    U16  type;		/* DBIt_DR, DBIt_DB, DBIt_ST			*/
    SV   *my_h;		/* copy of outer handle HV (not refcounted)	*/
    SV   *parent_h;	/* parent inner handle (RV(HV)) (r.c.inc)	*/
    imp_xxh_t *parent_com;	/* parent com struct shortcut		*/
    dbi_cond  *thr_cond;/* condition for thread access (see dispatch)	*/

    HV   *imp_stash;	/* who is the implementor for this handle	*/
    SV   *imp_data;	/* optional implementors data (for perl imp's)	*/

    I32  kids;		/* count of db's for dr's, st's for db's etc	*/
    I32  active_kids;	/* kids which are currently DBIc_ACTIVE		*/
    U32  thr_user;	/* thread id currently using the handle		*/
    void *spare2;
} dbih_com_std_t;

typedef struct dbih_com_attr_st {
    /* These are copies of the Hash values (ref.cnt.inc'd)	*/
    /* Many of the hash values are themselves references	*/
    SV *Debug;
    SV *State;		/* Standard SQLSTATE, 5 char string	*/
    SV *Err;		/* Native engine error code		*/
    SV *Errstr;		/* Native engine error message		*/
    SV *Handlers;
    U32  LongReadLen;	/* auto read length for long/blob types	*/
    I32  spare1;
} dbih_com_attr_t;


struct dbih_com_st {	/* complete core structure (typedef'd above)	*/
    dbih_com_std_t	std;
    dbih_com_attr_t	attr;
};

/* This 'implementors' type the DBI defines by default as a way to	*/
/* refer to the imp_??h data of a handle without considering its type.	*/
struct imp_xxh_st { struct dbih_com_st com; };

/* Define handle-type specific structures for implementors to include	*/
/* at the start of their private structures.				*/

typedef struct {		/* -- DRIVER --				*/
    dbih_com_std_t	std;
    dbih_com_attr_t	attr;
    HV          *cached_kids;	/* $drh->connect_cached(...)		*/
} dbih_drc_t;

typedef struct {		/* -- DATABASE --			*/
    dbih_com_std_t	std;	/* \__ standard structure		*/
    dbih_com_attr_t	attr;	/* /   plus... (nothing else right now)	*/
    HV          *cached_kids;	/* $dbh->prepare_cached(...)		*/
} dbih_dbc_t;

typedef struct {		/* -- STATEMENT --			*/
    dbih_com_std_t	std;	/* \__ standard structure		*/
    dbih_com_attr_t	attr;	/* /   plus ...				*/

    int 	num_params;	/* number of placeholders		*/
    int 	num_fields;	/* NUM_OF_FIELDS, must be set		*/
    AV  	*fields_svav;	/* special row buffer (inc bind_cols)	*/
    IV		row_count;	/* incremented by get_fbav()		*/

    AV		*fields_fdav;	/* not used yet, may change */

    I32  spare1;
    void *spare2;
} dbih_stc_t;


/* XXX THIS STRUCTURE SHOULD NOT BE USED */
typedef struct {		/* -- FIELD DESCRIPTOR --		*/
    dbih_com_std_t	std;	/* standard structure (not fully setup)	*/

    /* core attributes (from DescribeCol in ODBC)		*/
    char *col_name;		/* see dbih_make_fdsv		*/
    I16   col_name_len;
    I16   col_sql_type;
    I16   col_precision;
    I16   col_scale;
    I16   col_nullable;

    /* additional attributes (from ColAttributes in ODBC)	*/
    I32   col_length;
    I32   col_disp_size;

    I32  spare1;
    void *spare2;
} dbih_fdc_t;


#define _imp2com(p,f)      	((p)->com.f)

#define DBIc_FLAGS(imp)		_imp2com(imp, std.flags)
#define DBIc_TYPE(imp)		_imp2com(imp, std.type)
#define DBIc_CALL_DEPTH(imp)	_imp2com(imp, std.call_depth)
#define DBIc_MY_H(imp)  	_imp2com(imp, std.my_h)
#define DBIc_PARENT_H(imp)  	_imp2com(imp, std.parent_h)
#define DBIc_PARENT_COM(imp)  	_imp2com(imp, std.parent_com)
#define DBIc_THR_COND(imp)  	_imp2com(imp, std.thr_cond)
#define DBIc_THR_USER(imp)  	_imp2com(imp, std.thr_user)
#define DBIc_THR_USER_NONE  	(~(unsigned long)0)
#define DBIc_IMP_STASH(imp)  	_imp2com(imp, std.imp_stash)
#define DBIc_IMP_DATA(imp)  	_imp2com(imp, std.imp_data)
#define DBIc_KIDS(imp)  	_imp2com(imp, std.kids)
#define DBIc_ACTIVE_KIDS(imp)  	_imp2com(imp, std.active_kids)

#define DBIc_DEBUG(imp)		(_imp2com(imp, attr.Debug))
#define DBIc_DEBUGIV(imp)	SvIV(DBIc_DEBUG(imp))
#define DBIc_STATE(imp)		SvRV(_imp2com(imp, attr.State))
#define DBIc_ERR(imp)		SvRV(_imp2com(imp, attr.Err))
#define DBIc_ERRSTR(imp)	SvRV(_imp2com(imp, attr.Errstr))
#define DBIc_HANDLERS(imp)	SvRV(_imp2com(imp, attr.Handlers))
#define DBIc_LongReadLen(imp)  	_imp2com(imp, attr.LongReadLen)
#define DBIc_LongReadLen_init	80	/* may change */

/* handle sub-type specific fields						*/
/*	dbh	*/
#define DBIc_CACHED_KIDS(imp)  	_imp2com(imp, cached_kids)
/*	sth	*/
#define DBIc_NUM_FIELDS(imp)  	_imp2com(imp, num_fields)
#define DBIc_NUM_PARAMS(imp)  	_imp2com(imp, num_params)
#define DBIc_NUM_PARAMS_AT_EXECUTE	-9 /* see Driver.xst */
#define DBIc_ROW_COUNT(imp)  	_imp2com(imp, row_count)
#define DBIc_FIELDS_AV(imp)  	_imp2com(imp, fields_svav)
#define DBIc_FDESC_AV(imp)  	_imp2com(imp, fields_fdav)
#define DBIc_FDESC(imp, i)  	((imp_fdh_t*)(void*)SvPVX(AvARRAY(DBIc_FDESC_AV(imp))[i]))

#define DBIcf_COMSET	  0x0001	/* needs to be clear'd before free'd	*/
#define DBIcf_IMPSET	  0x0002	/* has implementor data to be clear'd	*/
#define DBIcf_ACTIVE	  0x0004	/* needs finish/disconnect before clear	*/
#define DBIcf_IADESTROY	  0x0008	/* do DBIc_ACTIVE_off before DESTROY	*/
#define DBIcf_WARN  	  0x0010	/* warn about poor practice etc  	*/
#define DBIcf_COMPAT  	  0x0020	/* compat/emulation mode (eg oraperl)	*/

#define DBIcf_ChopBlanks  0x0040	/* rtrim spaces from fetch char columns	*/
#define DBIcf_RaiseError  0x0080	/* throw exception (croak) on error	*/
#define DBIcf_PrintError  0x0100	/* warn() on error			*/
#define DBIcf_AutoCommit  0x0200	/* dbh only. used by drivers		*/
#define DBIcf_LongTruncOk 0x0400	/* truncation to LongReadLen is okay	*/
#define DBIcf_MultiThread 0x0800	/* allow multiple threads to enter	*/
#define DBIcf_Taint       0x1000	/* taint fetched data			*/

#define DBIcf_INHERITMASK			/* what NOT to pass on to children */	\
	(U32)( DBIcf_COMSET | DBIcf_IMPSET | DBIcf_ACTIVE | DBIcf_IADESTROY		\
	/* These are for dbh only:	*/						\
	| DBIcf_AutoCommit	)

/* general purpose flag setting and testing macros (except ACTIVE)	*/
#define DBIc_is(imp, flag)	(DBIc_FLAGS(imp) &   (flag))
#define DBIc_has(imp,flag)	DBIc_is(imp, flag) /* alias for _is */
#define DBIc_on(imp, flag)	(DBIc_FLAGS(imp) |=  (flag))
#define DBIc_off(imp,flag)	(DBIc_FLAGS(imp) &= ~(flag))
#define DBIc_set(imp,flag,on)	((on) ? DBIc_on(imp, flag) : DBIc_off(imp,flag))

#define DBIc_COMSET(imp)	DBIc_is(imp, DBIcf_COMSET)
#define DBIc_COMSET_on(imp)	DBIc_on(imp, DBIcf_COMSET)
#define DBIc_COMSET_off(imp)	DBIc_off(imp,DBIcf_COMSET)

#define DBIc_IMPSET(imp)	DBIc_is(imp, DBIcf_IMPSET)
#define DBIc_IMPSET_on(imp)	DBIc_on(imp, DBIcf_IMPSET)
#define DBIc_IMPSET_off(imp)	DBIc_off(imp,DBIcf_IMPSET)

#define DBIc_ACTIVE(imp)	(DBIc_FLAGS(imp) &   DBIcf_ACTIVE)
#define DBIc_ACTIVE_on(imp)	/* adjust parent's active kid count */	\
    do {								\
	imp_xxh_t *ph_com = DBIc_PARENT_COM(imp);			\
	if (!DBIc_ACTIVE(imp) && ph_com && !dirty			\
		&& ++DBIc_ACTIVE_KIDS(ph_com) > DBIc_KIDS(ph_com))	\
	    croak("panic: DBI active kids (%d) > kids (%d)",		\
		DBIc_ACTIVE_KIDS(ph_com), DBIc_KIDS(ph_com));		\
	DBIc_FLAGS(imp) |=  DBIcf_ACTIVE;				\
    } while(0)
#define DBIc_ACTIVE_off(imp)	/* adjust parent's active kid count */	\
    do {								\
	imp_xxh_t *ph_com = DBIc_PARENT_COM(imp);			\
	if (DBIc_ACTIVE(imp) && ph_com && !dirty			\
		&& (--DBIc_ACTIVE_KIDS(ph_com) > DBIc_KIDS(ph_com)	\
		   || DBIc_ACTIVE_KIDS(ph_com) < 0) )			\
	    croak("panic: DBI active kids (%d) < 0 or > kids (%d)",	\
		DBIc_ACTIVE_KIDS(ph_com), DBIc_KIDS(ph_com));		\
	DBIc_FLAGS(imp) &= ~DBIcf_ACTIVE;				\
    } while(0)

#define DBIc_IADESTROY(imp)	(DBIc_FLAGS(imp) &   DBIcf_IADESTROY)
#define DBIc_IADESTROY_on(imp)	(DBIc_FLAGS(imp) |=  DBIcf_IADESTROY)
#define DBIc_IADESTROY_off(imp)	(DBIc_FLAGS(imp) &= ~DBIcf_IADESTROY)

#define DBIc_WARN(imp)   	(DBIc_FLAGS(imp) &   DBIcf_WARN)
#define DBIc_WARN_on(imp)	(DBIc_FLAGS(imp) |=  DBIcf_WARN)
#define DBIc_WARN_off(imp)	(DBIc_FLAGS(imp) &= ~DBIcf_WARN)

#define DBIc_COMPAT(imp)   	(DBIc_FLAGS(imp) &   DBIcf_COMPAT)
#define DBIc_COMPAT_on(imp)	(DBIc_FLAGS(imp) |=  DBIcf_COMPAT)
#define DBIc_COMPAT_off(imp)	(DBIc_FLAGS(imp) &= ~DBIcf_COMPAT)


#ifdef IN_DBI_XS		/* get Handle Common Data Structure	*/
#define DBIh_COM(h)         	(dbih_getcom(h))
#else
#define DBIh_COM(h)         	(DBIS->getcom(h))
#define neatsvpv(sv,len)       	(DBIS->neat_svpv(sv,len))
#endif


/* --- Implementors Private Data Support --- */

#define D_impdata(name,type,h)	type *name = (type*)(DBIh_COM(h))
#define D_imp_drh(h) D_impdata(imp_drh, imp_drh_t, h)
#define D_imp_dbh(h) D_impdata(imp_dbh, imp_dbh_t, h)
#define D_imp_sth(h) D_impdata(imp_sth, imp_sth_t, h)
#define D_imp_xxh(h) D_impdata(imp_xxh, imp_xxh_t, h)

#define D_imp_from_child(name,type,child)	\
				type *name = (type*)(DBIc_PARENT_COM(child))
#define D_imp_drh_from_dbh D_imp_from_child(imp_drh, imp_drh_t, imp_dbh)
#define D_imp_dbh_from_sth D_imp_from_child(imp_dbh, imp_dbh_t, imp_sth)

#define DBI_IMP_SIZE(n,s) sv_setiv(perl_get_sv((n), GV_ADDMULTI), (s)) /* XXX */


/* --- Implementors Field Descriptor Support --- */


/* --- Event Support (VERY LIABLE TO CHANGE) --- */

#define DBIh_EVENTx(h,t,a1,a2)	(DBIS->event((h), (t), (a1), (a2)))
#define DBIh_EVENT0(h,t)	DBIh_EVENTx((h), (t), &sv_undef, &sv_undef)
#define DBIh_EVENT1(h,t, a1)	DBIh_EVENTx((h), (t), (a1),      &sv_undef)
#define DBIh_EVENT2(h,t, a1,a2)	DBIh_EVENTx((h), (t), (a1),      (a2))

#define ERROR_event	"ERROR"
#define WARN_event	"WARN"
#define MSG_event	"MESSAGE"
#define DBEVENT_event	"DBEVENT"
#define UNKNOWN_event	"UNKNOWN"


/* --- Handy Macros --- */

#define DBIh_CLEAR_ERROR(imp_xxh) (void)( \
	(void)SvOK_off(DBIc_ERR(imp_xxh)),    	\
	(void)SvOK_off(DBIc_ERRSTR(imp_xxh)),	\
	(SvPOK(DBIc_STATE(imp_xxh)) ? SvCUR(DBIc_STATE(imp_xxh))=0 : 0)	\
    )


/* --- DBI State Structure --- */

typedef struct {

#define DBISTATE_VERSION  94	/* Must change whenever dbistate_t does	*/

    /* this must be the first member in structure			*/
    void (*check_version) _((char *name,
		int dbis_cv, int dbis_cs, int need_dbixs_cv,
		int drc_s, int dbc_s, int stc_s, int fdc_s));

    /* version and size are used to check for DBI/DBD version mis-match	*/
    U16 version;	/* version of this structure			*/
    U16 size;
    U16 xs_version;	/* version of the overall DBIXS / DBD interface	*/
    U16 spare_pad;

    I32 debug;
    FILE *logfp;

    /* pointers to DBI functions which the DBD's will want to use	*/
    char      * (*neat_svpv)	_((SV *sv, STRLEN maxlen));
    imp_xxh_t * (*getcom)	_((SV *h));	/* see DBIh_COM macro	*/
    void        (*clearcom)	_((imp_xxh_t *imp_xxh));
    SV        * (*event)	_((SV *h, char *name, SV*, SV*));
    int         (*set_attr_k)	_((SV *h, SV *keysv, int dbikey, SV *valuesv));
    SV        * (*get_attr_k)	_((SV *h, SV *keysv, int dbikey));
    AV        * (*get_fbav)	_((imp_sth_t *imp_sth));
    SV        * (*make_fdsv)	_((SV *sth, char *imp_class, STRLEN imp_size, char *col_name));
    int         (*bind_as_num)	_((int sql_type, int p, int s, int *t, void *v));
    int         (*hash)		_((char *string, long i));
    AV        * (*preparse)	_((SV *sth, char *statement, U32 flags, U32 spare));

    SV *neatsvpvlen;	/* only show dbgpvlen chars when debugging pv's	*/

    dbi_mutex	*mutex;

    void *pad[9];
} dbistate_t;

/* macros for backwards compatibility */
#define set_attr(h, k, v)	set_attr_k(h, k, 0, v)
#define get_attr(h, k)		get_attr_k(h, k, 0)

#define DBISTATE_DECLARE  static dbistate_t *DBIS
#define DBISTATE_PERLNAME "DBI::_dbistate"
#define DBISTATE_ADDRSV   (perl_get_sv(DBISTATE_PERLNAME, 0x05))

#define DBISTATE_INIT_DBIS (DBIS = (dbistate_t*)SvIV(DBISTATE_ADDRSV))

#define DBISTATE_INIT {		/* typically use in BOOT: of XS file	*/    \
    DBISTATE_INIT_DBIS;	\
    if (DBIS == NULL)	\
	croak("Unable to get DBI state. DBI not loaded.");	\
    DBIS->check_version(__FILE__, DBISTATE_VERSION, sizeof(*DBIS), NEED_DBIXS_VERSION, \
		sizeof(dbih_drc_t), sizeof(dbih_dbc_t), sizeof(dbih_stc_t), sizeof(dbih_fdc_t) \
	); \
}

#define DBILOGFP	(DBIS->logfp)

/* --- Assorted Utility Macros	--- */

#define DBD_ATTRIB_OK(attribs)	/* is this a usable attrib value */	\
	(attribs && SvROK(attribs) && SvTYPE(SvRV(attribs))==SVt_PVHV)

/* If attribs value supplied then croak if it's not a hash ref.		*/
/* Also map undef to Null. Should always be called to pre-process the	*/
/* attribs value. One day we may add some extra magic in here.		*/
#define DBD_ATTRIBS_CHECK(func, h, attribs)	\
    if ((attribs) && SvOK(attribs)) {		\
	if (!SvROK(attribs) || SvTYPE(SvRV(attribs))!=SVt_PVHV)		\
	    croak("%s->%s(...): attribute parameter '%s' is not a hash ref",	\
		    SvPV(h,na), func, SvPV(attribs,na));		\
    } else (attribs) = Nullsv

#define DBD_ATTRIB_GET_SVP(attribs, key,klen)			\
	(DBD_ATTRIB_OK(attribs)					\
	    ? hv_fetch((HV*)SvRV(attribs), key,klen, 0)		\
	    : (SV **)Nullsv)
	
#define DBD_ATTRIB_GET_BOOL(attribs, key,klen, svp, var)		\
	if ((svp=DBD_ATTRIB_GET_SVP(attribs, key,klen)) != NULL)	\
	    var = SvTRUE(*svp)

#define DBD_ATTRIB_GET_IV(attribs, key,klen, svp, var)			\
	if ((svp=DBD_ATTRIB_GET_SVP(attribs, key,klen)) != NULL)	\
	    var = SvIV(*svp)

#endif /* DBIXS_VERSION */
/* end of DBIXS.h */
