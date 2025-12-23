package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

cut_string :: proc(line : string, l : int, r: int) -> string {
	if l == r {
		return strings.trim(line[l:], " ")
	} else {
		return strings.trim(line[l:r], " ")
	}
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	lines : [dynamic]string
	for line in strings.split_lines_iterator(&it) {
		append(&lines, line)
	}

	op_line := len(lines) - 1
	next_index := 0
	total: i64 = 0

	outer_loop: for index := 0; index < len(lines[op_line]); index = next_index {

		for next_index = index + 1; next_index < len(lines[op_line]) && lines[op_line][next_index] == ' '; next_index += 1 {}

		operator := lines[op_line][index]

		line_result := strconv.parse_i64(cut_string(lines[0], index, next_index < len(lines[op_line]) ? next_index : index)) or_continue

		for number_line := 1; number_line < len(lines) - 1; number_line += 1 {
			operand := strconv.parse_i64(cut_string(lines[number_line], index, next_index < len(lines[op_line]) ? next_index : index)) or_continue outer_loop

			if operator == '+' {
				line_result += operand
			} else {
				line_result *= operand
			}
		}

		total += line_result
	}

	fmt.printfln("Result = %d", total)
}
