# TAC Compiler and Optimizer

A simple compiler project that accepts a C-style arithmetic assignment statement, generates Three Address Code (TAC), and applies several optimization techniques.

## Features

- C-style variable names
- Integer constants
- Floating-point constants
- Arithmetic operators: `+`, `-`, `*`, `/`
- Parentheses
- Operator precedence
- Optional semicolon
- Three Address Code generation
- Constant folding
- Algebraic optimization
- Common subexpression elimination
- Copy propagation
- Temporary variable elimination
- Simple web frontend

## Technologies

- C
- Flex
- Bison
- GCC
- PHP
- HTML
- CSS
- JavaScript
- WSL / Ubuntu

## Project Structure

```text
TAC-Compiler-Optimizer/
│
├── compiler/
│   ├── lexer.l
│   └── parser.y
│
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── compile.php
│
└── README.md
```

## Requirements

Ubuntu / WSL with:

- GCC
- Flex
- Bison
- libc6-dev
- PHP CLI

Install everything with:

```bash
sudo apt update
sudo apt install gcc flex bison libc6-dev php-cli
```

## Running the Compiler

Open Ubuntu and enter the compiler directory:

```bash
cd ~/TAC-Compiler-Optimizer/compiler
```

Generate the parser:

```bash
bison -d parser.y
```

Generate the lexer:

```bash
flex lexer.l
```

Compile:

```bash
gcc lex.yy.c parser.tab.c -o parser
```

Make the parser executable:

```bash
chmod +x parser
```

Copy the parser to the frontend:

```bash
cp parser ../frontend/
```

## Running the Web Frontend

Enter the frontend directory:

```bash
cd ../frontend
```

Start the PHP development server:

```bash
php -S 0.0.0.0:8000
```

Open a browser and visit:

```
http://localhost:8000
```

## Example Inputs

```
x = a + b * c - d / e;
```

```
x = 5 + 3 * 2;
```

```
x = a * 1 + b * 0;
```

```
x = (a + b) * (a + b);
```

```
x = 5.5 + 2.5 * 2;
```

The compiler accepts one assignment statement at a time. The semicolon at the end is optional.

## Initializing Git

From the project root:

```bash
cd ~/TAC-Compiler-Optimizer
git init
git status
```

You should see your five source files and README as untracked.
