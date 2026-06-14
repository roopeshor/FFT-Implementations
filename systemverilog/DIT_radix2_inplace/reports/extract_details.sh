for f in master_report*.txt ; do
	grep -m 1 "^| fft_radix2   "  "$f" >> "summary_${f:14}.txt"
	grep -m 1 "^Logical Nets:"  "$f" >> "summary_${f:14}.txt"
	grep -m 1 "^   # of logical nets"  "$f" >> "summary_${f:14}.txt"
	grep -m 1 -A 2 "^    WNS(ns)"  "$f" | tail -n 1 >> "summary_${f:14}.txt"
	grep -m 1 "^| Total On-Chip Power (W)"  "$f" >> "summary_${f:14}.txt"
done
