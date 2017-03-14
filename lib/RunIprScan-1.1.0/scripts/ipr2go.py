#!/usr/bin/env python
import pdb
import sys
import os
import xml.sax


'''Extract interpro terms from a directory of interpro xml files.

example: ipr2tsv.py runiprcan_results/
'''
class IprHandler (xml.sax.ContentHandler):
    def __init__(self):
        xml.sax.ContentHandler.__init__(self)
        self.interpro = set()
        self.go = set()
        self.seqid = ""
        self.in_protein = False

    def startElement(self, name, attrs):
        if name == 'protein':
            self.in_protein = True

        if name == 'xref' and self.in_protein:
            self.seqid = attrs['id']

        if name == 'entry':
            self.interpro.add(attrs['ac'] + ' ' + attrs['desc'])

        if name == 'go-xref':
            self.go.add(attrs['id'] + '\t' + attrs['name'])

    def endElement(self, name):
        if name == 'protein':
            self.in_protein = False



ipr_set = set()
species_data = {}
dir_list = sys.argv[1:]

for dirname in dir_list:
    file_list = os.listdir(dirname)
    ipr_data = {}
    go_data = {}
    for xmlfile in file_list:
        if not xmlfile.endswith('xml'):
            continue

        parser = xml.sax.make_parser()
        handler = IprHandler()
        parser.setContentHandler(handler)
        parser.parse(open(dirname+'/'+xmlfile))
        #pdb.set_trace()

        for go in handler.go:
            print '%s\t%s' % (handler.seqid, go)

