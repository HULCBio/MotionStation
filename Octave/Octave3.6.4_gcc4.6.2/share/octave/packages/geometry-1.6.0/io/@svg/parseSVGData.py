#!/usr/bin/env python

## Copyright (c) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
##    This program is free software: you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation, either version 3 of the License, or
##    any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program. If not, see <http://www.gnu.org/licenses/>.
import inkex
import sys
#import getopt

def parseSVGData (filen=None):

  svg = inkex.Effect ()
  svg.parse (filen)

  root = svg.document.xpath ('//svg:svg', namespaces=inkex.NSS)
  print 'data = struct("height",{0},"width",{1},"id","{2}");' \
        .format(root[0].attrib['height'],root[0].attrib['width'],
                                                          root[0].attrib['id'])
# ----------------------------

if __name__=="__main__":
  svg = sys.argv[1]
  parseSVGData(svg)
