# Compiladors - Practica 2

Primera practica de compiladors. Desenvolupada sota l'entorn proporcionat per docker. 

**Requeriments**
 -  gcc 
 - flex 
 - bison 
 - make 
 
**Docker**
```sh
$ docker build . -t compiladors
$ docker run -v $(pwd):/prac2 -it compiladors /bin/sh
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
## Exemples

|  Nom  | Descripció |  Comanda  |
| - | - | - |
|  `default`  | Exemple de l'enunciat | `$ ./prac2 ./inputs/default.txt ./outputs/default.txt` |
|  `arithmetic`  | Exemple d'operacions aritmetiques | `$ ./prac2 ./inputs/arithmetic.txt ./outputs/arithmetic.txt` |
|  `commentaries`  | Exemple de comentaris | `$ ./prac2 ./inputs/commentaries.txt ./outputs/commentaries.txt` |
|  `comparators`  | Exemple de comparacions | `$ ./prac2 ./inputs/comparators.txt ./outputs/comparators.txt` |
|  `functions`  | Exemple de funcions | `$ ./prac2 ./inputs/functions.txt ./outputs/functions.txt` |

## Documentació
### Types
**int**
`a := 2`

**float**
`a := 2.0`

**string**
`a := "test"`

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
- `==` Equals
- `!=` Different
#### Int / float comparation 
Returns 1 if true, otherwise 0.

#### String comparation 
`str1 == str2`
If Return value < 0 then it indicates str1 is less than str2.

If Return value > 0 then it indicates str2 is less than str1.

If Return value = 0 then it indicates str1 is equal to str2.

### Functions
- `sqrt()`
- `log()`
