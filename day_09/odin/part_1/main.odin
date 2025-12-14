package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

Vec2 :: [2]i64

area :: proc(a, b : Vec2) -> i64 {
	return (math.abs(a[0] - b[0]) + 1) * (math.abs(a[1] - b[1]) + 1)
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	points: [dynamic]Vec2

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		tokens := strings.split(line, ",")

		v : Vec2
		v[0], _ = strconv.parse_i64(tokens[0])
		v[1], _ = strconv.parse_i64(tokens[1])

		append(&points, v)
	}

	biggest_area : i64 = 0

	for i : i32 = 0; i < i32(len(points)); i += 1 {
		for j : i32 = i + 1; j < i32(len(points)); j += 1 {
			biggest_area = math.max(biggest_area, area(points[i], points[j]))
		}
	}

	fmt.println(biggest_area)
}
