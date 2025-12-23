package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

Range :: struct {
	min: i64,
	max: i64,
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	reading_ranges := true
	ranges : [dynamic]Range
	ingredients : [dynamic]i64

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		if len(line) == 0 {
			reading_ranges = false
			continue
		}

		if reading_ranges {
			tokens := strings.split(line, "-")
			r : Range
			r.min = strconv.parse_i64(tokens[0]) or_continue
			r.max = strconv.parse_i64(tokens[1]) or_continue
			append(&ranges, r)
		} else {
			id := strconv.parse_i64(line) or_continue
			append(&ingredients, id)
		}
	}

	total : i64 = 0

	for ingredient in ingredients {

		is_fresh := false
		for range in ranges {
			if ingredient >= range.min && ingredient <= range.max {
				is_fresh = true
				break
			}
		}

		total += is_fresh ? 1 : 0
	}

	fmt.printfln("Result = %d", total)
}
