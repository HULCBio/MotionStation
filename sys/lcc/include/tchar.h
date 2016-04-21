/* $Revision: 1.2 $ */
#ifndef	_LCC_INC_TCHAR
#define	_LCC_INC_TCHAR
#define	_ftcscat	_tcscat
#define	_ftcschr	_tcschr
#define	_ftcscpy	_tcscpy
#define	_ftcscspn	_tcscspn
#define	_ftcslen	_tcslen
#define	_ftcsncat	_tcsncat
#define	_ftcsncpy	_tcsncpy
#define	_ftcspbrk	_tcspbrk
#define	_ftcsrchr	_tcsrchr
#define	_ftcsspn	_tcsspn
#define	_ftcsstr	_tcsstr
#define	_ftcstok	_tcstok
#define	_ftcsdup	_tcsdup
#define	_ftcsnset	_tcsnset
#define	_ftcsrev	_tcsrev
#define	_ftcsset	_tcsset
#define	_ftcscmp	_tcscmp
#define	_ftcsicmp	_tcsicmp
#define	_ftcsnccmp	_tcsnccmp
#define	_ftcsncmp	_tcsncmp
#define	_ftcsncicmp	_tcsncicmp
#define	_ftcsnicmp	_tcsnicmp
#define	_ftcscoll	_tcscoll
#define	_ftcsicoll	_tcsicoll
#define	_ftcsnccoll	_tcsnccoll
#define	_ftcsncoll	_tcsncoll
#define	_ftcsncicoll	_tcsncicoll
#define	_ftcsnicoll	_tcsnicoll
#define	_ftcsclen	_tcsclen
#define	_ftcsnccat	_tcsnccat
#define	_ftcsnccpy	_tcsnccpy
#define	_ftcsncset	_tcsncset
#define	_ftcsdec	_tcsdec
#define	_ftcsinc	_tcsinc
#define	_ftcsnbcnt	_tcsnbcnt
#define	_ftcsnccnt	_tcsnccnt
#define	_ftcsnextc	_tcsnextc
#define	_ftcsninc	_tcsninc
#define	_ftcsspnp	_tcsspnp
#define	_ftcslwr	_tcslwr
#define	_ftcsupr	_tcsupr
#define	_ftclen		_tclen
#define	_ftccpy		_tccpy
#define	_ftccmp		_tccmp
#ifdef	UNICODE

#include <wchar.h>
#ifndef	_WCTYPE_T_DEFINED
typedef	wchar_t	wint_t;
typedef	wchar_t	wctype_t;
#define	_WCTYPE_T_DEFINED
#endif
#ifndef	__TCHAR_DEFINED
typedef	wchar_t	_TCHAR;
typedef	wchar_t	_TSCHAR;
typedef	wchar_t	_TUCHAR;
typedef	wchar_t	_TXCHAR;
typedef	wint_t	_TINT;
#define	__TCHAR_DEFINED
#endif
#ifndef	_TCHAR_DEFINED
#if	!__STDC__
typedef	wchar_t	TCHAR;
#endif
#define	_TCHAR_DEFINED
#endif
#define	_TEOF	WEOF
#define	__T(x)	L	##	x
#define	_tmain	wmain
#define	_tWinMain	wWinMain
#define	_tenviron	_wenviron
#define	__targv	__wargv
#define	_tprintf	wprintf
#define	_ftprintf	fwprintf
#define	_stprintf	swprintf
#define	_sntprintf	_snwprintf
#define	_vtprintf	vwprintf
#define	_vftprintf	vfwprintf
#define	_vstprintf	vswprintf
#define	_vsntprintf	_vsnwprintf
#define	_tscanf	wscanf
#define	_ftscanf	fwscanf
#define	_stscanf	swscanf
#define	_fgettc	fgetwc
#define	_fgettchar	_fgetwchar
#define	_fgetts	fgetws
#define	_fputtc	fputwc
#define	_fputtchar	_fputwchar
#define	_fputts	fputws
#define	_gettc	getwc
#define	_gettchar	getwchar
#define	_getts	_getws
#define	_puttc	putwc
#define	_puttchar	putwchar
#define	_putts	_putws
#define	_ungettc	ungetwc
#define	_tcstod	wcstod
#define	_tcstol	wcstol
#define	_tcstoul	wcstoul
#define	_itot	_itow
#define	_ltot	_ltow
#define	_ultot	_ultow
#define	_ttoi	_wtoi
#define	_ttol	_wtol
#define	_tcscat	wcscat
#define	_tcschr	wcschr
#define	_tcscpy	wcscpy
#define	_tcscspn	wcscspn
#define	_tcslen	wcslen
#define	_tcsncat	wcsncat
#define	_tcsncpy	wcsncpy
#define	_tcspbrk	wcspbrk
#define	_tcsrchr	wcsrchr
#define	_tcsspn	wcsspn
#define	_tcsstr	wcsstr
#define	_tcstok	wcstok
#define	_tcsdup	_wcsdup
#define	_tcsnset	_wcsnset
#define	_tcsrev	_wcsrev
#define	_tcsset	_wcsset
#define	_tcscmp	wcscmp
#define	_tcsicmp	_wcsicmp
#define	_tcsnccmp	wcsncmp
#define	_tcsncmp	wcsncmp
#define	_tcsncicmp	_wcsnicmp
#define	_tcsnicmp	_wcsnicmp
#define	_tcscoll	wcscoll
#define	_tcsicoll	_wcsicoll
#define	_tcsnccoll	_wcsncoll
#define	_tcsncoll	_wcsncoll
#define	_tcsncicoll	_wcsnicoll
#define	_tcsnicoll	_wcsnicoll
#define	_texecl	_wexecl
#define	_texecle	_wexecle
#define	_texeclp	_wexeclp
#define	_texeclpe	_wexeclpe
#define	_texecv	_wexecv
#define	_texecve	_wexecve
#define	_texecvp	_wexecvp
#define	_texecvpe	_wexecvpe
#define	_tspawnl	_wspawnl
#define	_tspawnle	_wspawnle
#define	_tspawnlp	_wspawnlp
#define	_tspawnlpe	_wspawnlpe
#define	_tspawnv	_wspawnv
#define	_tspawnve	_wspawnve
#define	_tspawnvp	_wspawnvp
#define	_tspawnvp	_wspawnvp
#define	_tspawnvpe	_wspawnvpe
#define	_tsystem	_wsystem
#define	_tasctime	_wasctime
#define	_tctime	_wctime
#define	_tstrdate	_wstrdate
#define	_tstrtime	_wstrtime
#define	_tutime	_wutime
#define	_tcsftime	wcsftime
#define	_tchdir	_wchdir
#define	_tgetcwd	_wgetcwd
#define	_tgetdcwd	_wgetdcwd
#define	_tmkdir	_wmkdir
#define	_trmdir	_wrmdir
#define	_tfullpath	_wfullpath
#define	_tgetenv	_wgetenv
#define	_tmakepath	_wmakepath
#define	_tputenv	_wputenv
#define	_tsearchenv	_wsearchenv
#define	_tsplitpath	_wsplitpath
#define	_tfdopen	_wfdopen
#define	_tfsopen	_wfsopen
#define	_tfopen	_wfopen
#define	_tfreopen	_wfreopen
#define	_tperror	_wperror
#define	_tpopen	_wpopen
#define	_ttempnam	_wtempnam
#define	_ttmpnam	_wtmpnam
#define	_taccess	_waccess
#define	_tchmod	_wchmod
#define	_tcreat	_wcreat
#define	_tfindfirst	_wfindfirst
#define	_tfindfirsti64	_wfindfirsti64
#define	_tfindnext	_wfindnext
#define	_tfindnexti64	_wfindnexti64
#define	_tmktemp	_wmktemp
#define	_topen	_wopen
#define	_tremove	_wremove
#define	_trename	_wrename
#define	_tsopen	_wsopen
#define	_tunlink	_wunlink
#define	_tfinddata_t	_wfinddata_t
#define	_tfinddatai64_t	_wfinddatai64_t
#define	_tstat	_wstat
#define	_tstati64	_wstati64
#define	_tsetlocale	_wsetlocale
#define	_tcsclen	wcslen
#define	_tcsnccat	wcsncat
#define	_tcsnccpy	wcsncpy
#define	_tcsncset	_wcsnset
#define	_tcsdec	_wcsdec
#define	_tcsinc	_wcsinc
#define	_tcsnbcnt	_wcsncnt
#define	_tcsnccnt	_wcsncnt
#define	_tcsnextc	_wcsnextc
#define	_tcsninc	_wcsninc
#define	_tcsspnp	_wcsspnp
#define	_tcslwr	_wcslwr
#define	_tcsupr	_wcsupr
#define	_tcsxfrm	wcsxfrm
#define	_tclen(_pc)	(1)
#define	_tccpy(pc1,cpc2)	((*(pc1) = *(cpc2)))
#define	_tccmp(cpc1,cpc2)	((*(cpc1))-(*(cpc2)))
#define	_istalnum	iswalnum
#define	_istalpha	iswalpha
#define	_istascii	iswascii
#define	_istcntrl	iswcntrl
#define	_istdigit	iswdigit
#define	_istgraph	iswgraph
#define	_istlower	iswlower
#define	_istprint	iswprint
#define	_istpunct	iswpunct
#define	_istspace	iswspace
#define	_istupper	iswupper
#define	_istxdigit	iswxdigit
#define	_totupper	towupper
#define	_totlower	towlower
#define	_istlegal(_c)	(1)
#define	_istlead(_c)	(0)
#define	_istleadbyte(_c)	(0)
#define	_wcsdec(_cpc1,	_cpc2)	((_cpc2)-1)
#define	_wcsinc(_pc)	((_pc)+1)
#define	_wcsnextc(_cpc)	((unsigned int)	*(_cpc))
#define	_wcsninc(_pc,	_sz)	(((_pc)+(_sz)))
#define	_wcsncnt(_cpc,	_sz)	((wcslen(_cpc)>_sz) ? _sz : wcslen(_cpc))
#define	_wcsspnp(_cpc1,	_cpc2)	((*((_cpc1)+wcsspn(_cpc1,_cpc2))) ? ((_cpc1)+wcsspn(_cpc1,_cpc2)) : NULL)
#else	/*	not	UNICODE	*/
#include <string.h>
#define	_TEOF	EOF
#define	__T(x)	x
#define	_tmain	main
#define	_tWinMain	WinMain
#define	_tenviron	_environ
#define	__targv	__argv
#define	_tprintf	printf
#define	_ftprintf	fprintf
#define	_stprintf	sprintf
#define	_sntprintf	_snprintf
#define	_vtprintf	vprintf
#define	_vftprintf	vfprintf
#define	_vstprintf	vsprintf
#define	_vsntprintf	_vsnprintf
#define	_tscanf	scanf
#define	_ftscanf	fscanf
#define	_stscanf	sscanf
#define	_fgettc	fgetc
#define	_fgettchar	_fgetchar
#define	_fgetts	fgets
#define	_fputtc	fputc
#define	_fputtchar	_fputchar
#define	_fputts	fputs
#define	_gettc	getc
#define	_gettchar	getchar
#define	_getts	gets
#define	_puttc	putc
#define	_puttchar	putchar
#define	_putts	puts
#define	_ungettc	ungetc
#define	_tcstod	strtod
#define	_tcstol	strtol
#define	_tcstoul	strtoul
#define	_itot	_itoa
#define	_ltot	_ltoa
#define	_ultot	_ultoa
#define	_ttoi	atoi
#define	_ttol	atol
#define	_tcscat	strcat
#define	_tcscpy	strcpy
#define	_tcslen	strlen
#define	_tcsxfrm	strxfrm
#define	_tcsdup	_strdup
#define	_texecl	_execl
#define	_texecle	_execle
#define	_texeclp	_execlp
#define	_texeclpe	_execlpe
#define	_texecv	_execv
#define	_texecve	_execve
#define	_texecvp	_execvp
#define	_texecvpe	_execvpe
#define	_tspawnl	_spawnl
#define	_tspawnle	_spawnle
#define	_tspawnlp	_spawnlp
#define	_tspawnlpe	_spawnlpe
#define	_tspawnv	_spawnv
#define	_tspawnve	_spawnve
#define	_tspawnvp	_spawnvp
#define	_tspawnvpe	_spawnvpe
#define	_tsystem	system
#define	_tasctime	asctime
#define	_tctime	ctime
#define	_tstrdate	_strdate
#define	_tstrtime	_strtime
#define	_tutime	_utime
#define	_tcsftime	strftime
#define	_tchdir	_chdir
#define	_tgetcwd	_getcwd
#define	_tgetdcwd	_getdcwd
#define	_tmkdir	_mkdir
#define	_trmdir	_rmdir
#define	_tfullpath	_fullpath
#define	_tgetenv	getenv
#define	_tmakepath	_makepath
#define	_tputenv	_putenv
#define	_tsearchenv	_searchenv
#define	_tsplitpath	_splitpath
#define	_tfdopen	_fdopen
#define	_tfsopen	_fsopen
#define	_tfopen	fopen
#define	_tfreopen	freopen
#define	_tperror	perror
#define	_tpopen	_popen
#define	_ttempnam	_tempnam
#define	_ttmpnam	tmpnam
#define	_tchmod	_chmod
#define	_tcreat	_creat
#define	_tfindfirst	_findfirst
#define	_tfindfirsti64	_findfirsti64
#define	_tfindnext	_findnext
#define	_tfindnexti64	_findnexti64
#define	_tmktemp	_mktemp
#define	_topen	_open
#define	_taccess	_access
#define	_tremove	remove
#define	_trename	rename
#define	_tsopen	_sopen
#define	_tunlink	_unlink
#define	_tfinddata_t	_finddata_t
#define	_tfinddatai64_t	_finddatai64_t
#define	_istascii	isascii
#define	_istcntrl	iscntrl
#define	_istxdigit	isxdigit
#define	_tstat	_stat
#define	_tstati64	_stati64
#define	_tsetlocale	setlocale
#ifdef	_MBCS
#include <mbstring.h>
#ifndef	__TCHAR_DEFINED
typedef	char	_TCHAR;
typedef	signed	char	_TSCHAR;
typedef	unsigned	char	_TUCHAR;
typedef	unsigned	char	_TXCHAR;
typedef	unsigned	int	_TINT;
#define	__TCHAR_DEFINED
#endif
#ifndef	_TCHAR_DEFINED
typedef	char	TCHAR;
#define	_TCHAR_DEFINED
#endif
#define	_tcschr	_mbschr
#define	_tcscspn	_mbscspn
#define	_tcsncat	_mbsnbcat
#define	_tcsncpy	_mbsnbcpy
#define	_tcspbrk	_mbspbrk
#define	_tcsrchr	_mbsrchr
#define	_tcsspn	_mbsspn
#define	_tcsstr	_mbsstr
#define	_tcstok	_mbstok
#define	_tcsnset	_mbsnbset
#define	_tcsrev	_mbsrev
#define	_tcsset	_mbsset
#define	_tcscmp	_mbscmp
#define	_tcsicmp	_mbsicmp
#define	_tcsnccmp	_mbsncmp
#define	_tcsncmp	_mbsnbcmp
#define	_tcsncicmp	_mbsnicmp
#define	_tcsnicmp	_mbsnbicmp
#define	_tcscoll	_mbscoll
#define	_tcsicoll	_mbsicoll
#define	_tcsnccoll	_mbsncoll
#define	_tcsncoll	_mbsnbcoll
#define	_tcsncicoll	_mbsnicoll
#define	_tcsnicoll	_mbsnbicoll
#define	_tcsclen	_mbslen
#define	_tcsnccat	_mbsncat
#define	_tcsnccpy	_mbsncpy
#define	_tcsncset	_mbsnset
#define	_tcsdec	_mbsdec
#define	_tcsinc	_mbsinc
#define	_tcsnbcnt	_mbsnbcnt
#define	_tcsnccnt	_mbsnccnt
#define	_tcsnextc	_mbsnextc
#define	_tcsninc	_mbsninc
#define	_tcsspnp	_mbsspnp
#define	_tcslwr	_mbslwr
#define	_tcsupr	_mbsupr
#define	_tclen	_mbclen
#define	_tccpy	_mbccpy
#define	_tccmp(_cpuc1,_cpuc2)	_tcsnccmp(_cpuc1,_cpuc2,1)
#define	_tccmp(_cp1,_cp2)	_tcsnccmp(_cp1,_cp2,1)
#define	_istalnum	_ismbcalnum
#define	_istalpha	_ismbcalpha
#define	_istdigit	_ismbcdigit
#define	_istgraph	_ismbcgraph
#define	_istlegal	_ismbclegal
#define	_istlower	_ismbclower
#define	_istprint	_ismbcprint
#define	_istpunct	_ismbcpunct
#define	_istspace	_ismbcspace
#define	_istupper	_ismbcupper
#define	_totupper	_mbctoupper
#define	_totlower	_mbctolower
#define	_istlead	_ismbblead
#define	_istleadbyte	isleadbyte
#else	/*	!_MBCS	*/
#ifndef	__TCHAR_DEFINED
typedef	char	_TCHAR;
typedef	signed	char	_TSCHAR;
typedef	unsigned	char	_TUCHAR;
typedef	char	_TXCHAR;
typedef	int	_TINT;
#define	__TCHAR_DEFINED
#endif
#ifndef	__TCHAR_DEFINED
typedef	char	TCHAR;
#define	__TCHAR_DEFINED
#endif
#define	_tcschr	strchr
#define	_tcscspn	strcspn
#define	_tcsncat	strncat
#define	_tcsncpy	strncpy
#define	_tcspbrk	strpbrk
#define	_tcsrchr	strrchr
#define	_tcsspn	strspn
#define	_tcsstr	strstr
#define	_tcstok	strtok
#define	_tcsnset	_strnset
#define	_tcsrev	_strrev
#define	_tcsset	_strset
#define	_tcscmp	strcmp
#define	_tcsicmp	_stricmp
#define	_tcsnccmp	strncmp
#define	_tcsncmp	strncmp
#define	_tcsncicmp	_strnicmp
#define	_tcsnicmp	_strnicmp
#define	_tcscoll	strcoll
#define	_tcsicoll	_stricoll
#define	_tcsnccoll	_strncoll
#define	_tcsncoll	_strncoll
#define	_tcsncicoll	_strnicoll
#define	_tcsnicoll	_strnicoll
#define	_tcsclen	strlen
#define	_tcsnccat	strncat
#define	_tcsnccpy	strncpy
#define	_tcsncset	_strnset
#define	_tcsdec	_strdec
#define	_tcsinc	_strinc
#define	_tcsnbcnt	_strncnt
#define	_tcsnccnt	_strncnt
#define	_tcsnextc	_strnextc
#define	_tcsninc	_strninc
#define	_tcsspnp	_strspnp
#define	_tcslwr	_strlwr
#define	_tcsupr	_strupr
#define	_tcsxfrm	strxfrm
#define	_istlead(_c)	(0)
#define	_istleadbyte(_c)	(0)
#define	_tclen(_pc)	(1)
#define	_tccpy(_pc1,_cpc2)	(*(_pc1) = *(_cpc2))
#define	_tccmp(_cpc1,_cpc2)	(((unsigned char)*(_cpc1))-((unsigned char)*(_cpc2)))
#define	_istalnum	isalnum
#define	_istalpha	isalpha
#define	_istdigit	isdigit
#define	_istgraph	isgraph
#define	_istlower	islower
#define	_istprint	isprint
#define	_istpunct	ispunct
#define	_istspace	isspace
#define	_istupper	isupper
#define	_totupper	toupper
#define	_totlower	tolower
#define	_istlegal(_c)	(1)
#ifndef	NULL
#define	NULL	((void	*)0)
#endif
#define	_strdec(_cpc1,	_cpc2)	((_cpc2)-1)
#define	_strinc(_pc)	((_pc)+1)
#define	_strnextc(_cpc)	((unsigned int)	*(_cpc))
#define	_strninc(_pc, _sz)	(((_pc)+(_sz)))
#define	_strncnt(_cpc, _sz)	((strlen(_cpc)>_sz) ? _sz : strlen(_cpc))
#define	_strspnp(_cpc1,	_cpc2)	((*((_cpc1)+strspn(_cpc1,_cpc2))) ? ((_cpc1)+strspn(_cpc1,_cpc2)) : NULL)
#endif	/*	_MBCS	*/
#endif	/*	UNICODE	*/

#define	_T(x)	__T(x)
#define	_TEXT(x)	__T(x)
#endif
