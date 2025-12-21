package part_1

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:slice"

BoolArray :: []bool

MachineData :: struct {
    target_lights: BoolArray,
	button_configs: []BoolArray,
    joltage_requirements: []i32,
}

parse_light_diagram :: proc(diagram_str: string) -> BoolArray {
    content := strings.trim_space(strings.trim_prefix(strings.trim_suffix(diagram_str, "]"), "["))

    target_lights := make(BoolArray, len(content))

    for c, idx in content {
		target_lights[idx] = c == '#'
    }

    return target_lights
}

parse_button_schematic :: proc(schematic_str: string, num_buttons: int) -> BoolArray {
    buttons := make(BoolArray, num_buttons)
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

parse_machine_line :: proc(line: string) -> MachineData {
    diagram_end := strings.index(line, "]")
	joltage_start := strings.last_index(line, "{")

    str_diagram := line[:diagram_end+1]
	str_buttons := line[diagram_end+2:joltage_start-1]
	str_joltage := line[joltage_start:]

    target_lights := parse_light_diagram(str_diagram)

    button_parts := strings.split(str_buttons, " ")
	button_configs := make([]BoolArray, len(button_parts))

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

matrix_is_valid :: proc(m: [][]bool) -> bool {

	n_cols := len(m)
	n_vars := n_cols - 1
	n_rows := len(m[0])

	for r := 0; r < n_rows; r += 1 {
		has_vars := false
		for c := 0; c < n_vars && !has_vars; c += 1 {
			has_vars = m[c][r]
		}

		if !has_vars && m[n_vars][r] {
			return false
		}
	}

	return true
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

matrix_solve :: proc(m: [][]bool, pivots, free_var_indices: []i32, free_var_value: i32) -> BoolArray {

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

solve_parity :: proc(machine : ^MachineData, target_lights: BoolArray) -> []BoolArray {
	solutions : [dynamic]BoolArray

	// build matrix
	mat := make([][]bool, len(machine.button_configs) + 1)
	for col := 0; col < len(machine.button_configs); col += 1 {
		mat[col] = slice.clone(machine.button_configs[col])
	}
	mat[len(machine.button_configs)] = target_lights

	// guassian elimination
	gaussian_elimination(mat)

	if !matrix_is_valid(mat) {
		return []BoolArray{}
	}

	// find free variables
	pivots, free_vars := matrix_pivots_and_free_vars(mat)

	// iterate all solutions
	max_free_value : i32 = 1 << u32(len(free_vars))

	for free_value: i32 = 0; free_value < max_free_value; free_value += 1 {
		solution := matrix_solve(mat, pivots, free_vars, free_value)
		append(&solutions, solution)
	}

	return solutions[:]
}

solve_magnitude :: proc(machine: ^MachineData, target_vector: []i32) -> (i32, bool, bool) {

	// determine parity of the target_vector
	parity := make(BoolArray, len(target_vector))
	slice.fill(parity, false)

	non_zero_count := 0
	bad_value_count := 0

	for value, idx in target_vector {
		non_zero_count += (value != 0) ? 1 : 0;
		bad_value_count += (value < 0) ? 1 : 0;
		parity[idx] = value & 1 == 1
	}

	// it does not take many button presses to reach zero joltage
	if non_zero_count == 0 {
		return 0, true, true
	}

	if bad_value_count > 0 {
		return 0, false, false
	}

	min_cost : i32 = -1
	total_finished : bool = false

	parity_solutions := solve_parity(machine, parity)
	if len(parity_solutions) == 0 {
		return 0, false, false
	}

	for solution in parity_solutions {
		cost := i32(slice.count(solution, true))

		next_target := slice.clone(target_vector)
		for b, b_idx in solution {
			if !b { continue }

			for l := 0; l < len(target_vector); l += 1 {
				if machine.button_configs[b_idx][l] {
					next_target[l] -= 1
				}
			}
		}
		for i := 0; i < len(next_target); i += 1 {
			assert(next_target[i] % 2 == 0, "Non even target!")
			next_target[i] /= 2
		}

		recursive_cost, valid, finished := solve_magnitude(machine, next_target)
		if valid {
			cost += recursive_cost * 2
			total_finished |= finished

			if min_cost < 0 || cost < min_cost {
				min_cost = cost
			}
		}
	}

	return min_cost, min_cost > 0, total_finished
}

main :: proc() {
    data, _ := os.read_entire_file_from_handle(os.stdin, context.allocator)
    defer delete(data, context.allocator)

	result : i32 = 0

    it := string(data)
    for line in strings.split_lines_iterator(&it) {
		machine := parse_machine_line(line)
		count, valid, finished := solve_magnitude(&machine, machine.joltage_requirements)
		assert(valid, "Return invalid solution")
		assert(finished, "Puzzle is not finished")
		result += count
    }

	fmt.println(result)
}
