import os
import re
import csv
from collections import defaultdict


filename_regex = re.compile(r"^[a-z]+\/(\d+)-(\d+)-\d+.out", flags=re.I)


def parse_metrics_file(f, metrics):
    lines = [l.strip() for l in open(f, "r").readlines()]
    start_idx = 0

    for line in lines:
        if "overflow" in line:
            print("overflowed in", f)
            return
        if "Warning" in line:
            print("failed something", f)
            return

    key = tuple(int(i) for i in filename_regex.findall(f)[0])
    entry = {}

    for i, row in enumerate(lines):
        if row.startswith("Kernel: find_hash(int, int)"):
            start_idx = i+1

    for row in lines[start_idx:]:
        items = row.split()
        metric = items[1]
        val_candidate = list(
            filter(None, [x.strip() for x in items[-1].split("%")]))[0]
        val = float(val_candidate)
        entry[metric] = val

    metrics[key].append(entry)


def average_metrics_results(metrics):
    parsed_metrics = {}

    for run, results in metrics.items():
        metrics_types = results[0].keys()
        average_results = {}

        for metric in metrics_types:
            total = 0
            for r in results:
                total += r[metric]

            average_results[metric] = total / len(results)

        parsed_metrics[run] = average_results

    return parsed_metrics


def parse_metrics_files():
    metrics = defaultdict(list)
    csv_file = open("metrics.csv", "w")
    writer = csv.writer(csv_file)

    for f in os.listdir("./metrics"):
        fn = "metrics/" + f

        if f.endswith(".out"):
            try:
                parse_metrics_file(fn, metrics)
            except Exception as e:
                print(e)
                print(fn)

    parsed_results = average_metrics_results(metrics)

    keys = list(parsed_results.values())[0].keys()
    writer.writerow(["blocks", "threads"] + list(keys))

    for k, v in parsed_results.items():
        blocks, threads = k
        row = [blocks, threads]
        for e in keys:
            row.append(v.get(e))

        writer.writerow(row)
    csv_file.close()


def parse_timings_file(f, timings):
    lines = [l.strip() for l in open(f, "r").readlines()]

    for line in lines:
        if "overflow" in line:
            print("overflowed in", f)
            return
        if "Warning" in line:
            print("failed something", f)
            return

    key = tuple(int(i) for i in filename_regex.findall(f)[0])

    for row in lines:
        if "find_hash(int, int)" in row:
            elements = row.replace("find_hash(int, int)", "").strip().split()
            avg_timing = elements[-3]

            if "ms" in avg_timing:
                factor = 1
                avg_timing = avg_timing.replace("ms", "")
            elif "us" in avg_timing:
                factor = 0.001
                avg_timing = avg_timing.replace("us", "")
            elif "s" in avg_timing:
                factor = 1000
                avg_timing = avg_timing.replace("s", "")

            parsed_timing = float(avg_timing) * factor

            timings[key].append(parsed_timing)
            return


def average_timings_results(timings):
    parsed_timings = {}

    for run, results in timings.items():
        average_results = sum(results)/len(results)

        parsed_timings[run] = average_results

    return parsed_timings


def parse_timings_files():
    timings = defaultdict(list)
    csv_file = open("timings.csv", "w")
    writer = csv.writer(csv_file)

    for f in os.listdir("./memory"):
        fn = "memory/" + f

        if f.endswith(".out"):
            try:
                parse_timings_file(fn, timings)
            except Exception as e:
                print(e)
                print(fn)

    parsed_results = average_timings_results(timings)

    writer.writerow(["blocks", "threads", "time_ms"])

    for k, timing in parsed_results.items():
        blocks, threads = k
        row = [blocks, threads, timing]

        writer.writerow(row)
    csv_file.close()


def parse_event_file(f, events):
    lines = [l.strip() for l in open(f, "r").readlines()]
    start_idx = 0

    for line in lines:
        if "overflow" in line:
            print("overflowed in", f)
            return
        if "Warning" in line:
            print("failed something", f)
            return

    key = tuple(int(i) for i in filename_regex.findall(f)[0])

    entry = {}

    for i, row in enumerate(lines):
        if row.startswith("Kernel: find_hash(int, int)"):
            start_idx = i+1

    for row in lines[start_idx:]:
        items = row.split()
        event = items[1]
        val = float(items[-1])
        entry[event] = val

    events[key].append(entry)


def average_event_results(events):
    parsed_events = {}

    for run, results in events.items():
        event_types = results[0].keys()
        average_results = {}

        for event in event_types:
            total = 0
            for r in results:
                total += r[event]

            average_results[event] = total / len(results)

        parsed_events[run] = average_results

    return parsed_events


def parse_event_files():
    events = defaultdict(list)
    csv_file = open("events.csv", "w")
    writer = csv.writer(csv_file)

    for f in os.listdir("./events"):
        if f.endswith(".out"):
            fn = "events/" + f
            try:
                parse_event_file(fn, events)
            except Exception as e:
                print(e)
                print(fn)

    parsed_results = average_event_results(events)

    keys = list(parsed_results.values())[0].keys()
    writer.writerow(["blocks", "threads"] + list(keys))

    for k, v in parsed_results.items():
        blocks, threads = k
        row = [blocks, threads]
        for e in keys:
            row.append(v.get(e))

        writer.writerow(row)
    csv_file.close()


if __name__ == "__main__":
    print("parsing metrics")
    parse_metrics_files()
    print("parsing timings")
    parse_timings_files()
    print("parsing events")
    parse_event_files()
