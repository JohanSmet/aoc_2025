package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

DIAL_INITIAL_VALUE :: 50
DIAL_RANGE :: 100

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	dial_value := DIAL_INITIAL_VALUE
	count := 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		dir := line[:1]
		n, ok := strconv.parse_int(line[1:])

		if ok {
			full_rounds := n / 100
			count += full_rounds

			n := n % 100

			if dir == "L" {
				if dial_value != 0 && dial_value - n < 0 {
					count += 1
				}
				dial_value -= n
			} else {
				if dial_value != 0 && dial_value + n > DIAL_RANGE {
					count += 1
				}
				dial_value += n
			}

			dial_value = (dial_value + DIAL_RANGE) % DIAL_RANGE
			if dial_value == 0 {
				count += 1
			}
		}
	}

	fmt.printfln("Result = %d", count)
}
