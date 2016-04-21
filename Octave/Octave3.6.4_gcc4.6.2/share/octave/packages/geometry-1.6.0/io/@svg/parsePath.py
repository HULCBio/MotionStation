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

import inkex, simplepath
import sys
#import getopt

def parsePaths (filen=None):

  svg = inkex.Effect ()
  svg.parse (filen)

  paths = svg.document.xpath ('//svg:path', namespaces=inkex.NSS)
  for path in paths:
    D = simplepath.parsePath (path.attrib['d'])
    cmdlst = [];
    parlst = [];
    for cmd,params in D:
      cmdlst.append(cmd)
      parlst.append(params)

    print 'svgpath = struct("cmd","{0}","data",{{{1}}});' \
        .format(''.join(cmdlst),str(parlst).replace('[[','[').replace(']]',']'))

    print 'svgpathid = "{0}"; $'.format(path.attrib['id'])



# ----------------------------

if __name__=="__main__":
  '''
    try:
        optlist,args = getopt.getopt(sys.argv[1:],"thdp")
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    doHelp = 0
    c = Context()
    c.doPrint = 1
    for opt in optlist:
        if opt[0] == "-d":  c.debug = 1
        if opt[0] == "-p":  c.plot  = 1
        if opt[0] == "-t":  c.triangulate = 1
        if opt[0] == "-h":  doHelp = 1

    if not doHelp:
        pts = []
        fp = sys.stdin
        if len(args) > 0:
            fp = open(args[0],'r')
        for line in fp:
            fld = line.split()
            x = float(fld[0])
            y = float(fld[1])
            pts.append(Site(x,y))
        if len(args) > 0: fp.close()

    if doHelp or len(pts) == 0:
        usage()
        sys.exit(2)
  '''
  svg = sys.argv[1]
  parsePaths(svg)
