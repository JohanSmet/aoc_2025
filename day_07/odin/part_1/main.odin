package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

CHAR_EMPTY :: '.'
CHAR_SPLITTER :: '^'
CHAR_BEAM_START :: 'S'
CHAR_BEAM :: '|'

TOKEN_EMPTY :: 0
TOKEN_SPLITTER :: 1
TOKEN_BEAM :: 2

print_manifold :: proc(manifold : [dynamic][dynamic]u8) {
	for manifold_line in manifold {
		for manifold_char in manifold_line {
			if manifold_char == TOKEN_EMPTY {
				fmt.print(CHAR_EMPTY)
			} else if manifold_char == TOKEN_SPLITTER {
				fmt.print(CHAR_SPLITTER)
			} else if manifold_char == TOKEN_BEAM {
				fmt.print(CHAR_BEAM)
			}
		}
		fmt.println()
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
	manifold : [dynamic][dynamic]u8

	for line in strings.split_lines_iterator(&it) {
		manifold_line : [dynamic]u8
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

	count_split := 0

	for index := 1; index < len(manifold); index += 1 {
		prev := manifold[index - 1]
		next := manifold[index]

		for c := 0; c < len(prev); c += 1 {
			if prev[c] != TOKEN_BEAM {
				continue
			}

			if next[c] == TOKEN_SPLITTER {
				count_split += 1

				if c > 0 {
					next[c-1] = TOKEN_BEAM
				}

				if c + 1 < len(next) {
					next[c+1] = TOKEN_BEAM
				}

			} else {
				next[c] = TOKEN_BEAM
			}
		}
	}
	//print_manifold(manifold)
	fmt.printfln("Result = %d", count_split)
}
