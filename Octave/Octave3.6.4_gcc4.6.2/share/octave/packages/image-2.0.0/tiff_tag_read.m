## Copyright (C) 2010-2012 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{value}, @var{offset}] =} tiff_tag_read (@var{file}, @var{tag})
## @deftypefnx {Function File} {[@var{value}, @var{offset}] =} tiff_tag_read (@var{file}, @var{tag}, @var{ifd})
## @deftypefnx {Function File} {[@var{value}, @var{offset}] =} tiff_tag_read (@var{file}, @var{tag}, "all")
## Read value of @var{tag}s from TIFF files.
##
## @var{file} must be a TIFF file and @var{tag} should be a tag ID. To check
## multiple tags, @var{tag} can be a vector. If @var{ifd} is supplied, only
## those IFDs (Image File Directory) will be read. As with @var{tag}, multiple
## IFDs can be checked by using a vector or with the string `all'. By default,
## only the first IFD is read.
##
## @var{value} and @var{offset} will be a matrix with a number of rows and
## columns equal to the number of @var{tag}s and @var{ifd}s requested. The index
## relate to the same order as the input. @var{offset} has the same structure as
## @var{value} and when equal to 1 its matching value on @var{value} will be an
## offset to a position in the file.
##
## @var{tag}s that can't be found will have a value of 0 and the corresponding
## @var{offset} will be 2.
##
## If an error occurs when reading @var{file} (such as lack of permissions of file
## is not a TIFF file), @var{offset} is set to -1 and @var{value} contains the
## error message.
##
## See the following examples:
## @example
## @group
## ## read value of tag 258 on IFD 1 (`off' will be 1 if `val' is an offset or 2 if not found)
## [val, off] = tiff_tag_read (filepath, 258);
## @end group
## @end example
##
## @example
## @group
## ## read value 258, 262, 254 o IFD 1 (`val' and `off' will be a 1x3 matrix)
## [val, off] = tiff_tag_read (filepath, [258 262 254]);
## if (off(1) == -1), error ("something happpened: %s", val); endif
## off(2,1)   # will be 1 if val(2,1) is an offset to a file position or 2 if tag was not found
## val(2,1)   # value of tag 262 on IFD 1
## @end group
## @end example
##
## @example
## @group
## ## read value 258, 262, 254 on the first 10 IFDs 1 (`val' and `off' will be a 1x10 matrix)
## [val, off] = tiff_tag_read (filepath, [258 262 254], 1:10);
## val(2,5)   # value of tag 262 on IFD 5
## @end group
## @end example
##
## @example
## @group
## ## read value 258, 262, 254 o IFD 1 (`val' and `off' will be a 1x3 matrix)
## [val, off] = tiff_tag_read (filepath, [258 262 254], "all");
## val(2,end)   # value of tag 262 on the last IFD
## @end group
## @end example
##
## @seealso{imread, imfinfo, readexif}
## @end deftypefn

## Based on the documentation at
##  * http://en.wikipedia.org/wiki/Tagged_Image_File_Format
##  * http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf
##  * http://ibb.gsf.de/homepage/karsten.rodenacker/IDL/Lsmfile.doc
##  * http://www.awaresystems.be/imaging/tiff/faq.html
##
## and the function tiff_read by F. Nedelec, EMBL (www.cytosim.org)
##  * http://www.cytosim.org/misc/index.html
##
## Explanation of the TIFF file structure:
##
## The idea of multi-page images meeds to be understood first. These allow one file
## to have multiple images. This may sound strange but consider situtations such as
## an MRI scan (one file can then contain one scan which is multiple images across
## one of the axis) or time-lapse experiment (where one file is not unlike a movie).
## TIFF files support this by being like a container of single images, called IFD
## (Image File Directory). For each page there will be a single IFD. One can see a
## TIFF as an archive file of multiple images files that many times have a single file.
##
## Each TIFF file starts with a small header that identifies the file as TIFF. The
## header ends with the position on the file for the first IFD. Each IFD has multiple
## entries that hold information about the image of that IFD including where on the
## file is the actual image. Each IFD entry is identified by a tag. Each tag has a
## unique meaning; for example, the IFD entry with tag 259 will say the compression
## type (if any), of the image in that IFD.
##
## A TIFF file will always have at least one IFD and each IFD will always have at
## least one IFD entry.
##
## * On the TIFF image file header:
##     bytes 00-01 --> byte order used within the file: "II" for little endian
##                     and "MM" for big endian byte ordering.
##     bytes 02-03 --> number 42 that identifies the file as TIFF
##     bytes 04-07 --> file offset (in bytes) of the first IFD (Image File Directory)
##
##   Note: offset is always from the start of the file ("bof" in fread) and first
##   byte has an offset of zero.
##
## * On a TIFF's IFD structure:
##     bytes 00-01 --> number of entries (or tags or fields or directories)
##     bytes 02-13 --> the IFD entry #0
##     bytes 14+=11 -> the IFD entry #N. Each will have exactly 12 bytes (the
##                     number of IFD entries was specified at the start of the IFD)
##     bytes XX-XX --> file offset for next IFD (last 4 bytes of the IFD) or 0
##                     if it's the last IFD
##
## * On an IFD entry structure:
##     bytes 00-01 --> tag that identifies the entry
##     bytes 02-03 --> entry type
##                      1  --> BYTE (uint8)
##                      2  --> ASCII
##                      3  --> SHORT (uint16)
##                      4  --> LONG (uint32)
##                      5  --> RATIONAL (two LONGS)
##                      6  --> SBYTE (int8)
##                      7  --> UNDEFINED (8 bit)
##                      8  --> SSHORT (int16)
##                      9  --> SLONG (int32)
##                      10 --> FLOAT (single IEEE precision)
##                      11 --> DOUBLE (double IEEE precision)
##     bytes 04-07 --> number of values (count)
##     bytes 08-11 --> file offset (from the beggining of file) or value (only if
##                     it fits in 4 bytes). It is possible that the offset is for
##                     a structure and not a value so we return the offset
##
##   Note: file offset of the value may point anywhere in the file, even after the image.
##
## Tags numbered >= 32768 are private tags
## Tags numbered on the 65000--65535 range are reusable tags

function [val, off] = tiff_tag_read (file, tag, ifd = 1)

  if (nargin < 2 || nargin > 3)
    print_usage;
  elseif (!isnumeric (tag) || !isvector (tag))
    error ("`tag' must be either a numeric scalar or vector with tags -- identifying number of a field");
  elseif (!(ischar (ifd) && strcmpi (ifd, "all")) && !(isnumeric (ifd) && isvector (ifd) && all (ifd == fix (ifd)) && all (ifd > 0)))
    error ("`ifd' must be either the string `all' or numeric scalar or vector of positive integers with the IFD index");
  endif

  [FID, msg] = fopen (file, "r", "native");
  if (FID == -1)
    [val, off] = bad_exit (FID, sprintf ("Unable to fopen '%s': %s.", file, msg));
    return
  endif

  ## read byte order
  byte_order = fread (FID, 2, "char=>char")';     # if we are retrieving a char, we need to transpose to get the string
  if     (strcmp (byte_order, "II"))
    arch = "ieee-le";                             # IEEE little endian format
  elseif (strcmp (byte_order,"MM"))
    arch = "ieee-be";                             # IEEE big endian format
  else
    [val, off] = bad_exit (FID, sprintf ("First 2 bytes of '%s' returned '%s'. For TIFF should either be 'II' or 'MM'. Are you sure it's a TIFF.", file, byte_order));
    return
  endif

  ## read number 42
  nTIFF = fread (FID, 1, "uint16", arch);
  if (nTIFF != 42)
    [val, off] = bad_exit (FID, sprintf ("'%s' is not a TIFF (missing value 42 on header at offset 2. Instead got '%g').", file, tiff_id));
    return
  endif

  if (ischar (ifd) && strcmpi (ifd, "all"))
    all_ifd = true;
  else
    all_ifd = false;
  endif

  ## default values for val and off
  def_val = 0;
  def_off = 2;

  ## start output values with default values
  if (ischar (ifd) && strcmpi (ifd, "all"))
    val = def_val * ones (numel (tag), 1);
    off = def_off * ones (numel (tag), 1);
  else
    val = def_val * ones (numel (tag), numel (ifd));
    off = def_off * ones (numel (tag), numel (ifd));
  endif

  ## read offset for the first IFD and move into it
  offset_IFD = fread (FID, 1, "uint32", arch);

  cIFD = 1;   # current IFD
  while (offset_IFD != 0 && (all_ifd || any (ifd >= cIFD)))
    status = fseek (FID, offset_IFD, "bof");
    if (status != 0)
      [val, off] = bad_exit (FID, sprintf ("error on fseek when moving to IFD #%g", cIFD));
      return
    endif

    ## if checking on all IFD, add one column to the output
    if (all_ifd)
      val(:, end+1) = def_val;
      off(:, end+1) = def_off;
    endif

    ## read number of entries (nTag) and look for the desired tag ID
    nTag = fread (FID, 1, "uint16", arch);          # number of tags in the IFD
    cTag = 1;                                       # current tag
    while (nTag >= cTag)
      tagID = fread (FID, 1, "uint16", arch);       # current tag ID
      if (any(tagID == tag))                        # found one
        ## column number of this IFD in the output matrix:
        ## we don't know at start the number of IFD so if all IFD have been requested
        ## we can't find them in `ifd', we need to set the index for output manually
        if (all_ifd)
          iCol = cIFD;
        else
          iCol = (ifd == cIFD);
        endif
        [val(tagID == tag, iCol), ...
         off(tagID == tag, iCol) ] = read_value (FID, arch); # read tag value
      elseif (all (tag < tagID))
        ## tags are in numeric order so if they wanted tags are all below current tag ID
        ## we can jump over to the next IFD
        skip_bytes = 10 + (12 * (nTag - cTag));
        status = fseek (FID, skip_bytes, "cof");    # Move to the next IFD
        break
      else
        status = fseek (FID, 10, "cof");            # Move to the next tag
        if (status != 0)
          [val, off] = bad_exit (FID, sprintf ("error on fseek when moving out of tag #%g (tagID %g) on IFD %g.", cTag, tagID, cIFD));
          return
        endif
      endif
      cTag++;
    endwhile

    offset_IFD = fread (FID, 1, "uint32", arch);
    cIFD++;
  endwhile
  fclose (FID);
endfunction

function [val, off] = read_value (FID, arch)

  position   = ftell (FID);
  field_type = fread (FID, 1, "uint16", arch);
  count      = fread (FID, 1, "uint32", arch);
  switch (field_type)
    case  1,  nBytes = 1; precision = "uint8";    # BYTE      = 8-bit unsigned integer
    case  2,  nBytes = 1; precision = "uchar";    # ASCII     = 8-bit byte that contains a 7-bit ASCII code; the last byte must be NUL (binary zero)
    case  3,  nBytes = 2; precision = "uint16";   # SHORT     = 16-bit (2-byte) unsigned integer
    case  4,  nBytes = 4; precision = "uint32";   # LONG      = 32-bit (4-byte) unsigned integer
    case  5,  nBytes = 8; precision = "uint32";   # RATIONAL  = Two LONGs: the first represents the numerator of a fraction; the second, the denominator
    case  6,  nBytes = 1; precision = "int8";     # SBYTE     = An 8-bit signed (twos-complement) integer
    case  7,  nBytes = 1; precision = "uchar";    # UNDEFINED = An 8-bit byte that may contain anything, depending on the definition of the field
    case  8,  nBytes = 2; precision = "int16";    # SSHORT    = A 16-bit (2-byte) signed (twos-complement) integer
    case  9,  nBytes = 4; precision = "int32";    # SLONG     = A 32-bit (4-byte) signed (twos-complement) integer
    case 10,  nBytes = 8; precision = "int32";    # SRATIONAL = Two SLONG’s: the first represents the numerator of a fraction, the second the denominator
    case 11,  nBytes = 4; precision = "float32";  # FLOAT     = Single precision (4-byte) IEEE format
    case 12,  nBytes = 8; precision = "float64";  # DOUBLE    = Double precision (8-byte) IEEE format
    otherwise
      ## From the TIFF file specification (page 16, section 2: TIFF structure):
      ## "Warning: It is possible that other TIFF field types will be added in the
      ## future. Readers should skip over fields containing an unexpected field type."
      ##
      ## However, we only get to this point of the code if we are in the tag requested
      ## by the use so it makes sense to error if we don't supported it yet.
      error ("TIFF type %i not supported", field_type);
  endswitch

  if ((nBytes*count) > 4)
    off = true;
    val = fread (FID, 1, "uint32", arch);
    if (rem (val, 2) != 0)  # file offset must be an even number
      warning ("Found an offset with an odd value %g (offsets should always be even numbers.", val);
    endif
  else
    off = false;
    switch precision
      case {5, 10}    val = fread (FID, 2*count, precision, arch); val = val(1)/val(2);   # the first represents the numerator of a fraction; the second, the denominator
      case {2}        val = fread (FID, count, [precision "=>char"], arch)';                    # if we are retrieving a char, we need to transpose to get the string
      otherwise       val = fread (FID, count, precision, arch);
    endswitch
    ## adjust position to end of IFD entry (not all take up 4 Bytes)
    fseek (FID, 4 - (nBytes*count), "cof");
  endif
endfunction

function [val, off] = bad_exit (FID, msg)
  off = -1;
  val = sprintf (msg);
  fclose (FID);
endfunction
