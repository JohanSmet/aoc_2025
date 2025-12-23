package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

validate_id :: proc(id : i64) -> bool {
	buf : [32]byte

	str_id := fmt.bprint(buf[:], id)
	str_len := len (str_id)

	if str_len % 2 == 1 {
		return true
	}

	l_part := str_id[:str_len/2]
	r_part := str_id[str_len/2:]

	return l_part != r_part
}

process_range :: proc(range: string) -> i64 {
	limits := strings.split(range, "-")

	lower_limit, ok_l := strconv.parse_i64(limits[0])
	upper_limit, ok_u := strconv.parse_i64(limits[1])

	if !ok_l || !ok_u {
		return 0
	}

	total : i64 = 0

	for id := lower_limit; id <= upper_limit; id += 1 {
		if !validate_id(id) {
			total += id;
		}
	}

	return total
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	total : i64 = 0

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		for range in strings.split(line, ",") {
			total += process_range(range)
		}
	}

	fmt.printfln("Result = %d", total)
}
