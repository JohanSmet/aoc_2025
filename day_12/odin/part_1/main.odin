package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	it := string(data)

	count_fit := 0

	for line in strings.split_lines_iterator(&it) {
		if !strings.contains(line, "x") { continue }

		parts := strings.split_multi(line, { " ", "x", ": " })
		assert(len(parts) == 8)

		grid_w, _ := strconv.parse_int(parts[0])
		grid_h, _ := strconv.parse_int(parts[1])

		total_gifts := 0
		for i in 0..<6 {
			gifts, _ := strconv.parse_int(parts[i+2])
			total_gifts += gifts
		}

		grid_w = (grid_w / 3) * 3
		grid_h = (grid_h / 3) * 3

		if (total_gifts * 9) <= (grid_w * grid_h) {
			count_fit += 1
		}
	}

	fmt.println(count_fit)
}
