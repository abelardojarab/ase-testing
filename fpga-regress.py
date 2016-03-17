#!/usr/bin/python
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 2,
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Author:  Tobin Davis <tobin.b.davis@intel.com>
#

import testlib
import unittest, argparse, pdb
from random import choice, randrange
from unittest.runner import TextTestResult
TextTestResult.getDescription = lambda _, test: str(test.shortDescription())

# Global program variables, lists, and dictionaries
prog = testlib.which('fpgadiag') or testlib.which('./fpgadiag') or exit('Error:  fpgadiag not found')
Target = 'fpga'  # default
failures = 0
contMode = True
noTime = True
DEBUG = False
CRC = False
THERM = False
logTiming = False
clock = 2 *10**8  # Clock freq in Hz - default 200MHz
giggity = 1024 * 1024 * 1024  # 1G
meg = 1024 * 1024  # 1M

cacheLines = (1, 0x4000)  # range(min, max)
pTimeout = ['--timeout-sec=1', '--timeout-sec=15'] # for permute

valTargets = ['fpga', 'ase', 'swsim']
readMode = ['--rds', '--rdi', '--rdo', '']  # READ, TRPUT, SW
writeMode = ['--wt', '--wb', '']  # WRITE, LPBK1, SW, TRPUT

FPGA_Cache = {'Default': ('', ''),
              'Warm FPGA': ('--warm-fpga-cache', '--wfc'),
              'Cool FPGA': ('--cool-fpga-cache', '--cfc'),
             }  # READ, WRITE

CPU_Cache = {'Default': ('', ''),
             'Cool CPU': ('--cool-cpu-cache', '--ccc'),
            } 

noticeMode = {'Default': ('', ''),
              'Poll': ('--poll', '--p'),
              'CSR-Write': ('--csr-write', '--cw'),
              'UMSG-Data': ('--umsg-data', '--ud'),
              'UMSG-Hint': ('--umsg-hint', '--uh'),
             }

vc_select = {'Default': '',
             'va': '--va', 
             'vl0': '--vl0', 
             'vh0': '--vh0',
             'vh1': '--vh1',
            }

multiCL = {'Default': '',
           '1': '--multi-cl=1',
           '2': '--multi-cl=2',
           '4': '--multi-cl=4'}

# Timeouts are a dictionary of tuples defined as {'param': <range>(start,stop[,step])}
rTimeouts = {'--timeout-nsec': (10, 100000),
            '--timeout-usec': (10, 100000),
            '--timeout-sec': (1, 59),
            '--timeout-min': (1, 59),
            '--timeout-hour': (1, 5),
            }  


# Global Script Variables
CCIPARGS = []

# Define the test class - this is the heart of the program
class InitFPGATest(testlib.TestlibCase):
    '''Main Test'''
    def setUp(self):
        '''Set up prior to each test_* function'''
        # Prepare for per-test teardowns
        self.teardowns = []

    def tearDown(self):
        '''Clean up after each test_* function'''
        # Handle per-test teardowns
        global failures
        #failures = self.currentResult.failures
        for func in self.teardowns:
            func()

    def runner(self, params, timeout=None):
        '''Run each test'''
        if DEBUG:
            print "\nCmd: %s" % testlib.listless(params, ' ')
        self.assertShellExitEquals(0, params, timeout, logging=logTiming)


# Function to add a tests to the stack
def _add_test(name, doc, param, time=None):
    def test_method(self):
        self.runner(params=param, timeout=time)
    setattr(InitFPGATest, 'test_' + name, test_method)
    test_method.__name__ = 'test_' + name
    test_method.__doc__ = doc


# Function to remove tests from the stack
def _remove_test(cls):
    for name in list(vars(cls)):
        if name.startswith("test_") and callable(getattr(cls, name)):
            delattr(cls, name)


# Test Definitions
def permute_lpbk1():
    mode = 'lpbk1'
    basedoc = 'Validation LPBK1 (Loopback 1) '
    test = 1
    begin,end = cacheLines
    begc = end - 0x10
    for write in writeMode:
        for read in readMode:
            for ccip in CCIPARGS:
                for cl in MCLARGS:
                    if noTime:
                    # once for a long test
                        if cl == '': 
                           begin = cacheLines[0]
                        else:
                           begin = int(cl.split('=')[1],10)
                        cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s" % (
                                  (mode, Target, begin, end, read, write, ccip, cl))
                        name = "lpbk1_long_%03d" % test
                        doc = '%s Long Test %d' % (basedoc, test)
                        _add_test(name, doc, [prog, cmdline])
                    if contMode:
                    # and again for continuous mode
                        cmdline = "--mode=%s --target=%s --cont --timeout-sec=1 --begin=%s --end=%s %s %s %s %s" % (
                                  (mode, Target, begc, end, read, write, ccip, cl))
                        name = "lpbk1_cont_%03d" % test
                        doc = '%s Continuous Test %d' % (basedoc, test)
                        _add_test(name, doc, [prog, cmdline])
                    test += 1

def random_lpbk1(iter):
    mode = 'lpbk1'
    doc = 'Random LPBK1 %s' % iter
    # define our lists
    read = choice(readMode)
    write = choice(writeMode)
    ccip = choice(CCIPARGS)
    cl = choice(MCLARGS)
    if cl == '': 
        clv = 1
    else:
        clv = int(cl.split('=')[1], 10)
    # Pick a mode (Continuous or not) and define variables accordingly
    if contMode and (testlib.cointoss() if noTime else True):
        begin = end = randrange(clv, cacheLines[1], clv)
        tchoice = choice(list(rTimeouts))
        timeout = '--cont %s=%s' % (tchoice, testlib.rint(rTimeouts[tchoice]))
    else:
        timeout = ''
        begin, end = testlib.begin_end(clv, cacheLines[1], clv)
    cmdline = "--mode=%s --target=%s %s --begin=%s --end=%s %s %s %s %s" % (
            (mode, Target, timeout, begin, end, read, write, ccip, cl))
    # Add it to the stack
    name = "random-%s-%s" % (mode, iter)
    _add_test(name, doc, [prog, cmdline])

def permute_sw():
    mode = 'sw'
    basedoc = 'Validation SW Test'
    test = 1
    end = 0x7f
    begin = 3
    for notice in noticeMode:
        for write in writeMode:
            for read in readMode:
                for ccip in CCIPARGS:
                    cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s" % (
                        (mode, Target, begin, end, read, write, noticeMode[notice][0], ccip))
                    name = "sw_%03d" % test
                    doc = '%s %s' % (basedoc, test)
                    _add_test(name, doc, [prog, cmdline])
                    test += 1

def random_sw(iter):
    mode = 'sw'
    doc = 'Random SW Test %s' % iter
    # define our lists
    begin, end = testlib.begin_end(cacheLines[0], cacheLines[1], 1)
    write = choice(writeMode)
    read = choice(readMode)
    notice = noticeMode[choice(list(noticeMode))][testlib.cointoss()]
    ccip = choice(CCIPARGS)
    cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s" % (
              (mode, Target, begin, end, read, write, notice, ccip))
    name = "random-sw-%s" % iter
    # Add it to the stack
    _add_test(name, doc, [prog, cmdline])
        


def permute_read():
    basedoc = 'Validation READ (Streaming Reads)'
    mode = 'read'
    begin,end = cacheLines
    begc = end - 0x10
    test = 1
    for fcache in FPGA_Cache.values():
        for ccache in CPU_Cache.values():
            for read in readMode:
                for ccip in CCIPARGS:
                    for cl in MCLARGS:
                        # once for a long test (all cache lines)
                        if noTime:
                            if cl == '': 
                               begin = cacheLines[0]
                            else:
                               begin = int(cl.split('=')[1],10)
                            cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s %s" % (
                                     (mode, Target, begin, end, fcache[0], ccache[0], read, ccip, cl))
                            name = "read_long_%03d" % test
                            doc = '%s Long Test %s' % (basedoc, test)
                            _add_test(name, doc, [prog, cmdline])
                        # and again for continuous mode
                        if contMode:
                            cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s --cont --timeout-sec=1 %s %s" % (
                                (mode, Target, begc, end, fcache[0], ccache[0], read, ccip, cl))
                            name = "read_cont_%03d" % test
                            doc = '%s Continuous Test %s' % (basedoc, test)
                            _add_test(name, doc, [prog, cmdline])
                        test += 1

def random_read(iter):
    mode = 'read'
    doc = 'Random Read %s' % iter
    # define our lists

    # Pick a cache parameter and flip between long and short parameter
    fcache = FPGA_Cache[choice(list(FPGA_Cache))][testlib.cointoss()]
    ccache = CPU_Cache[choice(list(CPU_Cache))][testlib.cointoss()]
    read = choice(readMode)
    ccip = choice(CCIPARGS)
    cl = choice(MCLARGS)
    if cl == '': 
        clv = 1
    else:
        clv = int(cl.split('=')[1], 10)
    # Pick a mode (Continuous or not) and define variables accordingly
    if contMode and (testlib.cointoss() if noTime else True):
        begin = end = randrange(clv, cacheLines[1], clv)
        tchoice = choice(list(rTimeouts))
        timeout = '%s=%s' % (tchoice, testlib.rint(rTimeouts[tchoice]))
        cmdline = "--mode=%s --target=%s --begin=%s --end=%s --cont %s %s %s %s %s %s" % (
                  (mode, Target, begin, end, timeout, fcache, ccache, read, ccip, cl))
        name = "random-read-cont-%s" % iter
    else:
        begin, end = testlib.begin_end(clv, cacheLines[1], clv)
        cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s %s" % (
            (mode, Target, begin, end, fcache, ccache, read, ccip, cl))
        name = "random-read-long-%s" % iter
    # Add it to the stack
    _add_test(name, doc, [prog, cmdline])



def permute_write():
    mode = 'write'
    basedoc = 'Validation Write (Streaming Writes)'
    test = 1
    begin,end = cacheLines
    begc = end - 0x10
    for fcache in FPGA_Cache.values():
        for ccache in CPU_Cache.values():
            for write in writeMode:
                for ccip in CCIPARGS:
                    for cl in MCLARGS:
                        if noTime:
                            # once for long test
                            if cl == '': 
                               begin = cacheLines[0]
                            else:
                               begin = int(cl.split('=')[1],10)
                            cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s %s" % (
                                (mode, Target, begin, end, fcache[0], ccache[0], write, ccip, cl))
                            name = "write_long_%03d" % test
                            doc = '%s Long Test %s' % (basedoc, test)
                            _add_test(name, doc, [prog, cmdline])
                        if contMode:
                            # and again for continuous mode
                            for timeout in pTimeout:
                                cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s --cont %s %s %s" % (
                                    (mode, Target, begc, end, fcache[0], ccache[0], write, timeout, ccip, cl))
                                name = "write_cont_%03d-%s" % (test, timeout.split('=')[1])
                                doc = '%s Continuous Test %s %s seconds' % (basedoc, test, timeout.split('=')[1])
                                _add_test(name, doc, [prog, cmdline])
                        test += 1

def random_write(iter):
    mode = 'write'
    doc = 'Random Write %s' % iter
    # define our lists
    # Pick a cache parameter and flip between long and short parameter
    fcache = FPGA_Cache[choice(list(FPGA_Cache))][testlib.cointoss()]
    ccache = CPU_Cache[choice(list(CPU_Cache))][testlib.cointoss()]
    write = choice(writeMode)
    ccip = choice(CCIPARGS)
    cl = choice(MCLARGS)
    if cl == '': 
        clv = 1
    else:
        clv = int(cl.split('=')[1], 10)
    # Pick a mode (Continuous or not) and define variables accordingly
    if contMode and (testlib.cointoss() if noTime else True):
        begin = end = randrange(clv, cacheLines[1], clv)
        tchoice = choice(list(rTimeouts))
        timeout = '%s=%s' % (tchoice, testlib.rint(rTimeouts[tchoice]))
        cmdline = "--mode=%s --target=%s --begin=%s --end=%s --cont %s %s %s %s %s %s" % (
            (mode, Target, begin, end, timeout, fcache, ccache, write, ccip, cl))
        name = "random-write-cont-%s" % iter
    else:
        begin, end = testlib.begin_end(clv, cacheLines[1], clv)
        cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s %s" % (
            (mode, Target, begin, end, fcache, ccache, write, ccip, cl))
        name = "random-write-long-%s" % iter
    # Add it to the stack
    _add_test(name, doc, [prog, cmdline])


def permute_trput():
    mode = 'trput'
    basedoc = 'Validation Throughput (Streaming Read-Write)'
    test = 1
    begin,end = cacheLines
    begc = end - 0x10
    for write in writeMode:
        for read in readMode:
            for ccip in CCIPARGS:
                for cl in MCLARGS:
                    if noTime:
                        # once for long test
                        if cl == '': 
                           begin = cacheLines[0]
                        else:
                           begin = int(cl.split('=')[1],10)
                        cmdline = "--mode=%s --target=%s --begin=%s --end=%s %s %s %s %s" % (
                            (mode, Target, begin, end, write, read, ccip, cl))
                        name = "trput-long-%03d" % test
                        doc = '%s Long Test %s' % (basedoc, test)
                        _add_test(name, doc, [prog, cmdline])
                    if contMode:
                        # and again for continuous mode
                       cmdline = "--mode=%s --target=%s --cont --timeout-sec=1 --begin=%s --end=%s %s %s %s %s" % (
                           (mode, Target, begc, end, write, read, ccip, cl))
                       name = "trput-cont-%03d" % test
                       doc = '%s Continuous Test %s' % (basedoc, test)
                       _add_test(name, doc, [prog, cmdline])
                    test += 1

def random_trput(iter):
    mode = 'trput'
    doc = 'Random Throughput %s' % iter
    # define our lists
    write = choice(writeMode)
    read = choice(readMode)
    ccip = choice(CCIPARGS)
    cl = choice(MCLARGS)
    if cl == '': 
        clv = 1
    else:
        clv = int(cl.split('=')[1], 10)
    # Pick a mode (Continuous or not) and define variables accordingly
    if contMode and (testlib.cointoss() if noTime else True):
        begin = end = randrange(clv, cacheLines[1], clv)
        tchoice = choice(list(rTimeouts))
        timeout = '%s=%s' % (tchoice, testlib.rint(rTimeouts[tchoice]))
        name = "random-throughput-cont-%s" % iter
    else:
        begin, end = testlib.begin_end(clv, cacheLines[1], clv)
        timeout = ''
        name = "random-throughput-%s" % iter
    # Add it to the stack
    cmdline = "--mode=%s --target=%s --begin=%s --end=%s --cont %s %s %s %s %s" % (
            (mode, Target, begin, end, timeout, write, read, ccip, cl))
    _add_test(name, doc, [prog, cmdline])

# End of test definitions
def random_tests(tests, iterations):
    for i in range(1, iterations + 1):
        for test in tests:
            random_list[test](i)
        print 'Loop %s of %s' % (i, iterations)
        unittest.main(verbosity=2, exit=False, catchbreak=True, argv=[''])
        _remove_test(InitFPGATest)
        if CRC:
            csr1 = int(testlib.get_csr('0x3b0'), 16)
            csr2 = int(testlib.get_csr('0x3b4'), 16)
            if (csr1 > 1) or csr2:
                print 'CRC Errors Detected! %d/%d' % (csr1, csr2)
            else:
                print 'No CRC errors found.'
        if THERM:
            print 'Temperature: %dC' % testlib.get_temp()


def permute_tests(tests):
    status = 0
    for test in tests:
        permute_list[test]()
    unittest.main(verbosity=2, exit=False, catchbreak=True, argv=[''])
    #status = failures
    _remove_test(InitFPGATest)
    if CRC:
        csr1 = int(testlib.get_csr('0x3b0'), 16)
        csr2 = int(testlib.get_csr('0x3b4'), 16)
        if (csr1 > 1) or csr2:
            print 'CRC Errors Detected! %d/%d' % (csr1, csr2)
        else:
            print 'No CRC errors found.'
    if THERM:
        print 'Temperature: %dC' % testlib.get_temp()
    return 


def main():
    # testlib.require_root()
    global Target
    global DEBUG
    global QUICK
    global noTime
    global CACHE
    global pTimeout
    global rTimeouts
    global permute_list
    global random_list
    global vc_select
    global contMode
    global no_wt
    global READ_MODE
    global CRC
    global THERM
    global CCIPARGS
    global MCLARGS
    global logTiming

    # Test dictionary - alias:function
    permute_list = {'lpbk1': permute_lpbk1, 'read': permute_read,
                    'write': permute_write, 'trput': permute_trput,
                    'sw': permute_sw}
    random_list = {'lpbk1': random_lpbk1, 'read': random_read,
                   'write': random_write, 'trput': random_trput,
                   'sw': random_sw}

    # predefine defaults, change from commandline if needed
    CCIPARGS = vc_select.values()
    MCLARGS = multiCL.values()

    # Thermal sensor CSR enabled? Need to redo in testlib
    # REDO if (int(testlib.get_csr(0x454),16) &256): THERM = True
    # QPI CRC enabled?
    # REDO if int(testlib.get_csr(0x3b0),16): CRC = True

    # Parse commandline
    parser = argparse.ArgumentParser(description='Run tests', argument_default=argparse.SUPPRESS)
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--permute', nargs='*', default=argparse.SUPPRESS, help='Validation tests')
    group.add_argument('--random', nargs='*', default=argparse.SUPPRESS, help='Random tests')
    group.add_argument('--list', action='store_true', default=argparse.SUPPRESS, help='List all tests')
    group2 = parser.add_mutually_exclusive_group(required=False)
    group2.add_argument('-t', '--no-timeout', action='store_true', help='Run without continuous modes')
    group2.add_argument('-q', '--quick', action='store_true', help='Run quick continuous tests only')
    group2.add_argument('-C', '--cont', action='store_true', help='Run all continuous tests only')
    group2.add_argument('-L', '--long', action='store_true', help='Run long continuous tests only (hours)')
    parser.add_argument('-d', '--debug', action='store_true', help='Print cmdline for each test')
    parser.add_argument('-nd', '--no-defaults', dest='noDefaults', action='store_true', 
                        help='Do not generate commandlines with default options')
    parser.add_argument('-s', '--save_timing', action='store_true', help='Saves the run time for an fpgadiag operation.')
    parser.add_argument('-T', '--target', nargs='*', choices=('fpga', 'ase', 'swsim'), help='Change Target - default: fpga.')
    parser.add_argument('-r', '--read-mode', action='store_true', help='Enable read modes testing')
    parser.add_argument('-i', '--iter', dest='loop', type=int, action='store',
                        default=1, help='Number of random iterations to run tests')
    parser.add_argument('-c', '--ccip', nargs='*', default=argparse.SUPPRESS, choices=list(vc_select),
                        help='Run tests with selected channel(s)')
    parser.add_argument('-m', '--mclines', nargs='*', default=argparse.SUPPRESS, choices=list(multiCL),
                        help='Run with specific multi-cachelines')
    myargs = vars(parser.parse_args())
    if 'list' in myargs:
        print 'Permute tests: %s' % testlib.listless(list(permute_list), " ")
        print 'Random tests:  %s' % testlib.listless(list(random_list), " ")
        exit()
    if 'target' in myargs:
        Target = testlib.listless(myargs['target'],"")
    if 'debug' in myargs:
        DEBUG = True
    if 'save_timing' in myargs:
        logTiming = True
    if 'no_timeout' in myargs:
        contMode = False
        noTime = True
    if 'cont' in myargs:
        contMode = True
        noTime = False
    if 'noDefaults' in myargs:
        for mode in (readMode, writeMode):
            mode.remove('')
        for myDict in (noticeMode, FPGA_Cache, vc_select, multiCL):
            del myDict['Default']
        CCIPARGS = vc_select.values()
        MCLARGS = multiCL.values()
    if 'quick' in myargs:
        rTimeouts = {'--timeout-nsec': (10, 100000),
                    '--timeout-usec': (10, 100000),
                    '--timeout-sec': (1, 59),
                   }  
        pTimeout = ['--timeout-sec=1']
        contMode = True
        noTime = False
    if 'long' in myargs:
        rTimeouts = { '--timeout-min': (1, 59),
                    '--timeout-hour': (1, 5),
                   }
        pTimeout = ['--timeout-sec=15']
        contMode = True
        noTime = False
    #  If CCIP argument present, choose correct vchannel from dict.
    if 'ccip' in myargs:
        if len(myargs['ccip']):
            CCIPARGS=[]
            for chan in myargs['ccip']:
                if chan not in vc_select:
                    print "Error: %s is not a valid channel" % chan
                    exit()
                CCIPARGS.append(vc_select[chan]) 

    if 'mclines' in myargs:
        if len(myargs['mclines']):
            MCLARGS=[]
            for cl in myargs['mclines']:
                if cl not in multiCL:
                    print "Error: %s is not a valid cacheline setting" % cl
                    exit()
                MCLARGS.append(multiCL[cl]) 
    
    if 'random' in myargs:
        if not len(myargs['random']):
            myargs['random'] = list(random_list)
        if len(myargs['random']):
            for test in myargs['random']:
                if test not in random_list:
                    print "Error: %s is not a valid test" % test
                    exit()
        random_tests(myargs['random'], myargs['loop'])
    if 'permute' in myargs:
        if not len(myargs['permute']):
            myargs['permute'] = list(permute_list)
        if len(myargs['permute']):
            for test in myargs['permute']:
                if test not in permute_list:
                    print "Error: %s is not a valid test" % test
                    exit()
        stats = permute_tests(myargs['permute'])
        #print 'Status is: %s' % stats.wasSuccessful()

if __name__ == '__main__':
    main()
