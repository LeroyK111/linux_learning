# shell中的变量

变量的名称是对它所持有的数据的占位符（代名词）。引用（检索）其值称为变量替换。获取变量值使用美元符号：
```sh
$
```
让我们仔细区分变量的 名称 及 变量值。如果 variable1 是 变量，则 $variable 是对其值的引用， 它包含的数据项。

从技术上讲，变量的名称称为左值，这意味着它出现 在作业的左侧 语句，如 VARIABLE=23 所示。变量的值为 右值，这意味着 它出现在赋值语句的右侧，如 VAR2=$VARIABLE。事实上，变量的名称是引用，是指向内存的指针，即该变量的值被保留在变量指向的内存位置起始的内存字节空间中。

用一段shell命令演示变量的定义、赋值、读取（bash$ 后面的是具体执行的shell命令）：

```sh
bash$ variable1=23


bash$ echo variable1
variable1

bash$ echo $variable1
23
```

以“裸露”方式使用变量（没有 $ 前缀）的唯一时间是 声明或分配、未设置时、导出（export）时、 在双括号内的算术表达式中 (( variable1 ))，或者在变量的特殊情况下 表示信号时

```sh
#!/bin/bash
# Hunting variables with a trap.

trap 'echo Variable Listing --- a = $a  b = $b' EXIT
#  EXIT is the name of the signal generated upon exit from a script.
#
#  The command specified by the "trap" doesn't execute until
#+ the appropriate signal is sent.

echo "This prints before the \"trap\" --"
echo "even though the script sees the \"trap\" first."
echo

a=39

b=36

exit 0
#  Note that commenting out the 'exit' command makes no difference,
#+ since the script exits in any case after running out of commands.
```

## shell中如何给变量赋值？
赋值可以带有 =（如 var1=27）， 在 READ 语句中，
```sh
#!/bin/bash

# 读取用户输入
echo "请输入你的名字："
read name

# 输出用户输入的内容
echo "你输入的名字是：$name"
```
或在循环的头部（for var2 in 1 2 3方式循环给变量var2赋值并打印值）
```sh
bash$ for var2 in 1 2 3;do echo $var2;done
1
2
3

```
将引用的值括在英文的双引号中 （"...") 不会干扰变量操作。这是被称为部分引用 或称为“弱引用”。

使用英文的单引号 （'...') 导致按字面意思使用变量名，而不是将其替换为实际值。如

```sh
var1=123
echo '$var1'
# 输出结果为 $var1， 也就是原原本本，未做变量替换。

echo "$var1"
# 输出结果为123， 也就是双引号有会按变量替换。
```
单引号内的变量效果是全引用，有时称为“强”引用。`

## shell的变量和赋值的综合例子
```sh
#!/bin/bash

# ex9.sh

# 变量：赋值和替换

a=375
hello=$a

# ---------------------------------------
# 赋值时，等号两边不能有空格，否则初始化变量时会出错。
# 如果有空格会怎样？

# "VARIABLE =value"
# ^
#% 脚本尝试运行"VARIABLE"命令，参数为"="value"。

# "VARIABLE= value"
# ^
#% 脚本尝试运行"value"命令，将"VARIABLE"设置为空字符串。
# ---------------------------------------

echo hello    # hello
# 对echo来说，这不是变量引用，只是字符串"hello"...

echo $hello   # 375
# ^
# 这是变量引用。
echo ${hello} # 375
# ^
# 同样是变量引用。

# 引用...
echo "$hello"    # 375
echo "${hello}"  # 375

echo

hello="A B  C   D"
echo $hello   # A B C D
echo "$hello" # A B  C   D
# 可以看到，echo $hello 和 echo "$hello" 的输出结果不同。
# =======================================
# 引用变量时保留空格。
# =======================================



`echo '$hello' 
# $hello`：输出变量 $hello，该变量被单引号括起来，因此不会进行变量替换。
# 这演示了单引号的作用，即禁用变量引用，导致 $ 被解释为字面量。


# 注意不同类型引号的影响。

hello= # 将变量 hello 设置为空值。

echo "\$hello (null value) = $hello" # 输出变量 $hello的值，该变量为空值。所以打印结果为 $hello (null value) = 

# 注意将变量设置为空值与取消设置变量不同，尽管最终结果相同（见下文）。
# 允许在同一行设置多个变量，如果用空格分隔开。


# 可能会导致旧版“sh”出现问题......

# 如果变量中嵌入了空格，则需要使用双引号包裹。
numbers="one two three"
echo "numbers = $numbers"

other_numbers=1 2 3  # 会报错说bash: 2: command not found
# 使用双引号包裹
other_numbers="1 2 3" # 不会报错

echo "other_numbers = $other_numbers" 
# 此时输出为：other_numbers = 1 2 3

# 也可以用\符号，作为前导转义空格
mixed_bag=2\ ---\ Whatever # 设置变量 mixed_bag 的值，包含一个转义空格。那么mixed_bag的值为"2 --- Whatever"这字符串。

echo "$mixed_bag" # 2 --- Whatever`：输出变量 mixed_bag 的值。

echo; echo`：输出空行。

echo "uninitialized_variable = $uninitialized_variable" # 输出变量 uninitialized_variable，该变量具有空值。

uninitialized_variable= # 声明，但不初始化它 -- #+ 与将其设置为 null 值相同，如上所述。

echo "uninitialized_variable = $uninitialized_variable" # 输出变量 uninitialized_variable，该变量仍然具有空值。

uninitialized_variable=23 # 设置变量 uninitialized_variable 的值。

unset uninitialized_variable # 取消设置变量 unitialized_variable。使用unset命令

echo "uninitialized_variable = $unitialized_variable" # 输出变量 uninitialized_variable，该变量已被取消设置，具有空值。

exit 0
```


## 未赋值
以上例子中，未初始化的变量，有一个"null"值，不是字符串"null"，而是未赋值的状态。变量的为赋值状态，可以用if [ -z "$xxxx" ] 的-z 参数去判断。

```sh
if [ -z "$unassigned" ]
then
  echo "\$unassigned is NULL."
fi     # $unassigned is NULL.
```
直接使用未赋值的变量，可能引起一些问题，但可以对未赋值的变量做算数运算，达到初始化变量的效果。

```sh
echo "$uninitialized"     # 空行空变量
let "uninitialized += 5"  # 将该空变量加 5 
echo "$uninitialized"     # 现在该变量有值了，等于5

# 注意
# shell中，未初始化的变量没有值。
# 但在shell的算数运算中使用未初始化的变量，则该变量将被作为值等于0的变量使用。
```

