
/* These prototypes are for dbdimp.c funcs used in the XS file          */
/* These names are #defined to driver specific names in dbdimp.h        */

void    dbd_init _((dbistate_t *dbistate));

int      dbd_discon_all _((SV *drh, imp_drh_t *imp_drh));

int      dbd_db_login _((SV *dbh, imp_dbh_t *imp_dbh, char *dbname, char *uid, char *pwd));
int      dbd_db_do _((SV *sv, char *statement));
int      dbd_db_commit     _((SV *dbh, imp_dbh_t *imp_dbh));
int      dbd_db_rollback   _((SV *dbh, imp_dbh_t *imp_dbh));
int      dbd_db_disconnect _((SV *dbh, imp_dbh_t *imp_dbh));
void     dbd_db_destroy    _((SV *dbh, imp_dbh_t *imp_dbh));
int      dbd_db_STORE_attrib _((SV *dbh, imp_dbh_t *imp_dbh, SV *keysv, SV *valuesv));
SV      *dbd_db_FETCH_attrib _((SV *dbh, imp_dbh_t *imp_dbh, SV *keysv));
int      dbd_db_STORE_attrib_k _((SV *dbh, imp_dbh_t *imp_dbh, SV *keysv, int dbikey, SV *valuesv));
SV      *dbd_db_FETCH_attrib_k _((SV *dbh, imp_dbh_t *imp_dbh, SV *keysv, int dbikey));

int      dbd_st_prepare _((SV *sth, imp_sth_t *imp_sth,
                char *statement, SV *attribs));
int      dbd_st_rows    _((SV *sth, imp_sth_t *imp_sth));
int      dbd_st_execute _((SV *sth, imp_sth_t *imp_sth));
AV      *dbd_st_fetch   _((SV *sth, imp_sth_t *imp_sth));
int      dbd_st_finish  _((SV *sth, imp_sth_t *imp_sth));
void     dbd_st_destroy _((SV *sth, imp_sth_t *imp_sth));
int      dbd_st_blob_read _((SV *sth, imp_sth_t *imp_sth,
                int field, long offset, long len, SV *destrv, long destoffset));
int      dbd_st_STORE_attrib _((SV *sth, imp_sth_t *imp_sth, SV *keysv, SV *valuesv));
SV      *dbd_st_FETCH_attrib _((SV *sth, imp_sth_t *imp_sth, SV *keysv));
int      dbd_st_STORE_attrib_k _((SV *sth, imp_sth_t *imp_sth, SV *keysv, int dbikey, SV *valuesv));
SV      *dbd_st_FETCH_attrib_k _((SV *sth, imp_sth_t *imp_sth, SV *keysv, int dbikey));
 
int      dbd_bind_ph  _((SV *sth, imp_sth_t *imp_sth,
                SV *param, SV *value, IV sql_type, SV *attribs,
				int is_inout, IV maxlen));

/* end of dbd_xsh.h */
