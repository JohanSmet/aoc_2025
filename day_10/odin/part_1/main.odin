package part_1

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:mem"
import "core:slice"

LightSet :: []bool

MachineData :: struct {
    target_lights: LightSet,
	button_configs: []LightSet,
    joltage_requirements: []i32,
}

parse_light_diagram :: proc(diagram_str: string) -> LightSet {
    content := strings.trim_space(strings.trim_prefix(strings.trim_suffix(diagram_str, "]"), "["))

    target_lights := make(LightSet, len(content))

    for c, idx in content {
		target_lights[idx] = c == '#'
    }

    return target_lights
}

parse_button_schematic :: proc(schematic_str: string, num_buttons: int) -> LightSet {
    buttons := make(LightSet, num_buttons)
    content := strings.trim_prefix(strings.trim_suffix(schematic_str, ")"), "(")

    for light_index_str in strings.split(content, ",") {
        light_index_val, _ := strconv.parse_int(strings.trim_space(light_index_str))
        buttons[light_index_val] = true
    }

    return buttons
}

parse_joltage_requirements :: proc(joltage_str: string) -> []i32 {
    content := strings.trim_prefix(strings.trim_suffix(joltage_str, "}"), "{")

    parts := strings.split(content, ",")
    joltage_values := make([]i32, len(parts))

    for i := 0; i < len(parts); i += 1 {
        val, _ := strconv.parse_int(strings.trim_space(parts[i]))
        joltage_values[i] = i32(val)
    }

    return joltage_values
}

parse_machine_line :: proc(line: string, allocator: mem.Allocator) -> MachineData {
    diagram_end := strings.index(line, "]")
	joltage_start := strings.last_index(line, "{")

    str_diagram := line[:diagram_end+1]
	str_buttons := line[diagram_end+2:joltage_start-1]
	str_joltage := line[joltage_start:]

    target_lights := parse_light_diagram(str_diagram)

    button_parts := strings.split(str_buttons, " ")
	button_configs := make([]LightSet, len(button_parts))

    for part, button_idx in button_parts {
        button_configs[button_idx] = parse_button_schematic(part, len(target_lights))
    }

    joltage_requirements := parse_joltage_requirements(str_joltage)

    return MachineData {
        target_lights = target_lights,
		button_configs = button_configs,
        joltage_requirements = joltage_requirements,
    }
}

print_machine :: proc(machine : MachineData) {
	fmt.printfln("  Target Lights: ", machine.target_lights)
	fmt.print("  Button Configurations:")
	for btn_config in machine.button_configs {
		fmt.printf(" ", btn_config)
	}
	fmt.println()
	fmt.print("  Joltage Requirements: ")
	for joltage_val in machine.joltage_requirements {
		fmt.printf("%d ", joltage_val)
	}
	fmt.println("\n")
}

print_matrix :: proc(m: [][]bool) {

	for row := 0; row < len(m[0]); row += 1 {
		for col := 0; col < len(m); col += 1 {
			fmt.print(m[col][row] ? "1" : "0", " ")
		}
		fmt.println();
	}
	fmt.println()
}

swap_row :: proc(m: [][]bool, i, j : int) {
	for col := 0; col < len(m); col += 1 {
		m[col][i], m[col][j] = m[col][j], m[col][i]
	}
}

gaussian_elimination :: proc(m: [][] bool) {

	n_cols := len(m)
	n_rows := len(m[0])

	pivot_row := 0
	pivot_col := 0

	for ; pivot_row < n_rows && pivot_col < n_cols; {

		// find the next pivot (== first row with a 1 in pivot_col
		pivot := pivot_row
		for ; pivot < n_rows && !m[pivot_col][pivot]; pivot += 1 {}

		if pivot >= n_rows {
			// no pivot in this column, move on to the next column
			pivot_col += 1
		} else {
			swap_row(m, pivot_row, pivot)

			// for all rows below the pivot
			for row := pivot_row + 1; row < n_rows; row += 1 {
				if m[pivot_col][row] {
					for col := pivot_col; col < n_cols; col += 1 {
						m[col][row] ~= m[col][pivot_row]
					}
				}
			}

			// move to next pivot row and column
			pivot_row += 1
			pivot_col += 1
		}
	}
}

matrix_pivots_and_free_vars :: proc(m: [][]bool) -> ([]i32, []i32) {

	pivots := make([]i32, len(m[0]))
	free_vars := make([]bool, len(m) - 1)
	slice.fill(pivots, -1)
	slice.fill(free_vars[:], true);

	for r := 0; r < len(m[0]); r += 1 {
		for c := 0; c < len(m) - 1; c += 1 {
			if m[c][r] {
				pivots[r] = i32(c)
				free_vars[c] = false
				break
			}
		}
	}

	result : [dynamic]i32
	for f, idx in free_vars {
		if f {
			append(&result, i32(idx))
		}
	}

	return pivots, result[:]
}

matrix_solve :: proc(m: [][]bool, pivots, free_var_indices: []i32, free_var_value: i32) -> LightSet {

	button_pressed := make([]bool, len(m) - 1)
	slice.fill(button_pressed, false)

	// set the free variables
	for b : i32 = i32(len(m) - 1); b >= 0; b -= 1 {
		free_idx, is_free := slice.binary_search(free_var_indices, b)
		if is_free {
			button_pressed[b] = free_var_value & (1 << u32(free_idx)) != 0
		}
	}

	// process the rows
	for r := i32(len(m[0]) - 1); r >= 0; r -= 1 {
		if pivots[r] < 0 {
			continue
		}

		b := pivots[r]
		button_pressed[b] = false
		for c := b + 1; c < i32(len(m)); c += 1 {
			if c >= i32(len(button_pressed)) || button_pressed[c] {
				button_pressed[b] ~= m[c][r]
			}
		}
	}

	return button_pressed
}

solve_for_target_lights :: proc(machine : ^MachineData) -> []LightSet {
	solutions : [dynamic]LightSet

	// build matrix
	mat := make([][]bool, len(machine.button_configs) + 1)
	for col := 0; col < len(machine.button_configs); col += 1 {
		mat[col] = slice.clone(machine.button_configs[col])
	}
	mat[len(machine.button_configs)] = machine.target_lights

	// guassian elimination
	gaussian_elimination(mat)

	// find free variables
	pivots, free_vars := matrix_pivots_and_free_vars(mat)

	// iterate all solutions
	max_free_value : i32 = 1 << u32(len(free_vars))

	for free_value: i32 = 0; free_value < max_free_value; free_value += 1 {
		append(&solutions, matrix_solve(mat, pivots, free_vars, free_value))
	}

	return solutions[:]
}

main :: proc() {
    data, _ := os.read_entire_file_from_handle(os.stdin, context.allocator)
    defer delete(data, context.allocator)

	result : i32 = 0

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
        machine := parse_machine_line(line, context.allocator)

		solutions := solve_for_target_lights(&machine)

		min_pressed := i32(5000000)
		for solution in solutions {
			count := i32(slice.count(solution, true))
			min_pressed = math.min(min_pressed, count)
		}

		result += min_pressed
    }

	fmt.println(result)
}
