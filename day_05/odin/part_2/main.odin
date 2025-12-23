package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"

Range :: struct {
	min: i64,
	max: i64,
}

ranges_overlap :: proc( lhs: Range, rhs: Range) -> bool {
	return lhs.min <= rhs.max && lhs.max >= rhs.min
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	ranges : [dynamic]Range

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {
			break
		}

		tokens := strings.split(line, "-")
		new_range : Range
		new_range.min = strconv.parse_i64(tokens[0]) or_continue
		new_range.max = strconv.parse_i64(tokens[1]) or_continue

		overlaps := false
		for range, index in ranges {
			if (ranges_overlap(range, new_range)) {
				ranges[index].min = math.min(range.min, new_range.min)
				ranges[index].max = math.max(range.max, new_range.max)
				overlaps = true
			}
		}

		if !overlaps {
			append(&ranges, new_range)
		}
	}

	for detected_overlap := true; detected_overlap; {
		detected_overlap = false

		for lhs := 0; lhs < len(ranges); lhs += 1 {
			for rhs := lhs + 1; rhs < len(ranges); rhs += 1 {
				if ranges_overlap(ranges[lhs], ranges[rhs]) {
					detected_overlap = true
					ranges[lhs].min = math.min(ranges[lhs].min, ranges[rhs].min)
					ranges[lhs].max = math.max(ranges[lhs].max, ranges[rhs].max)
					unordered_remove(&ranges, rhs)
				}
			}
		}
	}

	total : i64 = 0
	for range in ranges {
		fmt.printfln("%16d - %16.d", range.min, range.max)
		total += range.max - range.min + 1
	}

	fmt.printfln("Result = %d", total)
}
