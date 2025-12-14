package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"
import "core:math"

Vec2 :: [2]i64
CoordMap :: map[i64]i64

g_grid : [dynamic]i32
g_coord_map : [2]CoordMap
g_dims : Vec2

area :: proc(a, b : Vec2) -> i64 {
	return (math.abs(a[0] - b[0]) + 1) * (math.abs(a[1] - b[1]) + 1)
}

map_point :: proc(v : Vec2) -> Vec2 {
	return Vec2 { g_coord_map[0][v[0]], g_coord_map[1][v[1]] }
}

set_pixel :: proc(p : Vec2, value : i32) {
	g_grid[(p[1] * g_dims[0]) + p[0]] = value
}

draw_line :: proc(p1, p2 : Vec2) {

	mapped_p1 := map_point(p1)
	mapped_p2 := map_point(p2)

	set_pixel(mapped_p1, 1)
	set_pixel(mapped_p2, 1)

	delta : Vec2 = mapped_p1[0] == mapped_p2[0] ? { 0, mapped_p2[1] > mapped_p1[1] ? 1 : -1 } : { mapped_p2[0] > mapped_p1[0] ? 1 : -1, 0 }

	for v := mapped_p1 + delta; v != mapped_p2; v += delta {
		set_pixel(v, 2)
	}
}

fill_insides :: proc() {
	for y : i64 = 0; y < g_dims[1]; y += 1 {
		inside := false
		for x : i64 = 0; x < g_dims[0]; x += 1 {
			is_boundary := g_grid[y * g_dims[0] + x] != 0

			if is_boundary {
				// A crossing occurs if the boundary continues "up" from here.
				// This handles corners and horizontal lines correctly for HV polygons.
				if y > 0 && g_grid[(y - 1) * g_dims[0] + x] != 0 {
					inside = !inside
				}
			} else { // Not a boundary
				if inside {
					set_pixel(Vec2{x, y}, 2)
				}
			}
		}
	}
}

is_valid_rectangle :: proc(p1, p2 : Vec2) -> bool {

	mapped_p1 := map_point(p1)
	mapped_p2 := map_point(p2)

	x1 := math.min(mapped_p1[0], mapped_p2[0])
	x2 := math.max(mapped_p1[0], mapped_p2[0])
	y1 := math.min(mapped_p1[1], mapped_p2[1])
	y2 := math.max(mapped_p1[1], mapped_p2[1])

	for y := y1; y <= y2; y += 1 {
		for x := x1; x <= x2; x += 1 {
			if g_grid[y * g_dims[0] + x] == 0 {
				return false
			}
		}
	}

	return true
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	points: [dynamic]Vec2
	defer delete(points)

	// parse input
	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		tokens := strings.split(line, ",")

		v : Vec2
		v[0], _ = strconv.parse_i64(tokens[0])
		v[1], _ = strconv.parse_i64(tokens[1])
		append(&points, v)
	}

	// compress the coordinate space
	unique_coords: [2][dynamic]i64
	reserve(&unique_coords[0], len(points))
	reserve(&unique_coords[1], len(points))

	for p in points {
		append(&unique_coords[0], p[0])
		append(&unique_coords[1], p[1])
	}

	slice.sort(unique_coords[0][:])
	slice.sort(unique_coords[1][:])

	g_dims = Vec2{ 1, 1 }

	for i := 0; i < 2; i += 1 {
		g_coord_map[i] = make(CoordMap)

		for v in slice.unique(unique_coords[i][:]) {
			g_coord_map[i][v] = g_dims[i]
			g_dims[i] += 2
		}
	}

	// create grid
	fmt.println("compressed dimension", g_dims)

	resize(&g_grid, g_dims[0] * g_dims[1])
	slice.fill(g_grid[:], 0)

	fmt.println("Draw outline")
	prev_point := points[0]
	for idx := 1; idx < len(points); idx += 1 {
		draw_line(prev_point, points[idx])
		prev_point = points[idx]
	}
	draw_line(prev_point, points[0])

	fmt.println("Fill insides")
	fill_insides()

	// find biggest area
	fmt.println("Checking rects")
	biggest_area : i64 = 0
	for i : i32 = 0; i < i32(len(points)); i += 1 {
		for j : i32 = i + 1; j < i32(len(points)); j += 1 {
			if is_valid_rectangle(points[i], points[j]) {
				biggest_area = math.max(biggest_area, area(points[i], points[j]))
			}
		}
	}

	fmt.println(biggest_area)
}
