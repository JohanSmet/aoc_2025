package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"

sample_string :: proc(line: string, idx: int) -> u8 {
	if idx < len(line) {
		return line[idx]
	} else {
		return ' '
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
	operands: [dynamic]i64
	max_len := 0

	for line in strings.split_lines_iterator(&it) {
		append(&lines, line)
		max_len = math.max(max_len, len(line))
	}

	op_line := len(lines) - 1

	total : i64 = 0

	for index := max_len - 1; index >= 0; index -= 1 {

		operand: i64
		for operand_idx := 0; operand_idx < op_line; operand_idx += 1 {
			digit := sample_string(lines[operand_idx], index)
			if digit != ' ' {
				operand = (operand * 10) + i64(digit - '0')
			}
		}

		if operand != 0 {
			append(&operands, operand)
		}

		operator := sample_string(lines[op_line], index)
		if operator != ' ' {

			line_result := operands[0]

			for op_idx := 1; op_idx < len(operands); op_idx += 1 {
				if operator == '+' {
					line_result += operands[op_idx]
				} else {
					line_result *= operands[op_idx]
				}
			}

			total += line_result
			clear(&operands)
		}
	}

	fmt.printfln("Result = %d", total)
}
