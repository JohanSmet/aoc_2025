package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

Vec3 :: [3]i64

Pair :: struct {
	point_a : i32,
	point_b : i32,
	dist_sq : i64
}

g_points : [dynamic]Vec3
g_pairs: [dynamic]Pair

UnionFind :: struct {
	parent : [dynamic]i32,
	size: [dynamic]i32
}

unionfind_init :: proc(uf: ^UnionFind, n: i32) {
	resize(&uf.parent, n)
	resize(&uf.size, n)

	for i : i32 = 0; i < n; i += 1 {
		uf.parent[i] = i
		uf.size[i] = 1
	}
}

unionfind_findrep :: proc(uf: ^UnionFind, i: i32) -> i32 {
	rep := uf.parent[i]

	if uf.parent[rep] != rep {
		uf.parent[rep] = unionfind_findrep(uf, rep)
		return uf.parent[rep]
	}

	return rep
}

unionfind_union :: proc(uf: ^UnionFind, i, j : i32) {

	i_rep := unionfind_findrep(uf, i)
	j_rep := unionfind_findrep(uf, j)

	if i_rep == j_rep {
		// already in the same set
		return
	}

	if uf.size[i_rep] < uf.size[j_rep] {
		uf.parent[i_rep] = j_rep
		uf.size[j_rep] += uf.size[i_rep]
		uf.size[i_rep] = 0
	} else {
		uf.parent[j_rep] = i_rep
		uf.size[i_rep] += uf.size[j_rep]
		uf.size[j_rep] = 0
	}
}

square :: proc(a: i64) -> i64 {
	return a * a
}

distance_sq :: proc(a : Vec3, b : Vec3) -> i64 {
	return square(a[0] - b[0]) + square(a[1] - b[1]) + square(a[2] - b[2])
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		tokens := strings.split(line, ",")

		v : Vec3
		v[0] = strconv.parse_i64(tokens[0]) or_continue
		v[1] = strconv.parse_i64(tokens[1]) or_continue
		v[2] = strconv.parse_i64(tokens[2]) or_continue

		append(&g_points, v)
	}

	iterations : i32 = len(g_points) > 20 ? 1000 : 10

	// build a sorted list of pairs based on their distance
	for i : i32 = 0; i < i32(len(g_points)); i += 1 {
		for j : i32 = i + 1; j < i32(len(g_points)); j += 1 {
			append(&g_pairs, Pair {
				point_a = i,
				point_b = j,
				dist_sq = distance_sq(g_points[i], g_points[j])
			})
		}
	}

	slice.sort_by(g_pairs[:], proc(lhs, rhs: Pair) -> bool {
		return lhs.dist_sq < rhs.dist_sq
	})

	// join the closest pairs
	uf_set : UnionFind
	unionfind_init(&uf_set, i32(len(g_points)))

	for idx : i32 = 0; idx < iterations; idx += 1 {
		unionfind_union(&uf_set, g_pairs[idx].point_a, g_pairs[idx].point_b)
	}

	// construct puzzle output
	set_sizes := slice.clone(uf_set.size[:])
	defer delete(set_sizes)

	slice.sort_by(set_sizes, proc(lhs, rhs : i32) -> bool { return lhs > rhs })
	fmt.println(set_sizes[0] * set_sizes[1] * set_sizes[2])
}
