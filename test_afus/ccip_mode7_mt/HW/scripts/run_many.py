#!/usr/bin/env python
import json
import subprocess
import itertools
import tempfile
import sys
import time

def run_mtnlb(threads, max_count, stride, mode, rw_channels, rw_modes, verbose=True):
    with open(tempfile.mktemp(suffix='.json', prefix='nlb-'), 'w') as tmp:
        conf_file = tmp.name
        json.dump({ "verbose" : verbose,
                    "channels" : rw_channels,
                    "modes" : rw_modes }, tmp, indent=4)
    cmd = "mtnlb -t {threads} -M {max_count} -m {mode} -r {stride} -C {conf_file}".format(**locals())
    print(cmd)
    output = subprocess.check_output(cmd, shell=True)
    print(output)
    if output.find("Test: ERROR")>=0 :
        sys.exit(-1)
    #time.sleep(10)      

def run_many(thread_range, max_count_range, stride_range, mode, read_channels, write_channels, read_modes, write_modes, verbose):
    for t,mc,r,rc,wc,rm,wm in itertools.product(thread_range, max_count_range, stride_range, read_channels, write_channels,  read_modes, write_modes):
        run_mtnlb(t, mc, r, mode, {'read':rc,
                                   'write':wc}, 
                                  {'read': rm, 
                                   'write': wm}, 
                                    verbose)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--threads', nargs='*', default=range(1,128),
                        help='list of thread counts to use')
    parser.add_argument('-r', '--stride', nargs='*', default=[2,4,8,16,32,64,512,1024],
                        help=' stride offsets')                     
    parser.add_argument('-M', '--max-counts', nargs='*', default=range(1,65535, +10001),
                        help='list of max counts to use')
    parser.add_argument('-m', '--mode', choices=['mt7', 'mt8'],
                        help='what mode to use (multi-threaded nlb7 or multi-threaded nlb8)')
    parser.add_argument('--rc', nargs='*', default=['vl0'], choices=['vl0', 'vh0', 'vh1', 'va'],
                        help='read channels to use')
    parser.add_argument('--wc', nargs='*', default=['vl0'], choices=['vl0', 'vh0', 'vh1', 'va'],
                        help='write channels to use')
    parser.add_argument('--rm', nargs='*', default=['rdline_s'], choices=['rdline_i', 'rdline_s'],
                        help='read modes to use')
    parser.add_argument('--wm', nargs='*', default=['wrline_m'], choices=['wrline_m', 'wrline_i', 'wrpush_i'],
                        help='write modes to use')
    parser.add_argument('--verbose', default=False, action='store_true',
                        help='run mtnlb in verbose mode')

    args = parser.parse_args()
    for i in range(1):
        run_many(args.threads, args.max_counts, args.stride, args.mode, args.rc, args.wc, args.rm, args.wm, args.verbose)
