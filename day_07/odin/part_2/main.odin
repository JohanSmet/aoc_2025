package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

CHAR_EMPTY :: '.'
CHAR_SPLITTER :: '^'
CHAR_BEAM_START :: 'S'
CHAR_BEAM :: '|'

TOKEN_EMPTY : i64 : 0
TOKEN_SPLITTER : i64 : -1
TOKEN_BEAM : i64: 1

print_manifold :: proc(manifold : [dynamic][dynamic]i64) {
	for manifold_line in manifold {
		for count in manifold_line {
			fmt.printf("%2d ", count)
		}

		fmt.println();
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

	manifold : [dynamic][dynamic]i64

	for line in strings.split_lines_iterator(&it) {
		manifold_line : [dynamic]i64
		for char in line {
			if char == CHAR_SPLITTER {
				append(&manifold_line, TOKEN_SPLITTER)
			} else if char == CHAR_BEAM_START {
				append(&manifold_line, TOKEN_BEAM)
			} else if char == CHAR_BEAM {
				append(&manifold_line, TOKEN_BEAM)
			} else {
				append(&manifold_line, TOKEN_EMPTY)
			}
		}

		append(&manifold, manifold_line)
	}

	for index := 1; index < len(manifold); index += 1 {
		prev := manifold[index - 1]
		next := manifold[index]

		for c := 0; c < len(prev); c += 1 {
			if prev[c] == TOKEN_EMPTY {
				if next[c] == TOKEN_SPLITTER {
					next[c] = 0
				}
				continue
			}

			if next[c] == TOKEN_SPLITTER {
				next[c - 1] += prev[c]
				next[c] = 0
				next[c + 1] += prev[c]
			} else {
				next[c] += prev[c]
			}
		}
	}

	total : i64 = 0
	for count in manifold[len(manifold) - 1] {
		if count > 0 {
			total += count
		}
	}

	fmt.printfln("Result = %d", total)
}
