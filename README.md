# Compiladors - Practica 2

Practica de compiladors. Desenvolupada sota l'entorn proporcionat per docker. 
Com a funcionalitat extres s'ha afegit:
- switch instruction
- array list
- continue instruction

**Requeriments**
 -  gcc 
 - flex 
 - bison 
 - make 
 
**Docker**
```sh
$ docker build . -t compiladors
$ docker run -v $(pwd):/prac -it compiladors /bin/sh
```
**Build**
```sh
$ make
```
**Clean**
```sh
$ make clean
```
**Run**
```sh
$ ./prac2 INPUT_FILE OUTPUT_FILE
```
**Run examples**
```sh
$ make test
```
## Examples

All examples are defined in `inputs` folder.

## Documentació
### Calc mode
File must begin with calc mode:
- `calc on`: begins in calculator mode.
- `calc off`: begins in program mode.

### Types
**int**
`a := 2`

**float**
`a := 2.0`

**string**
`a := "test"`

**array**
This is a basic implementation of an array list.
```
a := [1, 2.0, 3, 4.0]
a[0]
a[1]
```

### Operations
- `+` Add
- `-` Substract
- `*` Multiply
- `/` Divide
- `**` Power
- `mod` Module
#### Int / float operations 
Any operation with floats returns the result as a float.

`2 + 4 = 6`

`2.0 + 4.0 = 6.0`

`2 + 4.0 = 6.0`

#### String add operation 
`"test" + 1234 = "test1234"`

`"test" + "-" + "test" = "test-test"`

### Comparators
- `>` Greather than
- `<` Less than
- `>=` Greather than or equals to
- `<=` Less than or equals to
- `=` Equals
- `<>` Different
Is it possible to compare any type.

### Functions
- `sqrt()`
- `log()`
