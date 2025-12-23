package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

validate_id :: proc(id : i64) -> bool {

	buf : [32]byte
	str_id := fmt.bprint(buf[:], id)
	str_len := len (str_id)

	for count := 1; count <= str_len / 2; count += 1 {

		if str_len % count > 0 {
			continue
		}

		ref := str_id[:count]
		differs := false

		for idx := count; idx + count <= str_len && !differs; idx += count {
			differs = ref != str_id[idx:idx+count]
		}

		if (!differs) {
			return false
		}
	}

	return true
}

process_range :: proc(range: string) -> (total : i64, ok : bool) {
	limits := strings.split(range, "-")

	lower_limit := strconv.parse_i64(limits[0]) or_return
	upper_limit := strconv.parse_i64(limits[1]) or_return

	for id := lower_limit; id <= upper_limit; id += 1 {
		if !validate_id(id) {
			total += id;
		}
	}

	return total, true
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
			total += process_range(range) or_continue
		}
	}

	fmt.printfln("Result = %d", total)
}
