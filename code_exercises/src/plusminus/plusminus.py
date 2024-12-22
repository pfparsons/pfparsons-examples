#!/bin/python3

def plusMinus(arr: list[int]):
    pos = 0
    neg = 0
    zero = 0
    n = len(arr) or 1
    dec_digits = 6

    for v in arr:
        if v > 0:
            pos += 1
        elif v < 0:
            neg += 1
        else:
            zero += 1
    
    print(f'{pos / n:.{dec_digits}f}')
    print(f'{neg / n:.{dec_digits}f}')
    print(f'{zero / n:.{dec_digits}f}')


if __name__ == '__main__':
    arr = list(map(int, input().rstrip().split()))
    plusMinus(arr)
