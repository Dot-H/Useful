# ShellCheck Compliance Skill

This skill applies **every time you write or suggest shell code** -- whether in a `.sh` file, a Bash tool call, a code block in a PR/comment, or inline shell in a Dockerfile, Makefile, CI config, etc.

## Instructions

All shell code you produce MUST comply with the ShellCheck static analysis rules listed below. Before outputting any shell code, mentally lint it against these rules and fix violations proactively. Do not wait for the user to point them out.

### Key Rules to Internalize

These are the most frequently violated rules. Pay special attention:

1. **SC2086** - Double quote to prevent globbing and word splitting. Always quote `"$variable"` expansions.
2. **SC2046** - Quote command substitutions: `"$(cmd)"` not `$(cmd)`.
3. **SC2006** - Use `$(...)` notation instead of legacy backticks.
4. **SC2155** - Declare and assign separately: `local var; var=$(cmd)` not `local var=$(cmd)`.
5. **SC2064** - Use single quotes for trap: `trap 'cleanup' EXIT` not `trap "cleanup" EXIT`.
6. **SC2034** - Don't leave variables unused without reason.
7. **SC2162** - Use `read -r` to prevent backslash mangling.
8. **SC2164** - Use `cd ... || exit` in case cd fails.
9. **SC2230** - Use `command -v` instead of `which`.
10. **SC2181** - Check exit code directly with `if mycmd;` not indirectly with `$?`.
11. **SC2002** - Avoid useless `cat`. Use redirection or pass file as argument.
12. **SC2005** - Avoid useless `echo`. Instead of `echo $(cmd)`, just use `cmd`.
13. **SC2015** - `A && B || C` is not if-then-else. C may run when A is true.
14. **SC2059** - Don't use variables in printf format string. Use `printf "%s" "$foo"`.
15. **SC2068** - Double quote array expansions: `"${array[@]}"`.
16. **SC2048** - Use `"$@"` (with quotes) to prevent whitespace problems.
17. **SC2112** - `function` keyword is non-standard. Use `fname() { ... }` instead.
18. **SC2003** - `expr` is antiquated. Use `$((...))` for arithmetic.
19. **SC2009** - Consider using `pgrep` instead of grepping ps output.
20. **SC2010** - Don't use `ls | grep`. Use a glob or a for loop.
21. **SC2115** - Use `"${var:?}"` to ensure rm never expands to `/*`.
22. **SC2196/SC2197** - `egrep`/`fgrep` are deprecated. Use `grep -E`/`grep -F`.

### Complete ShellCheck Rules Reference

#### Syntax and Parsing (SC1000-SC1136)

- **SC1000**: `$` is not used specially and should therefore be escaped.
- **SC1001**: This `\o` will be a regular 'o' in this context.
- **SC1003**: Want to escape a single quote? `echo 'This is how it'\''s done'`.
- **SC1004**: This backslash+linefeed is literal. Break outside single quotes if you just want to break the line.
- **SC1007**: Remove space after `=` if trying to assign a value (or for empty string, use `var=''`).
- **SC1008**: This shebang was unrecognized. ShellCheck only supports sh/bash/dash/ksh.
- **SC1009**: The mentioned parser error was in this area.
- **SC1010**: Use semicolon or linefeed before `done` (or quote to make it literal).
- **SC1011**: This apostrophe terminated the single quoted string!
- **SC1012**: `\t` is just literal `t` here. For tab, use `"$(printf '\t')"` instead.
- **SC1014**: Use `if cmd; then ..` to check exit code, or `if [ "$(cmd)" = .. ]` to check output.
- **SC1015**: This is a unicode double quote. Delete and retype it.
- **SC1016**: This is a Unicode single quote. Delete and retype it.
- **SC1017**: Literal carriage return. Run script through `tr -d '\r'`.
- **SC1018**: This is a unicode non-breaking space. Delete it and retype as space.
- **SC1019**: Expected this to be an argument to the unary condition.
- **SC1020**: You need a space before the `]` or `]]`.
- **SC1026**: If grouping expressions inside `[[..]]`, use `( .. )`.
- **SC1028**: In `[..]` you have to escape `\(` `\)` or preferably combine `[..]` expressions.
- **SC1029**: In `[[..]]` you shouldn't escape `(` or `)`.
- **SC1035**: You need a space here.
- **SC1036**: `(` is invalid here. Did you forget to escape it?
- **SC1037**: Braces are required for positionals over 9, e.g. `${10}`.
- **SC1038**: Shells are space sensitive. Use `< <(cmd)`, not `<<(cmd)`.
- **SC1039**: Remove indentation before end token (or use `<<-` and indent with tabs).
- **SC1040**: When using `<<-`, you can only indent with tabs.
- **SC1041**: Found end token further down, but not on a separate line.
- **SC1044**: Couldn't find end token in the here document.
- **SC1045**: It's not `foo &; bar`, just `foo & bar`.
- **SC1046**: Couldn't find `fi` for this `if`.
- **SC1048**: Can't have empty then clauses (use `true` as a no-op).
- **SC1049**: Did you forget the `then` for this `if`?
- **SC1051**: Semicolons directly after `then` are not allowed. Just remove it.
- **SC1054**: You need a space after the `{`.
- **SC1058**: Expected `do`.
- **SC1061**: Couldn't find `done` for this `do`.
- **SC1064**: Expected a `{` to open the function definition.
- **SC1065**: Trying to declare parameters? Don't. Use `()` and refer to params as `$1`, `$2`..
- **SC1066**: Don't use `$` on the left side of assignments.
- **SC1068**: Don't put spaces around the `=` in assignments.
- **SC1069**: You need a space before the `[`.
- **SC1071**: ShellCheck only supports sh/bash/dash/ksh scripts.
- **SC1073**: Couldn't parse this. Fix to allow more checks.
- **SC1075**: Use `elif` instead of `else if`.
- **SC1077**: For command expansion, the tick should slant left.
- **SC1078**: Did you forget to close this double quoted string?
- **SC1081**: Scripts are case sensitive. Use `if`, not `If`.
- **SC1082**: This file has a UTF-8 BOM. Remove it.
- **SC1083**: This `{`/`}` is literal. Check expression or quote it.
- **SC1084**: Use `#!`, not `!#`, for the shebang.
- **SC1086**: Don't use `$` on the iterator name in for loops.
- **SC1087**: Use braces when expanding arrays, e.g. `${array[idx]}`.
- **SC1090**: Can't follow non-constant source. Use a directive to specify location.
- **SC1091**: Not following sourced file.
- **SC1095**: You need a space or linefeed between the function name and body.
- **SC1097**: Unexpected `==`. For assignment, use `=`. For comparison, use `[`/`[[`.
- **SC1098**: Quote/escape special characters when using eval.
- **SC1099**: You need a space before the `#`.
- **SC1100**: This is a unicode dash. Delete and retype as ASCII minus.
- **SC1101**: Delete trailing spaces after `\` to break line.
- **SC1102**: Shells disambiguate `$((` differently. Add space after `$(` for command substitution.
- **SC1105**: If the first `(` should start a subshell, add a space after it.
- **SC1107**: This directive is unknown. It will be ignored.
- **SC1108**: You need a space before and after the `=`.
- **SC1109**: This is an unquoted HTML entity. Replace with corresponding character.
- **SC1110-SC1112**: Unicode quotes. Delete and retype them.
- **SC1113-SC1115**: Shebang formatting issues.
- **SC1116**: Missing `$` on a `$((..))` expression?
- **SC1117**: Backslash is literal in `"\n"`. Prefer explicit escaping: `"\\n"`.
- **SC1118**: Delete whitespace after the here-doc end token.
- **SC1119**: Add a linefeed between end token and terminating `)`.
- **SC1120**: No comments allowed after here-doc token.
- **SC1123-SC1126**: ShellCheck directive placement rules.
- **SC1127**: Was this intended as a comment? Use `#` in sh.
- **SC1128**: The shebang must be on the first line.
- **SC1129**: You need a space before the `!`.
- **SC1130**: You need a space before the `:`.
- **SC1131**: Use `elif` to start another branch.
- **SC1132**: This `&` terminates the command. Escape it or add space.
- **SC1133**: Unexpected start of line. `|`/`||`/`&&` should be at the end of the previous line.
- **SC1135**: Prefer escape over ending quote to make `$` literal.
- **SC1136**: Unexpected characters after terminating `]`. Missing semicolon/linefeed?

#### Style, Modernization and Best Practices (SC2000-SC2263)

- **SC2000**: See if you can use `${#variable}` instead.
- **SC2001**: See if you can use `${variable//search/replace}` instead.
- **SC2002**: Useless cat. Consider `cmd < file | ..` or `cmd file | ..` instead.
- **SC2003**: `expr` is antiquated. Consider rewriting this using `$((..))`/`${}`/`[[ ]]`.
- **SC2004**: `$`/`${}` is unnecessary on arithmetic variables.
- **SC2005**: Useless `echo`? Instead of `echo $(cmd)`, just use `cmd`.
- **SC2006**: Use `$(...)` notation instead of legacy backticks.
- **SC2007**: Use `$((..))`instead of deprecated `$[..]`.
- **SC2008**: `echo` doesn't read from stdin, are you sure you should be piping to it?
- **SC2009**: Consider using `pgrep` instead of grepping ps output.
- **SC2010**: Don't use `ls | grep`. Use a glob or a for loop with a condition.
- **SC2011**: Use `find -print0` or `find -exec` to better handle non-alphanumeric filenames.
- **SC2012**: Use `find` instead of `ls` to better handle non-alphanumeric filenames.
- **SC2013**: To read lines rather than words, pipe/redirect to a `while read` loop.
- **SC2014**: This will expand once before find runs, not per file found.
- **SC2015**: Note that `A && B || C` is not if-then-else. C may run when A is true.
- **SC2016**: Expressions don't expand in single quotes, use double quotes for that.
- **SC2017**: Increase precision by replacing `a/b*c` with `a*c/b`.
- **SC2018**: Use `[:lower:]` to support accents and foreign alphabets.
- **SC2019**: Use `[:upper:]` to support accents and foreign alphabets.
- **SC2020**: `tr` replaces sets of chars, not words.
- **SC2021**: Don't use `[]` around ranges in `tr`, it replaces literal square brackets.
- **SC2022**: Note that unlike globs, `o*` here matches `ooo` but not `oscar`.
- **SC2024**: `sudo` doesn't affect redirects. Use `.. | sudo tee file`.
- **SC2025**: Make sure all escape sequences are enclosed in `\[..\]` to prevent line wrapping issues.
- **SC2026**: This word is outside of quotes. Did you intend to nest single quotes?
- **SC2027**: The surrounding quotes actually unquote this. Remove or escape them.
- **SC2028**: `echo` won't expand escape sequences. Consider `printf`.
- **SC2029**: Note that, unescaped, this expands on the client side.
- **SC2030**: Modification of var is local (to subshell caused by pipeline).
- **SC2031**: var was modified in a subshell. That change might be lost.
- **SC2032**: Use own script or `sh -c '..'` to run this from su.
- **SC2033**: Shell functions can't be passed to external commands.
- **SC2034**: Variable appears unused. Verify it or export it.
- **SC2035**: Use `./*glob*` or `-- *glob*` so names with dashes won't become options.
- **SC2036**: If you wanted to assign the output of the pipeline, use `a=$(b | c)`.
- **SC2037**: To assign the output of a command, use `var=$(cmd)`.
- **SC2038**: Use `-print0`/`-0` or `find -exec +` to allow for non-alphanumeric filenames.
- **SC2039**: In POSIX sh, some features are undefined.
- **SC2040**: `!/bin/sh` was specified, so certain features are not supported.
- **SC2041**: This is a literal string. To run as a command, use `$(..)` instead of `'..'`.
- **SC2043**: This loop will only ever run once for a constant value.
- **SC2044**: For loops over find output are fragile. Use `find -exec` or a while read loop.
- **SC2045**: Iterating over ls output is fragile. Use globs.
- **SC2046**: Quote this to prevent word splitting.
- **SC2048**: Use `"$@"` (with quotes) to prevent whitespace problems.
- **SC2049**: `=~` is for regex, but this looks like a glob. Use `=` instead.
- **SC2050**: This expression is constant. Did you forget the `$` on a variable?
- **SC2051**: Bash doesn't support variables in brace range expansions.
- **SC2053**: Quote the rhs of `=` in `[[ ]]` to prevent glob matching.
- **SC2054**: Use spaces, not commas, to separate array elements.
- **SC2055**: You probably wanted `&&` here, otherwise it's always true.
- **SC2057**: Unknown binary operator.
- **SC2059**: Don't use variables in the printf format string. Use `printf "..%s.." "$foo"`.
- **SC2060**: Quote parameters to `tr` to prevent glob expansion.
- **SC2061**: Quote the parameter to `-name` so the shell won't interpret it.
- **SC2062**: Quote the grep pattern so the shell won't interpret it.
- **SC2063**: Grep uses regex, but this looks like a glob.
- **SC2064**: Use single quotes, otherwise this expands now rather than when signalled.
- **SC2065**: This is interpreted as a shell file redirection, not a comparison.
- **SC2066**: Since you double quoted this, it will not word split, and the loop will only run once.
- **SC2067**: Missing `;` or `+` terminating `-exec`.
- **SC2068**: Double quote array expansions to avoid re-splitting elements.
- **SC2069**: To redirect stdout+stderr, `2>&1` must be last.
- **SC2070**: `-n` doesn't work with unquoted arguments.
- **SC2071**: `>` is for string comparisons. Use `-gt` instead.
- **SC2072**: Decimals are not supported. Use integers only, or use `bc`/`awk`.
- **SC2074**: Can't use `=~` in `[ ]`. Use `[[..]]` instead.
- **SC2076**: Don't quote rhs of `=~`, it'll match literally rather than as a regex.
- **SC2077**: You need spaces around the comparison operator.
- **SC2078**: This expression is constant. Did you forget a `$` somewhere?
- **SC2079**: `(( ))` doesn't support decimals. Use `bc` or `awk`.
- **SC2080**: Numbers with leading 0 are considered octal.
- **SC2081**: `[ .. ]` can't match globs. Use `[[ .. ]]` or `grep`.
- **SC2084**: Remove `$` or use `_=$((expr))` to avoid executing output.
- **SC2086**: Double quote to prevent globbing and word splitting.
- **SC2087**: Quote `EOF` to make here document expansions happen on the server side.
- **SC2088**: Tilde does not expand in quotes. Use `$HOME`.
- **SC2089**: Quotes/backslashes will be treated literally. Use an array.
- **SC2090**: Quotes/backslashes in this variable will not be respected.
- **SC2091**: Remove surrounding `$()` to avoid executing output.
- **SC2093**: Remove `exec` if script should continue after this command.
- **SC2094**: Make sure not to read and write the same file in the same pipeline.
- **SC2095**: Use `ssh -n` to prevent ssh from swallowing stdin.
- **SC2096**: On most OS, shebangs can only specify a single parameter.
- **SC2097**: This assignment is only seen by the forked process.
- **SC2098**: This expansion will not see the mentioned assignment.
- **SC2099-SC2100**: Use `$((..))`for arithmetics, e.g. `i=$((i + 2))`.
- **SC2101**: Named class needs outer `[]`, e.g. `[[:digit:]]`.
- **SC2103**: Use a `( subshell )` to avoid having to cd back.
- **SC2104**: In functions, use `return` instead of `break`.
- **SC2105**: `break` is only valid in loops.
- **SC2106**: This only exits the subshell caused by the pipeline.
- **SC2107**: Instead of `[ a && b ]`, use `[ a ] && [ b ]`.
- **SC2108**: In `[[..]]`, use `&&` instead of `-a`.
- **SC2109**: Instead of `[ a || b ]`, use `[ a ] || [ b ]`.
- **SC2110**: In `[[..]]`, use `||` instead of `-o`.
- **SC2112**: `function` keyword is non-standard. Delete it.
- **SC2114**: Warning: deletes a system directory.
- **SC2115**: Use `"${var:?}"` to ensure this never expands to `/*`.
- **SC2116**: Useless echo? Instead of `cmd $(echo foo)`, just use `cmd foo`.
- **SC2117**: To run commands as another user, use `su -c` or `sudo`.
- **SC2119**: Use `foo "$@"` if function's `$1` should mean script's `$1`.
- **SC2120**: Function references arguments, but none are ever passed.
- **SC2121**: To assign a variable, use just `var=value`, no `set ..`.
- **SC2122**: `>=` is not a valid operator. Use `! a < b` instead.
- **SC2123**: `PATH` is the shell search path. Use another name.
- **SC2124**: Assigning an array to a string! Assign as array, or use `*` instead of `@`.
- **SC2125**: Brace expansions and globs are literal in assignments. Quote or use an array.
- **SC2126**: Consider using `grep -c` instead of `grep | wc`.
- **SC2128**: Expanding an array without an index only gives the first element.
- **SC2129**: Consider using `{ cmd1; cmd2; } >> file` instead of individual redirects.
- **SC2130**: `-eq` is for integer comparisons. Use `=` instead.
- **SC2139**: This expands when defined, not when used. Consider escaping.
- **SC2140**: Word is on the form `"A"B"C"`. Did you mean `"ABC"` or `"A\"B\"C"`?
- **SC2141**: Did you mean `IFS=$'\t'`?
- **SC2142**: Aliases can't use positional parameters. Use a function.
- **SC2143**: Use `grep -q` instead of comparing output with `[ -n .. ]`.
- **SC2144**: `-e` doesn't work with globs. Use a for loop.
- **SC2145**: Argument mixes string and array. Use `*` or separate argument.
- **SC2146**: This action ignores everything before the `-o`. Use `\( \)` to group.
- **SC2147**: Literal tilde in PATH works poorly across programs.
- **SC2148**: Add a shebang line to the top of your script.
- **SC2149**: Remove `$`/`${}` for numeric index, or escape it for string.
- **SC2150**: `-exec` does not automatically invoke a shell. Use `-exec sh -c ..` for that.
- **SC2151-SC2152**: Only one integer 0-255 can be returned. Use stdout for other data.
- **SC2153**: Possible misspelling: check variable name casing.
- **SC2154**: Variable is referenced but not assigned.
- **SC2155**: Declare and assign separately to avoid masking return values.
- **SC2156**: Injecting filenames is fragile and insecure. Use parameters.
- **SC2157**: Argument to implicit `-n` is always true due to literal strings.
- **SC2158**: `[ false ]` is true. Remove the brackets.
- **SC2159**: `[ 0 ]` is true. Use `false` instead.
- **SC2160**: Instead of `[ true ]`, just use `true`.
- **SC2161**: Instead of `[ 1 ]`, use `true`.
- **SC2162**: `read` without `-r` will mangle backslashes.
- **SC2163**: This does not export the variable. Remove `$`/`${}` for that.
- **SC2164**: Use `cd ... || exit` in case cd fails.
- **SC2165-SC2167**: Nested loop overrides the index variable of its parent.
- **SC2168**: `local` is only valid in functions.
- **SC2169**: In dash, some features are not supported.
- **SC2170**: Numerical `-eq` does not dereference in `[..]`.
- **SC2171**: Found trailing `]` outside test.
- **SC2172**: Trapping signals by number is not well defined. Prefer signal names.
- **SC2173**: SIGKILL/SIGSTOP can not be trapped.
- **SC2174**: When used with `-p`, `-m` only applies to the deepest directory.
- **SC2176-SC2177**: `time` is undefined for pipelines/compound commands.
- **SC2178**: Variable was used as an array but is now assigned a string.
- **SC2179**: Use `array+=("item")` to append items to an array.
- **SC2180**: Bash does not support multidimensional arrays.
- **SC2181**: Check exit code directly with e.g. `if mycmd;`, not indirectly with `$?`.
- **SC2182-SC2183**: Printf format string variable count mismatches.
- **SC2184**: Quote arguments to `unset` so they're not glob expanded.
- **SC2185**: Some finds don't have a default path. Specify `.` explicitly.
- **SC2186**: `tempfile` is deprecated. Use `mktemp` instead.
- **SC2188**: This redirection doesn't have a command. Move to its command or use `true` as no-op.
- **SC2189**: You can't have `|` between this redirection and the command.
- **SC2190**: Elements in associative arrays need index, e.g. `array=( [index]=value )`.
- **SC2191**: The `=` here is literal. To assign by index, use `( [index]=value )` with no spaces.
- **SC2192**: This array element has no value. Remove spaces after `=` or use `""`.
- **SC2193**: The arguments to this comparison can never be equal.
- **SC2194**: This word is constant. Did you forget the `$` on a variable?
- **SC2195**: This pattern will never match the case statement's word.
- **SC2196**: `egrep` is non-standard and deprecated. Use `grep -E` instead.
- **SC2197**: `fgrep` is non-standard and deprecated. Use `grep -F` instead.
- **SC2198-SC2199**: Arrays don't work as operands in `[ ]`/`[[ ]]`. Use a loop.
- **SC2200-SC2203**: Brace expansions and globs don't work in test expressions. Use a loop.
- **SC2204-SC2205**: `(..)` is a subshell. Did you mean `[ .. ]`?
- **SC2206-SC2207**: Quote to prevent word splitting/globbing, or split robustly with `mapfile` or `read -a`.
- **SC2208**: Use `[[ ]]` or quote arguments to `-v` to avoid glob expansion.
- **SC2209**: Use `var=$(command)` to assign output (or quote to assign string).
- **SC2210**: This is a file redirection. Was it supposed to be a comparison?
- **SC2211**: This is a glob used as a command name.
- **SC2212**: Use `false` instead of empty `[`/`[[` conditionals.
- **SC2213-SC2214**: `getopts` case handling mismatches.
- **SC2215**: This flag is used as a command name. Bad line break or missing `[ .. ]`?
- **SC2216**: Piping to `rm`, a command that doesn't read stdin. Wrong command or missing `xargs`?
- **SC2217**: Redirecting to `echo`, a command that doesn't read stdin.
- **SC2218**: This function is only defined later. Move the definition up.
- **SC2219**: Instead of `let expr`, prefer `(( expr ))`.
- **SC2220**: Invalid flags are not handled. Add a `*)` case.
- **SC2221-SC2222**: Case pattern ordering issues (one overrides/shadows another).
- **SC2223**: This default assignment may cause DoS due to globbing. Quote it.
- **SC2224-SC2226**: `mv`/`cp`/`ln` has no destination. Check the arguments.
- **SC2227**: Redirection applies to the find command itself. Rewrite to work per action.
- **SC2229**: This does not read the variable. Remove `$`/`${}` for that.
- **SC2230**: `which` is non-standard. Use builtin `command -v` instead.
- **SC2231**: Quote expansions in this for loop glob to prevent wordsplitting.
- **SC2232**: Can't use `sudo` with builtins like `cd`. Did you want `sudo sh -c ..` instead?
- **SC2233-SC2234**: Remove superfluous `(..)` around condition/test command.
- **SC2235**: Use `{ ..; }` instead of `(..)` to avoid subshell overhead.
- **SC2236**: Use `-n` instead of `! -z`.
- **SC2237**: Use `[ -n .. ]` instead of `! [ -z .. ]`.
- **SC2238**: Redirecting to/from command name instead of file.
- **SC2239**: Ensure the shebang uses the absolute path to the interpreter.
- **SC2240**: The dot command does not support arguments in sh/dash.
- **SC2241-SC2242**: Can only exit with status 0-255. Other data should be written to stdout/stderr.
- **SC2243-SC2244**: Prefer explicit `-n` to check for output/non-empty string.
- **SC2245**: `-d` only applies to the first expansion of this glob. Use a loop.
- **SC2246**: This shebang specifies a directory. Ensure the interpreter is a file.
- **SC2247**: Flip leading `$` and `"` if this should be a quoted substitution.
- **SC2248**: Warn about variable references without braces.
- **SC2249**: Consider adding a default `*)` case, even if it just exits with error.
- **SC2250**: Prefer putting braces around variable references even when not strictly required.
- **SC2251**: This `!` is not on a condition and skips errexit.
- **SC2252**: You probably wanted `&&` here, otherwise it's always true.
- **SC2253**: Use `-R` to recurse, or explicitly `a-r` to remove read permissions.
- **SC2254**: Quote expansions in case patterns to match literally rather than as a glob.
- **SC2255**: `[ ]` does not apply arithmetic evaluation. Evaluate with `$((..))`for numbers.
- **SC2256**: Flip leading `$` and `"` for quoted substitution.
- **SC2257**: Arithmetic modifications in command redirections may be discarded.
- **SC2259**: This redirection overrides piped input.
- **SC2260**: This redirection overrides the output pipe. Use `tee` to output to both.
- **SC2261**: Multiple redirections compete for stdout. Use `cat`, `tee`, or pass filenames.
- **SC2262-SC2263**: Aliases can't be defined and used in the same parsing unit. Use a function instead.

### Quick Checklist (apply before every shell output)

- [ ] All variable expansions are double-quoted (`"$var"`, `"${var}"`, `"$(cmd)"`, `"$@"`)
- [ ] Using `$(...)` not backticks
- [ ] Using `$((...))` for arithmetic, not `expr` or `$[..]`
- [ ] `read -r` used (not bare `read`)
- [ ] `cd dir || exit` (not bare `cd dir`)
- [ ] `command -v` instead of `which`
- [ ] No useless `cat`, `echo`, or `grep | wc`
- [ ] `printf "%s"` for variable output, not `printf "$var"`
- [ ] `grep -E`/`grep -F` instead of `egrep`/`fgrep`
- [ ] `trap '...' SIGNAL` with single quotes
- [ ] Arrays properly quoted: `"${arr[@]}"`
- [ ] `declare`/`local` and assignment on separate lines
- [ ] Script files have a proper shebang (`#!/usr/bin/env bash` or `#!/bin/bash`)

Source: https://gist.github.com/nicerobot/53cee11ee0abbdc997661e65b348f375
