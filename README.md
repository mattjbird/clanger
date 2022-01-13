# clanger
A compiler for a small (but growing!) subset of the C programming language, written in Swift. 

Why, you ask? Good question...

> **Clanger (noun)**. *An absurd or embarrassing blunder*.

## Documentation
https://mattjbird.github.io/clanger/

## Requirements
You'll need Swift. You can get it here: https://swift.org/getting-started/

## Installation
1. Clone the repo:
```
git clone https://github.com/matthewbyrd/clanger.git
```
2. Build:
```
swift build -c release
cp .build/release/clanger clanger
```

## Running
To compile a file, just use `clanger compile`:
```
clanger compile <file-path.c> --out <executable-path>
```
See `clanger --help` for more info and other subcommands:
```
$ swift run clanger --help
OVERVIEW: Clanger is a compiler for a small (but growing!) subset of C

USAGE: clanger <subcommand>

OPTIONS:
  -h, --help              Show help information.

SUBCOMMANDS:
  compile                 Compiles the given C file
  pretty-ast              Generates a pretty AST from the given C file

  See 'clanger help <subcommand>' for detailed help.
```
The `pretty-ast` command is quite neat; it prints out an abstract-syntax-tree of the given C file:
```
$ clanger pretty-ast foo.c
  FUNC INT main:
    params: ()
    body:
      RETURN Int<42>
```

## Testing
There are unit tests for every stage of the compilation, and functional tests which test whole C files. 
You can run them like so:
```
swift test
```
Note: I recommend using [xcpretty](https://github.com/xcpretty/xcpretty) for running the tests. Then you can do:
```
swift test 2>&1 | xcpretty
```

## Stuff that helped:
1. [*Nand2Tetris*](https://www.nand2tetris.org), a fantastic course I did before embarking on this
2. Ghuloum’s [*An Incremental Approach to Compiler Construction*](http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf)
3. Nora Sandler's [*Writing A C Compiler*](https://norasandler.com/2017/11/29/Write-a-Compiler.html) series.
4. The [*C11 Standard language specification*](http://www.open-std.org/jtc1/sc22/wg14/www/docs/n1570.pdf)
5. The [*Intel 64 Dev Manual*](https://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf)
6. https://www.lri.fr/~filliatr/ens/compil/x86-64.pdf
7. https://www.cs.oberlin.edu/~bob/cs331/Notes%20on%20x86-64%20Assembly%20Language.pdf
8. https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf
