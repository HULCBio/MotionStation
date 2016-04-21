// defaults.h.in
/*

Copyright (C) 1993-2012 John W. Eaton

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#if !defined (octave_defaults_h)
#define octave_defaults_h 1

#include <string>

#include "pathsearch.h"

#ifndef OCTAVE_CANONICAL_HOST_TYPE
#define OCTAVE_CANONICAL_HOST_TYPE "i686-pc-mingw32"
#endif

#ifndef OCTAVE_DEFAULT_PAGER
#define OCTAVE_DEFAULT_PAGER "less"
#endif

#ifndef OCTAVE_ARCHLIBDIR
#define OCTAVE_ARCHLIBDIR "/c/OctaveB/octave-3.6.4/libexec/octave/3.6.4/exec/i686-pc-mingw32"
#endif

#ifndef OCTAVE_BINDIR
#define OCTAVE_BINDIR "/c/OctaveB/octave-3.6.4/bin"
#endif

#ifndef OCTAVE_DATADIR
#define OCTAVE_DATADIR "/c/OctaveB/octave-3.6.4/share"
#endif

#ifndef OCTAVE_DATAROOTDIR
#define OCTAVE_DATAROOTDIR "/c/OctaveB/octave-3.6.4/share"
#endif

#ifndef OCTAVE_DOC_CACHE_FILE
#define OCTAVE_DOC_CACHE_FILE "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/etc/doc-cache"
#endif

#ifndef OCTAVE_EXEC_PREFIX
#define OCTAVE_EXEC_PREFIX "/c/OctaveB/octave-3.6.4"
#endif

#ifndef OCTAVE_FCNFILEDIR
#define OCTAVE_FCNFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/m"
#endif

#ifndef OCTAVE_IMAGEDIR
#define OCTAVE_IMAGEDIR "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/imagelib"
#endif

#ifndef OCTAVE_INCLUDEDIR
#define OCTAVE_INCLUDEDIR "/c/OctaveB/octave-3.6.4/include"
#endif

#ifndef OCTAVE_INFODIR
#define OCTAVE_INFODIR "/c/OctaveB/octave-3.6.4/share/info"
#endif

#ifndef OCTAVE_INFOFILE
#define OCTAVE_INFOFILE "/c/OctaveB/octave-3.6.4/share/info/octave.info"
#endif

#ifndef OCTAVE_LIBDIR
#define OCTAVE_LIBDIR "/c/OctaveB/octave-3.6.4/lib"
#endif

#ifndef OCTAVE_LIBEXECDIR
#define OCTAVE_LIBEXECDIR "/c/OctaveB/octave-3.6.4/libexec"
#endif

#ifndef OCTAVE_LIBEXECDIR
#define OCTAVE_LIBEXECDIR "/c/OctaveB/octave-3.6.4/libexec"
#endif

#ifndef OCTAVE_LOCALAPIFCNFILEDIR
#define OCTAVE_LOCALAPIFCNFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/site/api-v48+/m"
#endif

#ifndef OCTAVE_LOCALAPIOCTFILEDIR
#define OCTAVE_LOCALAPIOCTFILEDIR "/c/OctaveB/octave-3.6.4/lib/octave/site/oct/api-v48+/i686-pc-mingw32"
#endif

#ifndef OCTAVE_LOCALARCHLIBDIR
#define OCTAVE_LOCALARCHLIBDIR "/c/OctaveB/octave-3.6.4/libexec/octave/site/exec/i686-pc-mingw32"
#endif

#ifndef OCTAVE_LOCALFCNFILEDIR
#define OCTAVE_LOCALFCNFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/site/m"
#endif

#ifndef OCTAVE_LOCALOCTFILEDIR
#define OCTAVE_LOCALOCTFILEDIR "/c/OctaveB/octave-3.6.4/lib/octave/site/oct/i686-pc-mingw32"
#endif

#ifndef OCTAVE_LOCALSTARTUPFILEDIR
#define OCTAVE_LOCALSTARTUPFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/site/m/startup"
#endif

#ifndef OCTAVE_LOCALAPIARCHLIBDIR
#define OCTAVE_LOCALAPIARCHLIBDIR "/c/OctaveB/octave-3.6.4/libexec/octave/api-v48+/site/exec/i686-pc-mingw32"
#endif

#ifndef OCTAVE_LOCALVERARCHLIBDIR
#define OCTAVE_LOCALVERARCHLIBDIR "/c/OctaveB/octave-3.6.4/libexec/octave/3.6.4/site/exec/i686-pc-mingw32"
#endif

#ifndef OCTAVE_LOCALVERFCNFILEDIR
#define OCTAVE_LOCALVERFCNFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/site/m"
#endif

#ifndef OCTAVE_LOCALVEROCTFILEDIR
#define OCTAVE_LOCALVEROCTFILEDIR "/c/OctaveB/octave-3.6.4/lib/octave/3.6.4/site/oct/i686-pc-mingw32"
#endif

#ifndef OCTAVE_MAN1DIR
#define OCTAVE_MAN1DIR "/c/OctaveB/octave-3.6.4/share/man/man1"
#endif

#ifndef OCTAVE_MAN1EXT
#define OCTAVE_MAN1EXT ".1"
#endif

#ifndef OCTAVE_MANDIR
#define OCTAVE_MANDIR "/c/OctaveB/octave-3.6.4/share/man"
#endif

#ifndef OCTAVE_OCTFILEDIR
#define OCTAVE_OCTFILEDIR "/c/OctaveB/octave-3.6.4/lib/octave/3.6.4/oct/i686-pc-mingw32"
#endif

#ifndef OCTAVE_OCTETCDIR
#define OCTAVE_OCTETCDIR "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/etc"
#endif

#ifndef OCTAVE_OCTINCLUDEDIR
#define OCTAVE_OCTINCLUDEDIR "/c/OctaveB/octave-3.6.4/include/octave-3.6.4/octave"
#endif

#ifndef OCTAVE_OCTLIBDIR
#define OCTAVE_OCTLIBDIR "/c/OctaveB/octave-3.6.4/lib/octave/3.6.4"
#endif

#ifndef OCTAVE_PREFIX
#define OCTAVE_PREFIX "/c/OctaveB/octave-3.6.4"
#endif

#ifndef OCTAVE_STARTUPFILEDIR
#define OCTAVE_STARTUPFILEDIR "/c/OctaveB/octave-3.6.4/share/octave/3.6.4/m/startup"
#endif

#ifndef OCTAVE_RELEASE
#define OCTAVE_RELEASE ""
#endif

extern std::string Voctave_home;

extern std::string Vbin_dir;
extern std::string Vinfo_dir;
extern std::string Vdata_dir;
extern std::string Vlibexec_dir;
extern std::string Varch_lib_dir;
extern std::string Vlocal_arch_lib_dir;
extern std::string Vlocal_ver_arch_lib_dir;

extern std::string Vlocal_ver_oct_file_dir;
extern std::string Vlocal_api_oct_file_dir;
extern std::string Vlocal_oct_file_dir;

extern std::string Vlocal_ver_fcn_file_dir;
extern std::string Vlocal_api_fcn_file_dir;
extern std::string Vlocal_fcn_file_dir;

extern std::string Voct_file_dir;
extern std::string Vfcn_file_dir;

extern std::string Vimage_dir;

// Name of the editor to be invoked by the edit_history command.
extern std::string VEDITOR;

extern std::string Vlocal_site_defaults_file;
extern std::string Vsite_defaults_file;

// Name of the FFTW wisdom program.
extern OCTINTERP_API std::string Vfftw_wisdom_program;

extern std::string subst_octave_home (const std::string&);

extern void install_defaults (void);

extern void set_exec_path (const std::string& path = std::string ());
extern void set_image_path (const std::string& path = std::string ());

#endif
