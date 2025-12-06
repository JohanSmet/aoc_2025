package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

has_roll :: proc(grid : [dynamic]string, row: int, col: int) -> int {

	if row < 0 || row >= len(grid) {
		return 0
	}

	if col < 0 || col >= len(grid[row]) {
		return 0
	}

	return grid[row][col] == '@' ? 1 : 0
}

sample :: proc(grid : [dynamic]string, row: int, col: int) -> int {

	result := has_roll(grid, row - 1, col - 1)
	result += has_roll(grid, row - 1, col)
	result += has_roll(grid, row - 1, col + 1)

	result += has_roll(grid, row, col - 1)
	result += has_roll(grid, row, col + 1)

	result += has_roll(grid, row + 1, col - 1)
	result += has_roll(grid, row + 1, col)
	result += has_roll(grid, row + 1, col + 1)

	return result
}


main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	total : int = 0

	grid : [dynamic]string
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		append(&grid, line)
	}

	for row := 0; row < len(grid); row +=1 {
		for col := 0; col < len(grid[row]); col += 1 {
			if grid[row][col] == '@' && sample(grid, row, col) < 4 {
				total += 1
			}
		}
	}

	fmt.printfln("Result = %d", total)
}
