import sys
import os
import csv
import re
from collections import defaultdict

time_regex = re.compile(r"(\d+(?:.\d+)?)m(\d+(?:.\d+)?)s")


def parse_subdir(dir_name):
    res = { "omp": defaultdict(list), "cu": defaultdict(list) }
    for f in os.listdir(dir_name):
        parse_file(dir_name, f, res)

    outfile = open("%s.csv" % dir_name.strip("./\\\s"), "w")
    writer = csv.writer(outfile, lineterminator="\n")
    writer.writerow(["program", "size", "time"])

    for prog in res.keys():
        for size in res[prog].keys():
            values = res[prog][size]
            average_timing = sum(values)/len(values)
            writer.writerow([prog, size, average_timing])

    outfile.close()


def parse_file(dir_name, f, res):
    if not f.endswith(".out"):
        return

    prog, size, run = f[:-(len(".out"))].split("-")

    real = list(filter(lambda x: "real" in x, open(dir_name + f, "r").readlines()))[0].strip()
    timing_parts = time_regex.findall(real.split()[1])[0]
    timing = float(timing_parts[0]) * 60 + float(timing_parts[1])

    res[prog][size].append(timing)

if __name__ == "__main__":
    subdir = sys.argv[1]
    parse_subdir(subdir)
