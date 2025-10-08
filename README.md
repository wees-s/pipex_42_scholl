# pipex

A program that mimics the behavior of shell pipes, redirecting output between commands as part of the 42 School curriculum.

## Table of Contents

- [Description](#description)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [How It Works](#how-it-works)
- [Implementation Details](#implementation-details)
- [Project Structure](#project-structure)
- [Compilation](#compilation)
- [Testing](#testing)
- [Key Concepts](#key-concepts)
- [Author](#author)

## Description

`pipex` recreates the behavior of the shell pipe operator `|` in C. The program takes two commands and executes them in a pipeline, where the output of the first command becomes the input of the second command, just like in the shell.

The project teaches fundamental Unix concepts including **pipes**, **process creation with fork**, **file descriptors**, and **program execution with execve**.

## Features

- ✅ Executes two commands in a pipeline
- ✅ Handles input/output file redirection
- ✅ Supports both absolute and relative command paths
- ✅ Automatic PATH resolution for commands
- ✅ Proper error handling and exit codes
- ✅ Memory-safe implementation with no leaks
- ✅ Mimics exact shell behavior

## Installation

1. Clone the repository:
```bash
git clone git@github.com:wees-s/pipex_42_scholl.git
cd pipex_42_scholl
```

2. Compile the project:
```bash
make
```

This will create the `pipex` executable.

## Usage

### Basic Syntax

```bash
./pipex file1 cmd1 cmd2 file2
```

This is equivalent to the shell command:
```bash
< file1 cmd1 | cmd2 > file2
```

### Examples

**Example 1: Simple pipe**
```bash
./pipex infile "ls -l" "wc -l" outfile
```
Equivalent to:
```bash
< infile ls -l | wc -l > outfile
```

**Example 2: Text processing**
```bash
./pipex input.txt "grep hello" "wc -w" output.txt
```
Equivalent to:
```bash
< input.txt grep hello | wc -w > output.txt
```

**Example 3: Absolute path**
```bash
./pipex infile "/bin/cat" "grep pattern" outfile
```

**Example 4: Complex commands**
```bash
./pipex file1 "cat -e" "grep $" file2
```

## How It Works

### Visual Representation

```
┌─────────┐      ┌──────────┐      ┌──────────┐      ┌─────────┐
│  file1  │ ───> │   cmd1   │ ───> │   PIPE   │ ───> │  cmd2   │ ───> │  file2  │
│ (input) │      │ (child1) │      │ (buffer) │      │(child2) │      │(output) │
└─────────┘      └──────────┘      └──────────┘      └─────────┘      └─────────┘
    FD              FD 0→file1         pipe[0]            FD 0→pipe[0]      FD 1
  (read)            FD 1→pipe[1]       pipe[1]            FD 1→file2      (write)
```

### Execution Flow

1. **Input Validation**: Check if arguments are valid (5 arguments, no empty strings)
2. **Pipe Creation**: Create a pipe with `pipe()` to connect the two commands
3. **First Fork**: Create first child process for `cmd1`
   - Open input file and redirect to stdin (FD 0)
   - Redirect stdout (FD 1) to pipe write end
   - Execute `cmd1`
4. **Second Fork**: Create second child process for `cmd2`
   - Redirect stdin (FD 0) to pipe read end
   - Open/create output file and redirect stdout (FD 1)
   - Execute `cmd2`
5. **Parent Process**: Close pipe ends and wait for both children to finish
6. **Exit**: Return the exit status of the last command

## Implementation Details

### Main Structure

```c
typedef struct s_pipex
{
    int     pipe_fd[2];    // Pipe file descriptors [0]=read, [1]=write
    pid_t   pid1;          // First child process ID
    pid_t   pid2;          // Second child process ID
    int     status1;       // Exit status of first command
    int     status2;       // Exit status of second command
} t_pipex;
```

### Core Functions

| Function | Description | Purpose |
|----------|-------------|---------|
| `input_checker` | Validates input arguments | Ensures 5 args and no empty strings |
| `pid_cmd1` | Handles first command execution | Executes cmd1 with proper redirections |
| `pid_cmd2` | Handles second command execution | Executes cmd2 with proper redirections |
| `exec_cmd` | Executes the command | Handles both absolute and PATH resolution |
| `open_file` | Opens/creates files | Manages file descriptors with proper flags |

### Command Execution Functions

| Function | Description | Usage |
|----------|-------------|-------|
| `cmd_bar` | Executes absolute path commands | When command contains '/' |
| `cmd_not_bar` | Resolves command from PATH | Standard command execution |
| `command_valid` | Finds executable in PATH | Searches all PATH directories |
| `path` | Extracts PATH from environment | Splits PATH variable |

### File Descriptor Operations

**Command 1 (Read from file1, write to pipe):**
```c
new_fd = open(file1, O_RDONLY);  // Open input file
dup2(new_fd, 0);                 // Redirect stdin to file1
dup2(pipe_fd[1], 1);             // Redirect stdout to pipe write
```

**Command 2 (Read from pipe, write to file2):**
```c
dup2(pipe_fd[0], 0);             // Redirect stdin to pipe read
new_fd = open(file2, O_WRONLY | O_CREAT | O_TRUNC, 0644);
dup2(new_fd, 1);                 // Redirect stdout to file2
```

## Project Structure

```
pipex/
├── src/
│   ├── pipex.c              # Main program and process management
│   ├── input_validation.c   # Input checking and error handling
│   ├── commands/
│   │   ├── cmd1.c          # First command execution
│   │   ├── cmd2.c          # Second command execution
│   │   ├── exec_cmd.c      # Command execution logic
│   │   ├── cmd_bar.c       # Absolute path execution
│   │   └── cmd_not_bar.c   # PATH resolution execution
│   ├── utils/
│   │   ├── path.c          # PATH parsing and searching
│   │   ├── command_valid.c # Command validation in PATH
│   │   ├── file_utils.c    # File opening and handling
│   │   └── error_utils.c   # Error printing functions
│   └── parsing/
│       └── bar.c           # Check for slash in command
├── includes/
│   └── pipex.h             # Header with prototypes and structs
├── libft/                  # Custom C library (if used)
├── Makefile                # Compilation rules
└── README.md              # This file
```

## Compilation

The project uses a Makefile with the following targets:

- `make` or `make all`: Compiles the pipex program
- `make clean`: Removes object files
- `make fclean`: Removes object files and executable
- `make re`: Performs fclean followed by all

### Compilation Flags

```
-Wall -Wextra -Werror
```

## Testing

### Basic Tests

```bash
# Test 1: Simple pipe
echo "Hello World" > infile
./pipex infile "cat" "wc -w" outfile
cat outfile  # Should show: 2

# Test 2: grep and wc
echo -e "hello\nworld\nhello" > infile
./pipex infile "grep hello" "wc -l" outfile
cat outfile  # Should show: 2

# Test 3: Multiple arguments
echo "one two three" > infile
./pipex infile "cat -e" "grep $" outfile
cat outfile  # Should show line endings

# Compare with shell
< infile cat | wc -w > shell_out
./pipex infile "cat" "wc -w" pipex_out
diff shell_out pipex_out  # Should be identical
```

### Error Handling Tests

```bash
# Test with non-existent input file
./pipex nofile "cat" "wc" outfile
# Should print error but continue

# Test with invalid command
./pipex infile "invalidcmd" "wc" outfile
# Should print "Command not found"

# Test with wrong number of arguments
./pipex file1 cmd1
# Should return error

# Test with empty arguments
./pipex "" "cat" "wc" outfile
# Should return error

# Test with non-executable file
./pipex infile "/etc/passwd" "cat" outfile
# Should print "Permission denied"
```

### Automated Test Script

```bash
#!/bin/bash

echo "=== PIPEX TESTING ==="

# Create test file
echo "Hello World
Test Line
Another Line
Hello Again" > test_input.txt

# Test 1: Basic functionality
echo "Test 1: Basic cat | wc"
./pipex test_input.txt "cat" "wc -l" test_output.txt
< test_input.txt cat | wc -l > shell_output.txt
if diff -q test_output.txt shell_output.txt > /dev/null; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
fi

# Test 2: grep and wc
echo "Test 2: grep | wc"
./pipex test_input.txt "grep Hello" "wc -w" test_output.txt
< test_input.txt grep Hello | wc -w > shell_output.txt
if diff -q test_output.txt shell_output.txt > /dev/null; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
fi

# Test 3: Error handling
echo "Test 3: Invalid command"
./pipex test_input.txt "invalidcmd123" "cat" test_output.txt 2>&1 | grep -q "not found"
if [ $? -eq 0 ]; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
fi

# Cleanup
rm -f test_input.txt test_output.txt shell_output.txt

echo "=== TESTING COMPLETE ==="
```

## Key Concepts

### Pipes
A **pipe** is a unidirectional data channel that can be used for inter-process communication. It has two ends:
- **Read end** (pipe_fd[0]): Data comes out
- **Write end** (pipe_fd[1]): Data goes in

### Fork
**Fork** creates a new process (child) that is a copy of the current process (parent):
- Returns `0` in the child process
- Returns child's PID in the parent process
- Returns `-1` on error

### File Descriptors
Standard file descriptors:
- **0 (STDIN)**: Standard input
- **1 (STDOUT)**: Standard output
- **2 (STDERR)**: Standard error

### dup2
**dup2(oldfd, newfd)** duplicates a file descriptor:
- Makes `newfd` a copy of `oldfd`
- Used for redirecting stdin/stdout

### execve
**execve(path, argv, envp)** replaces the current process with a new program:
- Never returns on success (process is replaced)
- Returns `-1` on error
- All open file descriptors remain open

### PATH Resolution
When a command doesn't contain '/', the program:
1. Extracts PATH from environment variables
2. Splits PATH by ':'
3. Searches each directory for the executable
4. Checks if file exists (F_OK) and is executable (X_OK)

### Process Management
```c
waitpid(pid, &status, 0);        // Wait for child to finish
WIFEXITED(status);               // Check if exited normally
WEXITSTATUS(status);             // Get exit code
```

## Error Codes

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success |
| 1 | General error |
| 126 | Permission denied (command not executable) |
| 127 | Command not found |

## Common Issues & Solutions

### Issue: "Permission denied"
**Cause**: Command exists but is not executable
**Solution**: Check file permissions with `ls -l` or use `chmod +x`

### Issue: "Command not found"
**Cause**: Command doesn't exist in PATH or absolute path is wrong
**Solution**: Verify command with `which command` or check absolute path

### Issue: Output file not created
**Cause**: First command fails before second runs
**Solution**: Check if input file exists and first command is valid

### Issue: Different output than shell
**Cause**: Exit status or error handling differs
**Solution**: Compare stderr output and exit codes

## Author

**wedos-sa** - Cadet at 42 São Paulo

---

*This project demonstrates fundamental Unix system programming concepts including process creation, inter-process communication, file descriptor manipulation, and program execution.*
