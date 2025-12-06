package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

BATTERY_COUNT : int : 12;

maximum_joltage :: proc(bank : string) -> i64 {

	str_len := len(bank)
	joltage : i64 = 0

	bank_idx := 0
	battery_count := 0

	for discardable_count := str_len - BATTERY_COUNT + 1; discardable_count > 0 && bank_idx < str_len && battery_count < BATTERY_COUNT; {

		max_digit := 0
		max_digit_idx := -1

		for idx := bank_idx; idx < bank_idx + discardable_count && idx < str_len; idx += 1 {
			digit := int(bank[idx] - '0')

			if digit > max_digit {
				max_digit = digit
				max_digit_idx = idx
			}
		}

		joltage = (joltage * 10) + i64(max_digit)
		battery_count += 1
		discardable_count -= max_digit_idx - bank_idx
		bank_idx = max_digit_idx + 1
	}

	for idx := bank_idx; idx < str_len && battery_count < BATTERY_COUNT; idx += 1 {
		digit := i64(bank[idx] - '0')
		joltage = (joltage * 10) + digit
		battery_count += 1
	}

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
