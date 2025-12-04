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

	dial := 50
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
				if dial != 0 && dial - n < 0 {
					count += 1
				}
				dial -= n
			} else {
				if dial != 0 && dial + n > 100 {
					count += 1
				}
				dial += n
			}

			dial = (dial + 100) % 100
			if dial == 0 {
				count += 1
			}
		}
	}

	fmt.printfln("Result = %d", count)
}
