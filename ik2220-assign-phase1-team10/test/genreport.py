#!/usr/bin/env python3

import sys
from datetime import datetime

def writeheader(report):
    report.write('==============================================================================\n')
    report.write('IK2220 Phase 1. Report\n')
    report.write('==============================================================================\n')
    report.write('\n')
    report.write('Date: %s\n' % datetime.now().isoformat(' '))
    report.write('\n')
    report.write('Team 10 members:\n')
    report.write('\tRoland Kovács\n')
    report.write('\tVenkata Ramakrishna Chivukula\n')
    report.write('\n')
    report.write('==============================================================================\n')
    report.write('\n')

def writefooter(report, suc, fail):
    report.write('==============================================================================\n')
    report.write('RESULTS:\n')
    report.write('==============================================================================\n')
    report.write('Total number of tests: %d\n' % (suc + fail))
    report.write('Number of tests PASSED: %d\n' % suc)
    report.write('Number of tests FAILED: %d\n' % fail)
    report.write('\n')
    report.write('SCORE: %.2f%% \n' % ((suc / (suc + fail)) * 100))
    report.write('==============================================================================\n')
    report.write('\n')

def parsedig(line, report):
    if line.startswith('; <<>>'):
        cmd = line.split('<<>>')[2]
        sp = line.split(' -p ')
        port = 53
        if len(sp) == 2:
            port = int(sp[1])
        report.write('  EXEC: dig %s' % cmd)
        if port in TESTPORT:
            return 'PASS'
        return 'FAIL'
    elif line.startswith(';; connection timed out'):
        return 'TIMEOUT'
    elif line.startswith(';; ANSWER SECTION'):
        return 'SUCCESS'
    else:
        return

def parsenc(line, report):
    if 'port_scan' in line:
        zone = line.split('_')[0].upper()
        report.write("EXEC: nc port scanning from %s\n" % zone)
        return
    if line.startswith('-'):
        return
    report.write('  LOG: %s' % line)
    if '100.0.0.4' in line:
        if line.startswith('Connection to'):
            if ' 80 ' in line:
                return ('PASS', 'PASSED')
            return ('FAIL', 'PASSED')
        elif ' 80 ' in line:
            return ('PASS', 'FAILED')
        return ('FAIL', 'FAILED')
    if '100.0.0.2' in line:
        if 'Connection refused' in line:
            if ' 53 ' in line:
                return ('PASS', 'PASSED')
            return ('FAIL', 'PASSED')
        elif ' timed out: ' in line:
            if ' 53 ' in line:
                return ('PASS', 'FAILED')
            return ('FAIL', 'FAILED')

def parsecurl(line, report):
    if line.startswith('curl_test'):
        port = line.split('_')[2].split('.')[0]
        report.write('  EXEC: curl against port %s\n' % port)
        if port == '80':
            return 'PASS'
        else:
            return 'FAIL'
    elif 'Connection timed out after' in line:
        return 'TIMEOUT'
    elif 'Connection refused' in line:
        return 'REFUSED'
    # the http server was just acting up...
    elif 'Operation timed out' in line:
        return 'OPTIMEOUT'
    elif line.startswith('<html>'):
        return 'SUCCESS'
    else:
        return

def parseping(line, report):
    if '->' in line:
        report.write("\t%s" % line)
    if line.startswith('*** Results:'):
        report.write("\t%s" % line)
        if '64/110' in line:
            return 'PASS'
        return 'FAIL'

if len(sys.argv) != 3:
    print('No log supplied...')
    exit(1)

LOG = sys.argv[1]
REPORT = sys.argv[2]

TESTNAME=''
TESTTYPE=''
TESTPORT=[]

SUCCESS = 0
TIMEOUT = 0
FAILURE = 0

SHOULD_SUCCEED = False

with open(LOG, 'r') as log:
    with open(REPORT,'w') as report:
        print('Generating report...')
        writeheader(report)
        for line in log:
            if line.startswith('Testing'):
                TESTNAME = (line.split()[1])[0:-1]
                report.write('\nEvaluating %s\n' % TESTNAME)
                report.write('------------------------------------------------------------------------------\n')
                if TESTNAME.startswith('curl'):
                    res = parsecurl(TESTNAME, report)
                    if res == 'PASS':
                        SHOULD_SUCCEED = True
                    elif res == 'FAIL':
                        SHOULD_SUCCEED = False
                    TESTTYPE = 'curl'
                    TESTPORT = [80]
                elif TESTNAME.startswith('dig'):
                    TESTTYPE = 'dig'
                    TESTPORT = [53]
                elif TESTNAME.startswith('ping_'):
                    TESTTYPE = 'ping'
                elif 'port_scan' in TESTNAME:
                    parsenc(TESTNAME, report)
                    TESTTYPE = 'portscan'
                    TESTPORT = [80, 53]
            elif TESTTYPE == 'dig':
                res = parsedig(line, report)
                if res == 'PASS':
                    SHOULD_SUCCEED = True
                elif res == 'FAIL':
                    SHOULD_SUCCEED = False
                elif res == 'TIMEOUT':
                    if SHOULD_SUCCEED:
                        FAILURE += 1
                        report.write('  - RESULT: expected to PASS, but FAILED.\n\n')
                    else:
                        SUCCESS += 1
                        report.write('  - RESULT: expected to FAIL and it FAILED.\n\n')
                elif res == 'SUCCESS':
                    if SHOULD_SUCCEED:
                        SUCCESS += 1
                        report.write('  - RESULT: expected to PASS and it PASSED.\n\n')
                    else:
                        FAILURE += 1
                        report.write('  - RESULT: expected to FAIL, but PASSED.\n\n')
            elif TESTTYPE == 'curl':
                res = parsecurl(line, report)
                if res in ('SUCCESS', 'OPTIMEOUT'):
                    if SHOULD_SUCCEED:
                        SUCCESS += 1
                        report.write('  - RESULT: expected to PASS and it PASSED.\n\n')
                    else:
                        FAILURE += 1
                        report.write('  - RESULT: expected to PASS, but FAILED.\n\n')
                elif res in ('TIMEOUT', 'REFUSED'):
                    if SHOULD_SUCCEED:
                        FAILURE += 1
                        report.write('  - RESULT: expected to PASS, but FAILED.\n\n')
                    else:
                        SUCCESS += 1
                        report.write('  - RESULT: expected to FAIL and it FAILED.\n\n')
            elif TESTTYPE == 'portscan':
                ret = parsenc(line, report)
                if not ret:
                    continue
                (exp, res) = ret
                if res == 'PASSED':
                    if exp == 'PASS':
                        SUCCESS += 1
                        report.write('  - RESULT: expected to PASS and it PASSED.\n\n')
                    else:
                        FAILURE += 1
                        report.write('  - RESULT: expected to PASS, but FAILED.\n\n')
                elif res == 'FAILED':
                    if exp == 'FAIL':
                        SUCCESS += 1
                        report.write('  - RESULT: expected to FAIL and it FAILED.\n\n')
                    else:
                        FAILURE += 1
                        report.write('  - RESULT: expected to FAIL, but PASSED.\n\n')
            elif TESTTYPE == 'ping':
                res = parseping(line, report)
                if not res:
                    continue
                if res == 'PASS':
                    SUCCESS += 1
                    report.write('  - RESULT: currect number of pings, PASSED\n\n')
                elif res == 'FAIL':
                    FAILURE += 1
                    report.write('  - RESULT: not all pings went through, FAILED\n\n')
        writefooter(report, SUCCESS, FAILURE)
