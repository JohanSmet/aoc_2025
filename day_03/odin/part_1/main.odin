package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

maximum_joltage :: proc(bank : string) -> i64 {

	str_len := len(bank)

	first_digits := [10]int{-1, -1, -1, -1, -1, -1, -1, -1, -1, -1}

	for idx := str_len - 2; idx >= 0; idx -= 1 {
		digit := bank[idx] - '0'
		first_digits[digit] = idx
	}

	joltage : i64 = 0
	start_at := 0

	for digit : i64 = 9; digit > 0; digit -= 1 {
		if (first_digits[digit] > -1) {
			joltage = digit * 10
			start_at = first_digits[digit] + 1
			break
		}
	}

	biggest : u8 = 0
	for idx := start_at; idx < str_len; idx += 1 {
		digit := bank[idx] - '0'
		if digit > biggest {
			biggest = digit
		}
	}

	joltage += i64(biggest)
	return joltage
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
		total += maximum_joltage(line)
	}

	fmt.printfln("Result = %d", total)
}
