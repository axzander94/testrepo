# print("Ты кто такой?")
# name = input("Введи свое имя: ")
# print(f"Здорова, {name}!")
# print("Че хотел, брат?")
# desire = input("Введи причину, зачем побеспокоил: ")
# print(f"Понял тебя, {name}. Ты хочешь: {desire}. Ладно, разберемся с этим позже.")

print("Давай посчитаем вместе!")
a = int(input("Введи первое число: "))
operation = input("Введи операцию (+, -, *, /): ")
b = int(input("Введи второе число: "))
result = None
if operation == "+":
    result = a + b
if operation == "-":
    result = a - b
if operation == "*":
    result = a * b
if operation == "/":
    result = a / b
print(f"Ответ: {result}")
