def calculate(num1, num2, operator):
    if operator == '+':
        return num1 + num2
    elif operator == '-':
        return num1 - num2
    elif operator == '%':
        return num1 % num2
    else:
        return "Invalid operator"

def main():
    try:
        num1 = float(input("Enter the first number: "))
        num2 = float(input("Enter the second number: "))
        operator = input("Enter an operator (+, -, %): ")
        result = calculate(num1, num2, operator)
        print(f"The result is: {result}")
    except ValueError:
        print("Invalid input. Please enter numeric values.")

if __name__ == "__main__":
    