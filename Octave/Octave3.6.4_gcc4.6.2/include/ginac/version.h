/* ginac/version.h.  Generated from version.h.in by configure.  */
/** @file version.h
 *
 *  GiNaC library version information. */

/*
 *  GiNaC Copyright (C) 1999-2008 Johannes Gutenberg University Mainz, Germany
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef __GINAC_VERSION_H__
#define __GINAC_VERSION_H__

/* Major version of GiNaC */
#define GINACLIB_MAJOR_VERSION 1

/* Minor version of GiNaC */
#define GINACLIB_MINOR_VERSION 4

/* Micro version of GiNaC */
#define GINACLIB_MICRO_VERSION 4

namespace GiNaC {

extern const int version_major;
extern const int version_minor;
extern const int version_micro;

} // namespace GiNaC

#endif // ndef __GINAC_VERSION_H__
