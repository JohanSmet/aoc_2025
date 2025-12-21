package main

import "core:fmt"
import "core:os"
import "core:strings"

Node :: struct {
	name : string,
	children: [dynamic]i32
}

g_node_name_map : map[string]i32
g_cache: map[i64]i64
g_nodes : [dynamic]Node

node_find_or_create :: proc(name : string) -> i32 {

	node_index, exists := g_node_name_map[name]
	if !exists {
		node_index = i32(len(g_nodes))
		append(&g_nodes, Node {})
		g_nodes[node_index].name = name
		g_node_name_map[name] = node_index
	}

	return node_index
}

cache_construct_key :: proc(curr_node : i32, has_dac, has_fft : bool) -> i64 {
	key : i64 = has_dac ? 1 : 0
	key |= has_fft ? 2 : 0
	key |= i64(curr_node) << 2
	return key
}

cache_add :: proc(curr_node : i32, has_dac, has_fft: bool, path_count : i64) {
	key := cache_construct_key(curr_node, has_dac, has_fft)
	g_cache[key] = path_count
}


find_path_to_out_node :: proc(curr_node : i32, has_dac, has_fft : bool) -> i64 {

	cached_count, cache_found := g_cache[cache_construct_key(curr_node, has_dac, has_fft)]
	if cache_found {
		return cached_count
	}

	if g_nodes[curr_node].name == "out" {
		return has_dac && has_fft ? 1 : 0
	}

	has_dac := has_dac || g_nodes[curr_node].name == "dac"
	has_fft := has_fft || g_nodes[curr_node].name == "fft"

	valid_path_count := i64(0)
	for child_node in g_nodes[curr_node].children {
		valid_path_count += find_path_to_out_node(child_node, has_dac, has_fft)
	}

	cache_add(curr_node, has_dac, has_fft, valid_path_count)
	return valid_path_count
}

main :: proc() {

	data, ok := os.read_entire_file_from_handle(os.stdin, context.allocator)
	if !ok {
		fmt.println("Error reading input")
		return
	}
	defer delete(data, context.allocator)

	g_node_name_map = make(map[string]i32)
	g_cache = make(map[i64]i64)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		colon := strings.index(line, ":")

		node_index := node_find_or_create(line[:colon])

		for child_name in strings.split(line[colon+2:], " ") {
			child_node := node_find_or_create(child_name)
			append(&g_nodes[node_index].children, child_node)
		}
	}

	fmt.println(find_path_to_out_node(g_node_name_map["svr"], false, false))
}
