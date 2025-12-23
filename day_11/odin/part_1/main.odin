package main

import "core:fmt"
import "core:os"
import "core:strings"

Node :: struct {
	name : string,
	children: [dynamic]i32
}

g_node_name_map : map[string]i32
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

find_path_to_out_node :: proc(curr_node : i32) -> i32 {

	if g_nodes[curr_node].name == "out" {
		return 1
	}

	valid_path_count := i32(0)
	for child_node in g_nodes[curr_node].children {
		valid_path_count += find_path_to_out_node(child_node)
	}

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

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		colon := strings.index(line, ":")

		node_index := node_find_or_create(line[:colon])

		for child_name in strings.split(line[colon+2:], " ") {
			child_node := node_find_or_create(child_name)
			append(&g_nodes[node_index].children, child_node)
		}
	}

	fmt.println(find_path_to_out_node(g_node_name_map["you"]))
}
