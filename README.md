# Advent Of Code 2025

After a small hiatus, I'm back at solving the annual [Advent of Code](https://adventofcode.com/2025). I dropped off because the full 25 day competition was too big of a workload, but this years 12 part series seemed more manageable.

This year I decided to write my solutions in Odin without, as always, relying on external libraries. It's the first time I've written anything in Odin, so some of the code is probably not "the way to do it in Odin (tm)". Especially the memory management is atrocious; as these are short lived programs I just allocate and assume there's enough memory to go around.

Disclaimer: As an experiment to evaluate the current state of AI, I did use an agent to provide hints along the way. I did not use it write any code, just to provide hints when I was stuck.

Reflecting on how things went this year, I flew through the first week without breaking a sweat. Progress ground to a halt on day 8, however. I misinterpreted the problem and of course did not get the correct result at all. I asked the AI agent to look at the problem description and my code, and to provide hints about what I was doing wrong. To my surprise, after a minute or two, it came back, congratulated me on the effort I had put in, and gently prodded me towards discovering my logic error.

By day 9 I fully remembered why I stopped doing AoC, and I just wanted to finish as quickly as possible, brute-forcing a solution whenever possible. However day 9 was not the day to try brute-forcing it, and after a polite chastising by the AI-agent I followed its suggestion of using coordinate compression for part 2. Day 10 found me frantically trying to remember how to solve Guassian elimination to solve a system of linear equations. Day 11 provided a much needed breather, just a DFS and some memoization, no biggy. 

And I won't talk about day 12. Well not much anyway, just enough to say that after a day of thinking about backtracking I turned to a spreadsheet to run some numbers on the real input data and found the correct solution right then and there. I implemented a short solution in Odin because I can't submit the spreadsheet. I'm just glad I figured it out before implementing the backtracking.

Anyway, I mostly had fun and, for once, completed a AoC before Christmas, ha!
